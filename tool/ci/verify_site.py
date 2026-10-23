#!/usr/bin/env python3
"""Check rendered slash routes used by the app and store privacy/support links."""
from pathlib import Path
import sys


def verify_site(root):
    checked = []
    for language in ['', 'zh-CN/']:
        for page in ['privacy', 'terms', 'support']:
            route = f'{language}{page}/index.html'
            path = Path(root) / route
            if not path.is_file():
                raise ValueError(f'Missing rendered app/store URL: {route}')
            html = path.read_text()
            if '<html' not in html.lower() or 'MorseCQ' not in html:
                raise ValueError(f'Empty or unexpected store page: {route}')
            checked.append(route)
    return checked


if __name__ == '__main__':
    routes = verify_site(sys.argv[1])
    print(f'Verified {len(routes)} rendered privacy/terms/support slash routes')
