# Directory Tree Viewer

A Python script to display the directory tree structure with optional file pattern matching.

## Features

- View directory tree structure
- Filter files using patterns (e.g., `*.py`)
- Skip specified directories and large directories

## Usage

```bash
./tree.py                    # Show tree for current directory
./tree.py /path/to/dir       # Show tree for specific directory
./tree.py -p "*.coffee"      # Show only .coffee files
./tree.py /path -p "*.py"    # Show only .py files in /path
./tree.py --dir /path        # Specify directory using option
```

## Arguments

- `directory`: Directory to scan (default is the current directory)
- `-d, --dir`: Specify directory to scan
- `-p, --pattern`: Pattern to match files (e.g., `*.py`)
- `--max-items`: Max items before skipping a directory (default is 100)

