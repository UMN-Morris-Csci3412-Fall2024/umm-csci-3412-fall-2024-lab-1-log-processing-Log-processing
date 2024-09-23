#!/bin/bash

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <log_archive1.tgz> <log_archive2.tgz> ..."
  exit 1
fi

scratch_dir=$(mktemp -d)

for archive in "$@"; do
  client_name=$(basename "$archive" _secure.tgz)
  
  client_dir="$scratch_dir/$client_name"
  mkdir -p "$client_dir"
  
  tar -xzf "$archive" -C "$client_dir"

  ./bin/process_client_logs.sh "$client_dir"
done

./bin/create_username_dist.sh "$scratch_dir"
./bin/create_hours_dist.sh "$scratch_dir"
./bin/create_country_dist.sh "$scratch_dir"
./bin/assemble_report.sh "$scratch_dir"

mv "$scratch_dir/failed_login_summary.html" .

rm -rf "$scratch_dir"

echo "Report generated successfully: failed_login_summary.html"