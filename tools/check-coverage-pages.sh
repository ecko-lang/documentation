#!/usr/bin/env bash
# Every `page:` entry in the lang-spec coverage map (synced from core at
# tools/from-core/coverage.yaml) must point at a public doc page that
# actually exists under DOCS_ROOT.
#
#   check-coverage-pages.sh [DOCS_ROOT] [MAP]
set -euo pipefail
cd "$(dirname "$0")/.."
docs="${1:-.}"
map="${2:-tools/from-core/coverage.yaml}"
fail=0
checked=0
while IFS= read -r page; do
    [ -z "$page" ] && continue
    checked=$((checked + 1))
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
if [ "$checked" -eq 0 ]; then
    echo "check-coverage-pages: parsed zero page: entries from $map - map is empty or malformed" >&2
    exit 1
fi
exit "$fail"
