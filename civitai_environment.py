#!/usr/bin/env python3
import os
import os.path
import sys
import argparse
import time
import urllib.request
from pathlib import Path
from urllib.parse import urlparse, parse_qs, unquote


CHUNK_SIZE = 1638400
TOKEN_FILE = Path.home() / '.civitai' / 'config'
USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'


def get_args():
    parser = argparse.ArgumentParser(description='CivitAI Downloader')

    parser.add_argument(
        'output_path',
        type=str,
        help='Output path, eg: /workspace/ComfyUI/models/loras'
    )

    # Either a single URL, or --file
    parser.add_argument(
        'url',
        nargs='?',
        type=str,
        help='CivitAI Download URL, eg: https://civitai.com/api/download/models/2529895?type=Model&format=SafeTensor'
    )

    parser.add_argument(
        '--file',
        type=str,
        default=None,
        help='Batch file with URLs (one per line). Lines starting with # are ignored.'
    )

    parser.add_argument(
        '--quit',
        action='store_true',
        help='No console output except error handling'
    )

    return parser.parse_args()


def get_token():
    civitai_token = os.environ.get('CIVITAI_TOKEN')

    if not civitai_token:
        raise ValueError("CIVITAI_TOKEN environment variable is not set (or empty)")

    return civitai_token


def read_batch_file(batch_file: str):
    urls = []
    with open(batch_file, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            urls.append(line)
    return urls


def ensure_output_dir(path: str):
    os.makedirs(path, exist_ok=True)
    if not os.path.isdir(path):
        raise ValueError(f"Output path is not a directory: {path}")


def download_file(url: str, output_path: str, token: str, quiet: bool):
    headers = {
        'Authorization': f'Bearer {token}',
        'User-Agent': USER_AGENT,
    }

    # Disable automatic redirect handling
    class NoRedirection(urllib.request.HTTPErrorProcessor):
        def http_response(self, request, response):
            return response
        https_response = http_response

    request = urllib.request.Request(url, headers=headers)
    opener = urllib.request.build_opener(NoRedirection)
    response = opener.open(request)

    if response.status in [301, 302, 303, 307, 308]:
        redirect_url = response.getheader('Location')

        # Extract filename from the redirect URL
        parsed_url = urlparse(redirect_url)
        query_params = parse_qs(parsed_url.query)
        content_disposition = query_params.get('response-content-disposition', [None])[0]

        if content_disposition and 'filename=' in content_disposition:
            filename = unquote(content_disposition.split('filename=')[1].strip('"'))
        else:
            raise Exception('Unable to determine filename')

        response = urllib.request.urlopen(redirect_url)
    elif response.status == 404:
        raise Exception('File not found')
    else:
        raise Exception(f'No redirect found, something went wrong (HTTP {response.status})')

    total_size = response.getheader('Content-Length')
    if total_size is not None:
        total_size = int(total_size)

    output_file = os.path.join(output_path, filename)

    # Skip if already exists (optional behavior)
    if os.path.exists(output_file) and os.path.getsize(output_file) > 0:
        if not quiet:
            print(f'SKIP: {filename} already exists: {output_file}')
        return

    with open(output_file, 'wb') as f:
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
                speed = len(buffer) / chunk_time / (1024 ** 2)  # MB/s

            if total_size is not None and not quiet:
                progress = downloaded / total_size
                sys.stdout.write(f'\rDownloading: {filename} [{progress*100:.2f}%] - {speed:.2f} MB/s')
                sys.stdout.flush()

    end_time = time.time()
    time_taken = end_time - start_time
    hours, remainder = divmod(time_taken, 3600)
    minutes, seconds = divmod(remainder, 60)

    if hours > 0:
        time_str = f'{int(hours)}h {int(minutes)}m {int(seconds)}s'
    elif minutes > 0:
        time_str = f'{int(minutes)}m {int(seconds)}s'
    else:
        time_str = f'{int(seconds)}s'

    if not quiet:
        sys.stdout.write('\n')
        print(f'Download completed. File saved as: {filename}')
        print(f'Downloaded in {time_str}')


def main():
    args = get_args()
    token = get_token()
    ensure_output_dir(args.output_path)

    # Validate mutually exclusive mode
    if args.file and args.url:
        print("ERROR: Use either a single URL OR --file batchfile.txt (not both).", file=sys.stderr)
        sys.exit(2)

    if not args.file and not args.url:
        print("ERROR: Missing URL. Provide a URL or use --file batchfile.txt.", file=sys.stderr)
        sys.exit(2)

    # Build URL list
    if args.file:
        try:
            urls = read_batch_file(args.file)
        except Exception as e:
            print(f'ERROR: Could not read batch file: {e}', file=sys.stderr)
            sys.exit(1)

        if not urls:
            print('ERROR: Batch file contained no URLs.', file=sys.stderr)
            sys.exit(1)

        failed = 0
        for i, url in enumerate(urls, start=1):
            if not args.quit:
                print(f'\n[{i}/{len(urls)}] {url}')
            try:
                download_file(url, args.output_path, token, args.quit)
            except Exception as e:
                failed += 1
                print(f'ERROR: {url} -> {e}', file=sys.stderr)

        if failed > 0:
            sys.exit(1)
    else:
        try:
            download_file(args.url, args.output_path, token, args.quit)
        except Exception as e:
            print(f'ERROR: {e}', file=sys.stderr)
            sys.exit(1)


if __name__ == '__main__':
    main()