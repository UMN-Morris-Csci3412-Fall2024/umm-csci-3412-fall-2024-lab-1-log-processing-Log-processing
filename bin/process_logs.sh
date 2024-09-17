#!/bin/bash

# Check if a directory argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Set the target directory and check if it is a directory
TARGET_DIR="$1"
if [ ! -d "$TARGET_DIR" ]; then
  echo "$TARGET_DIR is not a directory"
  exit 1
fi

# Create a temporary directory for extraction
TEMP_DIR=$(mktemp -d)

# Extract all .tgz files into the temporary directory
for file in "$TARGET_DIR"/*.tgz; do
  if [ -f "$file" ]; then
    echo "Extracting $file..."
    tar -xzf "$file" -C "$TEMP_DIR"
  else
    echo "$file does not exist or is not a regular file"
  fi
done

# Change to the temporary directory
cd "$TEMP_DIR" || { echo "Failed to change to temporary directory"; exit 1; }

# Process log files
find . -type f -exec cat {} + | awk '
  /Failed password for invalid user/ {
    split($0, a, " ")
    if (length(a) >= 13) {
      print a[1], a[2], substr(a[3], 1, 2), a[11], a[13]
    } else {
      print "Malformed line:", $0
    }
  }
  /Failed password for/ && !/invalid user/ {
    split($0, a, " ")
    if (length(a) >= 11) {
      print a[1], a[2], substr(a[3], 1, 2), a[9], a[11]
    } else {
      print "Malformed line:", $0
    }
  }
' > failed_login_data

# Clean up temporary directory
rm -rf "$TEMP_DIR"

echo "Processing complete. Results saved to failed_login_data"
