#!/usr/bin/env bash
set -euo pipefail

ECKO=${ECKO:-ecko}
TIMEOUT=${ECKO_FENCE_TIMEOUT:-5}

if (($# == 0)); then
    if [[ -f docs/reference/lang-spec.md ]]; then
        set -- docs/reference/lang-spec.md
    else
        echo "need a path" >&2
        exit 1
    fi
fi

files=()
for path in "$@"; do
    if [[ -d "$path" ]]; then
        while IFS= read -r -d '' file; do
            files+=("$file")
        done < <(find "$path" -type f -name '*.md' -print0)
    elif [[ -f "$path" ]]; then
        files+=("$path")
    else
        echo "need a path: $path" >&2
        exit 1
    fi
done

tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/ecko-doc-fences.XXXXXX")
trap 'rm -rf "$tmpdir"' EXIT
tmpfile="$tmpdir/fence.ecko"

run_count=0
skip_count=0
fail_count=0

run_timed() {
    perl -e 'alarm shift; exec @ARGV' "$TIMEOUT" "$@"
}

for file in "${files[@]}"; do
    in_fence=0
    info=

    while IFS= read -r line || [[ -n "$line" ]]; do
        if ((in_fence == 0)); then
            if [[ "$line" == '```ecko'* ]]; then
                info=${line#\`\`\`}
                info=${info#"${info%%[![:space:]]*}"}
                info=${info%"${info##*[![:space:]]}"}
                : >"$tmpfile"
                in_fence=1
            fi
            continue
        fi

        if [[ "$line" != '```' ]]; then
            printf '%s\n' "$line" >>"$tmpfile"
            continue
        fi

        in_fence=0
        case "$info" in
            ecko)
                run_count=$((run_count + 1))
                if ! "$ECKO" fmt --check "$tmpfile"; then
                    fail_count=$((fail_count + 1))
                elif ! run_timed "$ECKO" "$tmpfile"; then
                    fail_count=$((fail_count + 1))
                fi
                ;;
            "ecko fragment")
                skip_count=$((skip_count + 1))
                ;;
            ecko*)
                echo "$file: unknown fence info: $info" >&2
                fail_count=$((fail_count + 1))
                ;;
        esac
    done <"$file"

    if ((in_fence != 0)); then
        echo "$file: unterminated ecko fence" >&2
        fail_count=$((fail_count + 1))
    fi
done

echo "fences: $run_count run, $skip_count skipped, $fail_count failed"
((fail_count == 0))
