# generate-qr-code

Generates a QR code PNG image from a text string provided by the user.

## Prerequisites

- **qrencode** — command-line QR code generator.
- **ImageMagick** *(optional)* — required only when using the `-h`/`--height`
  option to resize the output image.

Install them with:

```bash
# Debian / Ubuntu
sudo apt install qrencode imagemagick

# Fedora
sudo dnf install qrencode ImageMagick

# Arch
sudo pacman -S qrencode imagemagick
```

## Usage

```bash
./generate-qr-code.sh "<text-to-encode>" -o <output.png> [-h <height-in-pixels>]
```

### Examples

```bash
# Encode a URL
./generate-qr-code.sh "https://example.com" -o site-qr.png

# Encode plain text
./generate-qr-code.sh "Hello, World!" -o hello.png

# Generate a higher-resolution image 600px tall
./generate-qr-code.sh "https://example.com" -o site-qr.png -h 600

# Output to another directory
./generate-qr-code.sh "wifi-password-123" -o ~/qrcodes/wifi.png
```

## How It Works

1. Parses the command-line arguments, collecting the text to encode, the output
   path (`-o` / `--output`), and the optional target height (`-h` / `--height`).
2. Validates that:
   - A text string was provided.
   - An output path was specified.
   - The output file has a `.png` extension.
   - The height, if given, is a positive integer.
   - `qrencode` is installed on the system.
   - The output directory exists.
   - The output file does not already exist (prevents accidental overwrites).
3. Calls `qrencode` to generate the QR code PNG at the given path.
4. If `-h`/`--height` was provided, resizes the image to the requested height
   using ImageMagick, applying nearest-neighbour scaling (the `point` filter) to
   keep the QR modules sharp. Aspect ratio is preserved, so the width scales
   proportionally.

## Options

| Flag | Description |
|------|-------------|
| `-o`, `--output <file>`  | **(required)** Path for the generated QR code PNG. |
| `-h`, `--height <pixels>` | *(optional)* Target image height in pixels. Requires ImageMagick. |
| `--help` | Show the usage message. |

## Error Handling

The script exits with an error message if:

- No text is provided to encode.
- The `-o` flag is missing or has no value.
- The output file does not end in `.png`.
- The `-h` value is not a positive integer.
- `qrencode` is not installed.
- The output directory does not exist.
- The output file already exists.

If `-h`/`--height` is used but ImageMagick is not installed, the script prints a
warning and produces the QR code at its default resolution instead of failing.
