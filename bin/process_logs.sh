#!/bin/bash
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

cd "$1" || exit

find . -type f -exec cat {} + | awk '
  /Failed password for invalid user/ {
    split($0, a, " ")
    print a[1], a[2], substr(a[3], 1, 2), a[11], a[13]
  }
  /Failed password for/ && !/invalid user/ {
    split($0, a, " ")
    print a[1], a[2], substr(a[3], 1, 2), a[9], a[11]
  }
' > failed_login_data