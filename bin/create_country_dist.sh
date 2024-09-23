#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

target="$1"
output="country_dist.html"
header="../html_components/country_dist_header.html"
footer="../html_components/country_dist_footer.html"
country_ip_map="../etc/country_IP_map.txt"

if ! cd "$target"; then
  echo "Error: Unable to access directory $target"
  exit 1
fi

if [ ! -f "$country_ip_map" ]; then
  echo "Error: Country IP map not found: $country_ip_map"
  exit 1
fi

if [ -f "$header" ]; then
  cat "$header" > "$output"
else
  echo "Header file missing: $header"
  exit 1
fi

temp=$(mktemp)

for sub_dir in */; do
  login_file="${sub_dir%/}/failed_login_data.txt"  
  if [ -f "$login_file" ]; then
    awk '{print $5}' "$login_file" >> "$temp"
  fi
done


mapped=$(mktemp)
sort "$temp" | join -1 1 -2 1 -o 2.2 - "$country_ip_map" > "$mapped"

sort "$mapped" | uniq -c | while read -r count country; do
  printf "data.addRow([\x27%s\x27, %d]);\n" "$country" "$count" >> "$output"
done

if [ -f "$footer" ]; then
  cat "$footer" >> "$output"
else
  echo "Footer file missing: $footer"
  rm -f "$temp" "$mapped"
  exit 1
fi

rm -f "$temp" "$mapped"
echo "Country distribution chart created: $output"