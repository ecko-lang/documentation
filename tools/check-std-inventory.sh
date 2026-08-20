#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
docs="${1:-.}"
exports="${2:-tools/from-core/std-exports.txt}"
fail=0
while IFS=$'\t' read -r mod name; do
    [ -z "${mod:-}" ] && continue
    case "$mod" in \#*) continue ;; esac
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
exit "$fail"
