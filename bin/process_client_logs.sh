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

# Define the output directory and file.
output_dir="data/discovery"
output_file="$output_dir/failed_login_data.txt"
temp_dir=$(mktemp -d)

# Create the output directory if it doesn't exist.
mkdir -p "$output_dir"

# Empty the output file if it already exists.
> "$output_file"

# Extract .tgz files into a temporary directory
find "$log_dir" -type f -name "*.tgz" | while read -r tgz_file; do
  echo "Extracting file: $tgz_file"  # Debugging statement
  tar -xzf "$tgz_file" -C "$temp_dir"
done

# Process each log file within the temporary directory.
find "$temp_dir" -type f -name "secure*" | while read -r log_file; do
  echo "Processing file: $log_file"  # Debugging statement
  # Extract failed login attempts using grep.
  grep "Failed password for" "$log_file" | \
  awk '{print $1, $2, substr($3, 1, 2), $9, $(NF-3)}' >> "$output_file"
  
  # Check if grep found any lines
  if [ $? -ne 0 ]; then
    echo "No failed login attempts found in $log_file"  # Debugging statement
  fi
done

# Clean up the temporary directory
rm -rf "$temp_dir"

# Check if the output file is still empty
if [ ! -s "$output_file" ]; then
  echo "No failed login attempts found in any log files."  # Debugging statement
else
  echo "Failed login attempts have been recorded in $output_file"  # Debugging statement
fi