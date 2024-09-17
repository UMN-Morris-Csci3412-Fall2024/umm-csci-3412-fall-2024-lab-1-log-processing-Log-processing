#!/bin/bash


if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_file> <header_footer_name> <output_file>"
    exit 1
fi

input_file=$1
header_footer_name=$2
output_file=$3

header_file="html_components/${header_footer_name}_header.html"
footer_file="html_components/${header_footer_name}_footer.html"

if [ ! -f "$header_file" ] || [ ! -f "$footer_file" ]; then
    echo "Header or footer file not found!"
    exit 1
fi

cat "$header_file" "$input_file" "$footer_file" > "$output_file"
echo "Content wrapped successfully into $output_file"