#!/usr/bin/env bash
# Every `std.<mod>\t<name>` row in the exports dump (synced from core at
# tools/from-core/std-exports.txt) must have a matching public page under
# DOCS_ROOT/stdlib/ that at least mentions the name.
#
#   check-std-inventory.sh [DOCS_ROOT] [EXPORTS]
set -euo pipefail
cd "$(dirname "$0")/.."
docs="${1:-.}"
exports="${2:-tools/from-core/std-exports.txt}"
fail=0
checked=0
while IFS=$'\t' read -r mod name; do
    [ -z "${mod:-}" ] && continue
    case "$mod" in \#*) continue ;; esac
    checked=$((checked + 1))
    leaf="${mod#std.}"
    page="$docs/stdlib/${leaf}.md"
    if [ ! -f "$page" ]; then
        echo "missing page $page (for $mod.$name)"
        fail=1
        continue
    fi
    if ! grep -qF "$name" "$page"; then
        echo "$page does not mention $mod.$name"
        fail=1
    fi
done < "$exports"
if [ "$checked" -eq 0 ]; then
    echo "check-std-inventory: parsed zero export rows from $exports - file is empty or malformed" >&2
    exit 1
fi
exit "$fail"
