# CS 131 Final Project | Data Alchemists

Akshay K, Yogi C, Tomo S, and Phu H

This project uses Bash and awk to clean the instructor's altered stock-price
CSV, summarize monthly trading volume, and rank adjusted-close changes
over a shared date window.

## Run the pipeline

From the project directory, using Bash and standard Unix tools:

    bash analyze.sh "/path/to/instructor/prices.csv" results

Choose a new output directory for each run. Keep the instructor CSV local.
See README.txt for output descriptions and docs/test-results.txt for the
checks run on macOS.

## Verified results

The instructor file contained 36,056 data rows. The pipeline rejected four
rows and retained 36,052. It corrected one ticker and found zero duplicate
or conflicting date/ticker keys.

The monthly summary covers 11 observed months, including partial months
in February and December. The adjusted-close ranking covers 131 tickers
with a price on both February 23 and December 20, 2024.

A fresh clone of commit 9a71d8e reproduced both reports byte for byte.
