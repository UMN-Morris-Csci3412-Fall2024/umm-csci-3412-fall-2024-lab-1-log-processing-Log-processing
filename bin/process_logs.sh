#!/bin/bash

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <log_archive1.tgz> <log_archive2.tgz> ..."
  exit 1
fi

scratch_dir=$(mktemp -d)

trap 'rm -rf "$scratch_dir"' EXIT

for archive in "$@"; do
  client_name=$(basename "$archive" _secure.tgz)

  client_directory="$scratch_dir/$client_name"
  mkdir -p "$client_directory"

  if tar -xzf "$archive" -C "$client_directory"; then
    echo "Extracted $archive successfully."
  else
    echo "Error extracting $archive."
    exit 1
  fi

  if bin/process_client_logs.sh "$client_directory"; then
    echo "Processed logs for $client_name."
  else
    echo "Error processing logs for $client_name."
    exit 1
  fi
done

if bin/create_username_dist.sh "$scratch_dir"; then
  echo "Generated username distribution."
else
  echo "Error generating username distribution."
  exit 1
fi

if bin/create_hours_dist.sh "$scratch_dir"; then
  echo "Generated hours distribution."
else
  echo "Error generating hours distribution."
  exit 1
fi


if bin/create_country_dist.sh "$scratch_dir"; then
  echo "Generated country distribution."
else
  echo "Error generating country distribution."
  exit 1
fi

if bin/assemble_report.sh "$scratch_dir"; then
  echo "Report assembled successfully."
else
  echo "Error assembling report."
  exit 1
fi

if mv "$scratch_dir/failed_login_summary.html" .; then
  echo "Report generated successfully: failed_login_summary.html"
else
  echo "Error moving the report file."
  exit 1
fi

exit 0