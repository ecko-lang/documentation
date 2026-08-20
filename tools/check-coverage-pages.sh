#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
docs="${1:-.}"
map="${2:-tools/from-core/coverage.yaml}"
fail=0
while IFS= read -r page; do
    [ -z "$page" ] && continue
    if [ ! -f "$docs/$page" ]; then
        echo "missing $docs/$page"
        fail=1
    fi
done < <(awk '
    $1 == "page:" {
        p = $2
        gsub(/"/, "", p)
        print p
    }
' "$map")
exit "$fail"
