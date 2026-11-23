#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

if [ "$#" -ne 2 ]; then
    printf 'Usage: bash analyze.sh INPUT.csv NEW_OUTPUT_DIR\n' >&2
    exit 2
fi

project_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
output=$2

bash "$project_dir/clean_prices.sh" "$1" "$output"
clean_file="$output/prices.csv"

{
    printf 'month,records,observed_dates,total_volume,mean_daily_total_volume\n'
    awk -f "$project_dir/scripts/monthly.awk" "$clean_file" |
        sort -t, -k1,1
} > "$output/monthly.csv"

{
    printf 'symbol,start_date,end_date,first_adj_close,last_adj_close,change_pct\n'
    awk -v start_date=2024-02-23 -v end_date=2024-12-20 \
        -f "$project_dir/scripts/endpoint_returns.awk" "$clean_file" |
        sort -t, -k6,6nr -k1,1
} > "$output/endpoint_returns.csv"

printf 'Analysis files written to %s\n' "$output"
