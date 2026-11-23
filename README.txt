CS 131 Final Project | Data Alchemists
Team: Akshay K, Yogi C, Tomo S, Phu H

Requirements: Bash, awk, sort, and standard Unix utilities.
Run from the project directory:

    bash analyze.sh "/path/to/instructor/prices.csv" results

Use the instructor's altered CSV. The second argument must name a new
directory. For another run, use a different name such as results-rerun.

Project files:
  analyze.sh       Runs cleaning and generates both analysis reports.
  clean_prices.sh  Validates input, resolves duplicate keys, and checks counts.
  scripts/         AWK inspection, cleaning, and analysis programs.
  docs/            Supporting documentation and test evidence.

Generated files:
  validated.csv         Rows that passed field and date validation.
  prices.csv            Clean records after duplicate handling.
  cleaning.tsv          Validation errors and ticker corrections.
  duplicates.tsv        Duplicate and conflicting-key actions.
  summary.txt           Counts of input, rejected, removed, and retained rows.
  monthly.csv           Monthly coverage, total volume, and mean daily volume.
  endpoint_returns.csv  Adjusted-close changes for tickers with prices on both
                        February 23 and December 20, 2024.

The endpoint ranking describes a subset of the dataset. Monthly mean
daily volume uses the number of observed dates in each month.

Keep the raw CSV local. Exclude the raw CSV, validated.csv, and prices.csv
from the submission ZIP. Include the generated summaries and logs.
