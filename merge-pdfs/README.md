# merge-pdfs

Merges multiple PDF files into a single output PDF, preserving the order in which they are provided.

## Prerequisites

- **pdfunite** — part of the `poppler-utils` package.

Install it with:

```bash
# Debian / Ubuntu
sudo apt install poppler-utils

# Fedora
sudo dnf install poppler-utils

# Arch
sudo pacman -S poppler
```

## Usage

```bash
./merge-pdfs.sh file1.pdf file2.pdf [file3.pdf ...] -out output.pdf
```

### Examples

```bash
# Merge two files
./merge-pdfs.sh report-part1.pdf report-part2.pdf -out full-report.pdf

# Merge several files
./merge-pdfs.sh ch1.pdf ch2.pdf ch3.pdf appendix.pdf -out book.pdf
```

## How It Works

1. Parses the command-line arguments, collecting input files and the output path (specified with `-out`).
2. Validates that:
   - At least 2 input PDF files are provided.
   - All input files exist on disk.
   - The output directory exists.
   - The output file does not already exist (prevents accidental overwrites).
3. Calls `pdfunite` with the input files in the given order to produce the merged output.

## Options

| Flag | Description |
|------|-------------|
| `-out <file>` | **(required)** Path for the merged output PDF. |

## Error Handling

The script exits with an error message if:

- Fewer than 2 input files are given.
- Any input file does not exist.
- The `-out` flag is missing or has no value.
- The output directory does not exist.
- The output file already exists.
