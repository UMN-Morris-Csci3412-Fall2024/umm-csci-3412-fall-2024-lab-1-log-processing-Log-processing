#!/bin/bash

# Check if the directory is provided as an argument.
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Assign the directory variable.
log_dir="$1"

# Check if the provided argument is a directory.
if [ ! -d "$log_dir" ]; then
  echo "Error: $log_dir is not a directory."
  exit 1
fi

# Define the output file.
output_file="$log_dir/failed_login_data.txt"

# Empty the output file if it already exists.
> "$output_file"

# Process each log file within the directory.
find "$log_dir" -type f -name "secure*" | while read -r log_file; do
  # Extract failed login attempts using grep.
  # Adjust the pattern below to match "Failed password for" lines in the logs.
  grep "Failed password for" "$log_file" | \
  awk '{print $1, $2, substr($3, 1, 2), $9, $11}' >> "$output_file"
done

echo "Failed login data has been extracted to $output_file."
