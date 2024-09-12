#!/bin/bash

# Get the content file, specifier, and output file from the command line arguments
content_file=$1
specifier=$2
output_file=$3

# Construct the header and footer file names based on the specifier
header_file="${specifier}_header.html"
footer_file="${specifier}_footer.html"

# Concatenate the header, content, and footer files into the output file
cat "$header_file" "$content_file" "$footer_file" > "$output_file"