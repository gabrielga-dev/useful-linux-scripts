#!/bin/bash

set -euo pipefail

usage() {
    echo "Usage: $0 \"<text-to-encode>\" -o <output.png> [-h <height-in-pixels>]"
    echo ""
    echo "Generates a QR code PNG image from the given text."
    echo ""
    echo "Options:"
    echo "  -o, --output <file>    (required) Path for the generated QR code PNG."
    echo "  -h, --height <pixels>  (optional) Target image height in pixels."
    echo "      --help             Show this help message."
    exit 1
}

if [ $# -lt 1 ]; then
    usage
fi

TEXT=""
OUTPUT_FILE=""
HEIGHT=""

while [ $# -gt 0 ]; do
    case "$1" in
        -o|--output)
            if [ -z "${2:-}" ]; then
                echo "Error: -o requires an output file path."
                exit 1
            fi
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -h|--height)
            if [ -z "${2:-}" ]; then
                echo "Error: -h requires a height in pixels."
                exit 1
            fi
            HEIGHT="$2"
            shift 2
            ;;
        --help)
            usage
            ;;
        -*)
            echo "Error: Unknown option '$1'."
            usage
            ;;
        *)
            if [ -z "$TEXT" ]; then
                TEXT="$1"
            else
                echo "Error: Unexpected extra argument '$1'."
                usage
            fi
            shift
            ;;
    esac
done

# Validate that text was provided
if [ -z "$TEXT" ]; then
    echo "Error: No text provided to encode."
    usage
fi

# Validate that output was specified
if [ -z "$OUTPUT_FILE" ]; then
    echo "Error: No output file specified. Use -o <file>."
    exit 1
fi

# Ensure the output has a .png extension
case "$OUTPUT_FILE" in
    *.png) ;;
    *)
        echo "Error: Output file must have a .png extension."
        exit 1
        ;;
esac

# Validate height, if provided (must be a positive integer)
if [ -n "$HEIGHT" ]; then
    case "$HEIGHT" in
        ''|*[!0-9]*)
            echo "Error: Height must be a positive integer (pixels)."
            exit 1
            ;;
    esac
    if [ "$HEIGHT" -le 0 ]; then
        echo "Error: Height must be greater than 0."
        exit 1
    fi
fi

# Check that qrencode is installed
if ! command -v qrencode >/dev/null 2>&1; then
    echo "Error: 'qrencode' is not installed. Install the 'qrencode' package."
    exit 1
fi

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

# Generate the QR code
qrencode -o "$OUTPUT_FILE" -- "$TEXT"

# Resize to the requested height, if provided
if [ -n "$HEIGHT" ]; then
    # Prefer ImageMagick for an exact height. Use nearest-neighbour scaling
    # ("point" filter) to keep the QR modules crisp.
    if command -v magick >/dev/null 2>&1; then
        magick "$OUTPUT_FILE" -filter point -resize "x${HEIGHT}" "$OUTPUT_FILE"
    elif command -v convert >/dev/null 2>&1; then
        convert "$OUTPUT_FILE" -filter point -resize "x${HEIGHT}" "$OUTPUT_FILE"
    else
        echo "Warning: ImageMagick ('magick'/'convert') not found; cannot resize."
        echo "         Generated QR code at default resolution instead."
        echo "         Install ImageMagick to enable the -h/--height option."
    fi
fi

echo "QR code generated at '$OUTPUT_FILE'."
