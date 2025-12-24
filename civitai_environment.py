#!/usr/bin/env python3
# 20251224.1
import os
import os.path
import sys
import argparse
import time
import urllib.request
from pathlib import Path
from urllib.parse import urlparse, parse_qs, unquote

CHUNK_SIZE = 1638400
USER_AGENT = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/58.0.3029.110 Safari/537.3"
)

def get_args():
    parser = argparse.ArgumentParser(description="CivitAI Downloader (+ batch mode)")

    # Backwards compatible: positional url + output_path
    parser.add_argument(
        "url",
        nargs="?",
        default=None,
        help="Download URL, e.g. https://civitai.com/api/download/models/46846",
    )
    parser.add_argument(
        "output_path",
        nargs="?",
        default=None,
        help="Output directory, e.g. /workspace/ComfyUI/models/loras",
    )

    # Batch mode: read many urls from a file
    parser.add_argument(
        "--file",
        dest="batch_file",
        type=str,
        default=None,
        help="Batch file with URLs (and optional per-line output dir).",
    )

    # Allow pasting like: "url /path" without needing explicit --url
    # We'll parse free-form trailing arguments into entries
    parser.add_argument(
        "items",
        nargs=argparse.REMAINDER,
        help="Extra items: you can paste 'URL /path' pairs here.",
    )

    parser.add_argument(
        "--quit",
        action="store_true",
        help="No console output except error handling",
    )

    return parser.parse_args()


def get_token():
    # Correct behavior: return None if not set (don't use a fake default)
    token = os.environ.get("CIVITAI_TOKEN")
    if not token:
        raise ValueError("CIVITAI_TOKEN environment variable is not set")
    return token


def _is_url(s: str) -> bool:
    if not s:
        return False
    p = urlparse(s)
    return p.scheme in ("http", "https") and bool(p.netloc)


def parse_batch_line(line: str):
    line = line.strip()
    if not line or line.startswith("#"):
        return None

    # Simple split (supports paths without spaces)
    parts = line.split()
    if len(parts) == 1:
        return (parts[0], None)

    # If user accidentally put path first, try to detect and swap
    if _is_url(parts[0]) and not _is_url(parts[1]):
        return (parts[0], parts[1])

    if _is_url(parts[1]) and not _is_url(parts[0]):
        return (parts[1], parts[0])

    # If both look like URLs or neither do, just assume "url output"
    return (parts[0], parts[1])


def build_download_entries(args):
    entries = []

    # 1) Batch file mode
    if args.batch_file:
        default_out = args.output_path  # may be None; then line must provide outdir
        with open(args.batch_file, "r", encoding="utf-8") as f:
            for raw in f:
                parsed = parse_batch_line(raw)
                if not parsed:
                    continue
                url, outdir = parsed
                if not outdir:
                    outdir = default_out
                if not outdir:
                    raise ValueError(
                        f"Batch line missing output dir and no default output_path provided: {raw.strip()}"
                    )
                entries.append((url, outdir))

    # 2) Positional single mode: URL + OUTDIR
    if args.url and args.output_path:
        entries.append((args.url, args.output_path))

    # 3) Free-form pasted items (REMAINDER)
    # Allow:
    #   script.py https://... /path
    #   script.py https://... /path https://... /path
    if args.items:
        items = [x for x in args.items if x.strip()]
        i = 0
        while i < len(items):
            a = items[i]
            b = items[i + 1] if i + 1 < len(items) else None

            # If "URL /path"
            if _is_url(a) and b and not _is_url(b):
                entries.append((a, b))
                i += 2
                continue

            # If "/path URL"
            if (not _is_url(a)) and b and _is_url(b):
                entries.append((b, a))
                i += 2
                continue

            # If just a URL, try to use args.output_path as default
            if _is_url(a):
                if not args.output_path:
                    raise ValueError(f"Missing output directory for URL: {a}")
                entries.append((a, args.output_path))
                i += 1
                continue

            # If it's not a URL, user probably provided a stray path or typo
            raise ValueError(f"Unrecognized argument sequence near: '{a}'")

    # De-duplicate while preserving order
    seen = set()
    unique = []
    for u, o in entries:
        key = (u, o)
        if key not in seen:
            seen.add(key)
            unique.append((u, o))

    return unique


