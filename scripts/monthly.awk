BEGIN { FS = "," }

NR == 1 { next }

{
    month = substr($1, 1, 7)
    records[month]++
    volume[month] += $8

    if (!($1 in seen_date)) {
        seen_date[$1] = 1
        days[month]++
    }
}

END {
    for (month in records) {
        printf "%s,%d,%d,%.0f,%.2f\n",
            month, records[month], days[month], volume[month],
            volume[month] / days[month]
    }
}
