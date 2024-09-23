#!/bin/bash

here=$(pwd)

if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

target="$1"

if ! cd "$target"; then
  echo "Error: Unable to access directory $target"
  exit 1
fi

out="username_dist.html"
head="$here/html_components/username_dist_header.html"
foot="$here/html_components/username_dist_footer.html"

if [ -f "$head" ]; then
  cat "$head" > "$out"
else
  echo "Header file missing (we are here: $here): $head"
  exit 1
fi

temp=$(mktemp)

find . -mindepth 1 -maxdepth 1 -type d | while read -r sub_dir; do
  login="$sub_dir/failed_login_data.txt"
  if [ -f "$login" ]; then
    awk '{print $4}' "$login" >> "$temp"
  fi
done

if [ -s "$temp" ]; then
  sort "$temp" | uniq -c | while read -r count username; do
    printf "data.addRow([\x27%s\x27, %d]);\n" "$username" "$count" >> "$out"
  done
else
  echo "No usernames found."
  exit 1
fi

if [ -f "$foot" ]; then
  cat "$foot" >> "$out"
else
  echo "Footer file missing: $foot"
  exit 1
fi

rm -f "$temp"

echo "Username distribution chart created: $out"