def ensure_dir(path: str):
    os.makedirs(path, exist_ok=True)
    if not os.path.isdir(path):
        raise ValueError(f"Output path is not a directory: {path}")


def filename_from_url(url: str) -> str:
    """
    Best effort filename extraction from a direct URL.
    """
    parsed = urlparse(url)
    base = os.path.basename(parsed.path.rstrip("/"))
    if base:
        return base

    # fallback
    return "download.safetensors"


def download_file(url: str, output_path: str, token: str, quiet: bool):
    ensure_dir(output_path)

    headers = {
        "Authorization": f"Bearer {token}",
        "User-Agent": USER_AGENT,
    }

    class NoRedirection(urllib.request.HTTPErrorProcessor):
        def http_response(self, request, response):
            return response
        https_response = http_response

    request = urllib.request.Request(url, headers=headers)
    opener = urllib.request.build_opener(NoRedirection)
    response = opener.open(request)

    filename = None

    if response.status in [301, 302, 303, 307, 308]:
        redirect_url = response.getheader("Location")
        if not redirect_url:
            raise Exception("Redirect without Location header")

        # Try extract filename from query parameter (civitai style)
        parsed_url = urlparse(redirect_url)
        query_params = parse_qs(parsed_url.query)
        content_disposition = query_params.get("response-content-disposition", [None])[0]

        if content_disposition and "filename=" in content_disposition:
            filename = unquote(content_disposition.split("filename=")[1].strip('"'))
        else:
            # fallback: from redirect URL path
            filename = filename_from_url(redirect_url)

        response = urllib.request.urlopen(redirect_url)
    elif response.status == 404:
        raise Exception("File not found")
    elif response.status == 200:
        # Sometimes you might get a direct file without redirect
        filename = filename_from_url(url)
    else:
        raise Exception(f"Unexpected HTTP status: {response.status}")

    total_size = response.getheader("Content-Length")
    total_size = int(total_size) if total_size is not None else None

    output_file = os.path.join(output_path, filename)

    with open(output_file, "wb") as f:
        downloaded = 0
        start_time = time.time()
        speed = 0.0

        while True:
            chunk_start_time = time.time()
            buffer = response.read(CHUNK_SIZE)
            chunk_end_time = time.time()

            if not buffer:
                break

            downloaded += len(buffer)
            f.write(buffer)

            chunk_time = chunk_end_time - chunk_start_time
            if chunk_time > 0:
                speed = len(buffer) / chunk_time / (1024 ** 2)

            if total_size is not None and not quiet:
                progress = downloaded / total_size
                sys.stdout.write(
                    f"\rDownloading: {filename} [{progress*100:.2f}%] - {speed:.2f} MB/s"
                )
                sys.stdout.flush()

    time_taken = time.time() - start_time
    hours, remainder = divmod(time_taken, 3600)
    minutes, seconds = divmod(remainder, 60)

    if hours > 0:
        time_str = f"{int(hours)}h {int(minutes)}m {int(seconds)}s"
    elif minutes > 0:
        time_str = f"{int(minutes)}m {int(seconds)}s"
    else:
        time_str = f"{int(seconds)}s"

    if not quiet:
        sys.stdout.write("\n")
        print(f"Download completed. File saved as: {output_file}")
        print(f"Downloaded in {time_str}")


def main():
    args = get_args()
    token = get_token()

    try:
        entries = build_download_entries(args)
        if not entries:
            raise ValueError(
                "No downloads specified. Use:\n"
                "  script.py URL OUTDIR\n"
                "  script.py --file batchfile.txt\n"
                "  script.py URL OUTDIR URL OUTDIR ...\n"
                "  script.py URL OUTDIR  (paste style)\n"
            )

        # Batch processing
        for (url, outdir) in entries:
            try:
                if not args.quit:
                    print(f"ℹ️ [DOWNLOAD] Fetching {url} → {outdir} ...")
                download_file(url, outdir, token, args.quit)
            except Exception as e:
                print(f"ERROR: {e}", file=sys.stderr)
                print(f"⚠️ Failed to download {url}", file=sys.stderr)

    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()