#!/usr/bin/env bash
# Extract every ```ecko fenced block from the given Markdown file(s) (or every
# .md under a directory) and check it: `ecko fmt --check` must accept it
# byte-identically, then it must run to a non-error exit inside a timeout.
# A block tagged ```ecko fragment is intentionally partial and is skipped
# rather than run. Anything else after ```ecko is an unknown info string and
# fails loudly rather than being silently ignored.
#
#   ECKO               path to the ecko binary to run (default: ecko on PATH -
#                       CI and release-check.sh set this to the freshly built
#                       target/debug/ecko so a stale PATH binary can't hide a
#                       break)
#   ECKO_FENCE_TIMEOUT seconds allowed per fence before it counts as a
#                       failure (default: 5) - catches a fence that hangs
#                       instead of erroring
#
# Documentation (ecko-lang/Documentation) carries a twin of this script at
# tools/check-doc-fences.sh for its own public pages. The two repos have no
# shared build, so keep them in sync by hand: copy this file across
# byte-for-byte whenever it changes.
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
    start=0
    lineno=0

    while IFS= read -r line || [[ -n "$line" ]]; do
        lineno=$((lineno + 1))
        if ((in_fence == 0)); then
            if [[ "$line" == '```ecko'* ]]; then
                info=${line#\`\`\`}
                info=${info#"${info%%[![:space:]]*}"}
                info=${info%"${info##*[![:space:]]}"}
                : >"$tmpfile"
                in_fence=1
                start=$lineno
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
                    echo "$file:$start: fence failed (fmt --check)" >&2
                    fail_count=$((fail_count + 1))
                elif ! run_timed "$ECKO" "$tmpfile"; then
                    echo "$file:$start: fence failed (run)" >&2
                    fail_count=$((fail_count + 1))
                fi
                ;;
            "ecko fragment")
                skip_count=$((skip_count + 1))
                ;;
            ecko*)
                echo "$file:$start: unknown fence info: $info" >&2
                fail_count=$((fail_count + 1))
                ;;
        esac
    done <"$file"

    if ((in_fence != 0)); then
        echo "$file:$start: unterminated ecko fence" >&2
        fail_count=$((fail_count + 1))
    fi
done

echo "fences: $run_count run, $skip_count skipped, $fail_count failed"
((fail_count == 0))
