#!/bin/bash

set -euo pipefail

usage() {
    echo "Usage: $0 file1.pdf file2.pdf [...] -out output.pdf"
    echo ""
    echo "Merges multiple PDF files into a single output PDF."
    echo "Files are merged in the order they are provided."
    exit 1
}

if [ $# -lt 3 ]; then
    usage
fi

INPUT_FILES=()
OUTPUT_FILE=""

while [ $# -gt 0 ]; do
    case "$1" in
        -out)
            if [ -z "${2:-}" ]; then
                echo "Error: -out requires an output file path."
                exit 1
            fi
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -*)
            echo "Error: Unknown option '$1'."
            usage
            ;;
        *)
            INPUT_FILES+=("$1")
            shift
            ;;
    esac
done

# Validate that output was specified
if [ -z "$OUTPUT_FILE" ]; then
    echo "Error: No output file specified. Use -out <file>."
    exit 1
fi

# Validate at least 2 input files
if [ ${#INPUT_FILES[@]} -lt 2 ]; then
    echo "Error: At least 2 input PDF files are required."
    exit 1
fi

# Check that all input files exist
for f in "${INPUT_FILES[@]}"; do
    if [ ! -f "$f" ]; then
        echo "Error: Input file '$f' does not exist."
        exit 1
    fi
done

# Check that the output directory exists
OUTPUT_DIR="$(dirname "$OUTPUT_FILE")"
if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Error: Output directory '$OUTPUT_DIR' does not exist."
    exit 1
fi

# Check that the output file does not already exist
if [ -f "$OUTPUT_FILE" ]; then
    echo "Error: Output file '$OUTPUT_FILE' already exists."
    exit 1
fi

# Merge PDFs
pdfunite "${INPUT_FILES[@]}" "$OUTPUT_FILE"

echo "Merged ${#INPUT_FILES[@]} files into '$OUTPUT_FILE'."
