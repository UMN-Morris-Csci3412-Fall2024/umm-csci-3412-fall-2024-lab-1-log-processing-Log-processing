#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Check if the directory exists and is not empty
if [ ! -d "$1" ] || [ -z "$(ls -A "$1")" ]; then
  echo "Directory $1 does not exist or is empty"
  exit 1
fi

# Find all files in the specified directory and concatenate their contents
find "$1" -type f -exec cat {} + | awk '
  # Process lines with "Failed password for invalid user"
  /Failed password for invalid user/ {
    # Split the line into an array 'a' using space as the delimiter
    split($0, a, " ")
    # Split the time field (a[3]) into an array 't' using colon as the delimiter
    split(a[3], t, ":")
    # Print the date, month, hour (dropping minutes and seconds), username, and IP address
    print a[1], a[2], t[1], a[11], a[13]
  }
  # Process lines with "Failed password for" but exclude "invalid user" and "Accepted password"
  /Failed password for / && !/invalid user/ && !/Accepted password/ {
    # Split the line into an array 'a' using space as the delimiter
    split($0, a, " ")
    # Split the time field (a[3]) into an array 't' using colon as the delimiter
    split(a[3], t, ":")
    # Print the date, month, hour (dropping minutes and seconds), username, and IP address
    print a[1], a[2], t[1], a[9], a[11]
  }
' > "$1/failed_login_data.txt"  # Redirect the output to the specified file