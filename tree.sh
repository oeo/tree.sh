#!/usr/bin/env python3
import os
from pathlib import Path
import glob
import fnmatch
import argparse

IGNORE_DIRS = {
    'node_modules',
    '.git',
    '__pycache__',
    'venv',
    '.idea',
    '.vscode',
    'build',
    'dist'
}

MAX_ITEMS = 100

def print_tree(directory, prefix="", is_root=False, pattern="*"):
    try:
        items = list(os.scandir(directory))
        dir_name = Path(directory).name

        if (dir_name in IGNORE_DIRS) or (not is_root and len(items) > MAX_ITEMS):
            return f"{prefix}[+] {dir_name}/ ({len(items)} items - skipped)"

        filtered_items = []
        for item in items:
            if item.is_dir():
                filtered_items.append(item)
            elif fnmatch.fnmatch(item.name, pattern):
                filtered_items.append(item)

        filtered_items.sort(key=lambda x: (not x.is_dir(), x.name.lower()))

        if not filtered_items:
            return None

        lines = []
        for index, item in enumerate(filtered_items):
            is_last = index == len(filtered_items) - 1
            connector = "└── " if is_last else "├── "

            if item.is_dir():
                if item.name in IGNORE_DIRS or len(list(os.scandir(item.path))) > MAX_ITEMS:
                    subtree = None
                else:
                    subtree = print_tree(item.path, prefix + ("    " if is_last else "│   "), pattern=pattern)

                if subtree:
                    lines.append(f"{prefix}{connector}{item.name}/")
                    lines.append(subtree)
            else:
                lines.append(f"{prefix}{connector}{item.name}")

        return "\n".join(lines) if lines else None

    except PermissionError:
        return f"{prefix}[!] {Path(directory).name}/ (Permission denied)"

def parse_args():
    parser = argparse.ArgumentParser(
        description='Display directory tree structure with optional file pattern matching',
        formatter_class=argparse.RawTextHelpFormatter
    )

    parser.add_argument('directory', nargs='?', default='.',
                      help='Directory to scan (default: current directory)')

    parser.add_argument('-d', '--dir',
                      help='Explicitly specify directory to scan (alternative to positional argument)')

    parser.add_argument('-p', '--pattern',
                      help='File pattern to match (e.g., "*.coffee", "*.py")')

    parser.add_argument('--max-items', type=int, default=MAX_ITEMS,
                      help=f'Maximum number of items in directory before skipping (default: {MAX_ITEMS})')

    # Add example usage
    parser.epilog = '''
examples:
  tree.py                     # Show tree for current directory
  tree.py /path/to/dir       # Show tree for specific directory
  tree.py -p "*.coffee"      # Show only .coffee files in current directory
  tree.py /path -p "*.py"    # Show only .py files in /path
  tree.py --dir /path        # Alternative way to specify directory'''

    return parser.parse_args()

def main():
    args = parse_args()

    # Determine directory (--dir takes precedence over positional argument)
    directory = args.dir if args.dir else args.directory
    pattern = args.pattern if args.pattern else "*"

    # Make sure directory exists
    if not os.path.exists(directory):
        print(f"Error: Directory '{directory}' does not exist")
        return 1

    # Make sure directory is actually a directory
    if not os.path.isdir(directory):
        print(f"Error: '{directory}' is not a directory")
        return 1

    print(f"{os.path.abspath(directory)}")
    tree = print_tree(directory, is_root=True, pattern=pattern)
    if tree:
        print(tree)
    else:
        if pattern != "*":
            print(f"No files matching pattern '{pattern}' found.")
        else:
            print("Directory is empty.")

if __name__ == "__main__":
    main()
