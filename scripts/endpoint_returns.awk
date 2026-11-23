BEGIN { FS = "," }

NR == 1 { next }

$1 == start_date { first_price[$2] = $3 + 0 }
$1 == end_date   { last_price[$2] = $3 + 0 }

END {
    if (NR < 2) {
        print "ERROR: expected cleaned price records" > "/dev/stderr"
        exit 2
    }

    for (symbol in first_price) {
        if (symbol in last_price) {
            change = 100 * (last_price[symbol] / first_price[symbol] - 1)
            printf "%s,%s,%s,%.10g,%.10g,%.6f\n",
                symbol, start_date, end_date,
                first_price[symbol], last_price[symbol], change
            eligible++
        }
    }

    if (!eligible) {
        print "ERROR: no tickers have prices on both endpoints" > "/dev/stderr"
        exit 2
    }
}
