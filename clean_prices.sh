#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

if [ "$#" -ne 2 ]; then
    printf 'Usage: bash clean_prices.sh INPUT.csv NEW_OUTPUT_DIR\n' >&2
    exit 2
fi

project_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
input=$1
output=$2

if [ ! -f "$input" ] || [ ! -r "$input" ] || [ ! -s "$input" ]; then
    printf 'ERROR: input must be a readable, nonempty file: %s\n' "$input" >&2
    exit 2
fi

# Require a new directory so each run has its own outputs.
mkdir -- "$output"

awk -v error_log="$output/cleaning.tsv" \
    -f "$project_dir/scripts/clean.awk" < "$input" > "$output/validated.csv"

awk -v duplicate_log="$output/duplicates.tsv" \
    -f "$project_dir/scripts/deduplicate.awk" \
    "$output/validated.csv" > "$output/prices.csv"

input_rows=$(awk 'END {print NR - 1}' < "$input")
validated_rows=$(awk 'END {print NR - 1}' "$output/validated.csv")
retained_rows=$(awk 'END {print NR - 1}' "$output/prices.csv")
duplicate_removals=$(awk -F '\t' 'NR > 1 {total += $4} END {print total + 0}' \
    "$output/duplicates.tsv")

if [ "$retained_rows" -eq 0 ] ||
   [ "$validated_rows" -gt "$input_rows" ] ||
   [ "$validated_rows" -ne "$((retained_rows + duplicate_removals))" ]; then
    printf 'ERROR: no usable rows or row accounting failed\n' >&2
    exit 4
fi

printf 'Input: %d\nRejected by validation: %d\nRemoved by duplicate policy: %d\nRetained: %d\n' \
    "$input_rows" "$((input_rows - validated_rows))" "$duplicate_removals" "$retained_rows" \
    > "$output/summary.txt"

cat "$output/summary.txt"
