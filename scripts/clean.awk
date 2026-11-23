# Convert a valid M/D/YY date to YYYY-MM-DD.
# The fixed cutoff maps 00–69 to 2000–2069 and 70–99 to 1970–1999.
function iso_date(value,    parts, month, day, year, days) {
    if (value !~ /^[0-9][0-9]?\/[0-9][0-9]?\/[0-9][0-9]$/)
        return ""

    split(value, parts, "/")
    month = parts[1] + 0
    day = parts[2] + 0
    year = parts[3] + 0
    year += (year <= 69 ? 2000 : 1900)

    if (month < 1 || month > 12)
        return ""

    days = 31
    if (month == 4 || month == 6 || month == 9 || month == 11)
        days = 30
    if (month == 2)
        days = 28 + ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0)

    if (day < 1 || day > days)
        return ""

    return sprintf("%04d-%02d-%02d", year, month, day)
}

BEGIN {
    FS = OFS = ","
    expected_header = "Date,Symbol,Adj Close,Close,High,Low,Open,Volume"
}

# Strip the carriage return before comparing or splitting fields.
{ sub(/\r$/, "", $0) }

NR == 1 {
    if ($0 != expected_header) {
        print "ERROR: unexpected CSV header" > "/dev/stderr"
        exit 2
    }
    print "line\tsymbol\tissue\tvalue" > error_log
    print
    next
}

{
    if (NF != 8) {
        printf "%d\t-\tFIELD_COUNT\t%d\n", NR, NF > error_log
        next
    }

    normalized_date = iso_date($1)
    if (normalized_date == "") {
        printf "%d\t%s\tINVALID_DATE\t%s\n", NR, $2, $1 > error_log
        next
    }

    bad = 0
    split("Date,Symbol,Adj Close,Close,High,Low,Open,Volume", names, ",")

    for (i = 2; i <= 8; i++) {
        valid[i] = 0
        if ($i ~ /^[[:space:]]*$/) {
            printf "%d\t%s\tMISSING_VALUE\t%s\n", NR, $2, names[i] > error_log
            bad = 1
        } else if ((i == 2 && $i !~ /^[A-Z][A-Z0-9.-]*$/) ||
                   (i >= 3 && i <= 7 &&
                    ($i !~ /^[0-9]+([.][0-9]+)?$/ || $i + 0 <= 0)) ||
                   (i == 8 && $i !~ /^[0-9]+([.]0+)?$/)) {
            printf "%d\t%s\tINVALID_VALUE\t%s=%s\n", NR, $2, names[i], $i > error_log
            bad = 1
        } else {
            valid[i] = 1
        }
    }

    epsilon = 0.0000001
    if (valid[5] && valid[6] &&
        ($6 + 0 > $5 + epsilon ||
         (valid[4] && ($4 + 0 < $6 - epsilon || $4 + 0 > $5 + epsilon)) ||
         (valid[7] && ($7 + 0 < $6 - epsilon || $7 + 0 > $5 + epsilon)))) {
        printf "%d\t%s\tOHLC_ORDER\tHigh=%s Low=%s Open=%s Close=%s\n",
            NR, $2, $5, $6, $7, $4 > error_log
        bad = 1
    }

    if (bad)
        next

    # The original CSV confirms this ticker on this date.
    if (normalized_date == "2024-12-19" && $2 == "AMZNN") {
        printf "%d\t%s\tSYMBOL_CORRECTED\tAMZNN -> AMZN\n", NR, $2 > error_log
        $2 = "AMZN"
    }

    $1 = normalized_date
    print
}

END {
    if (NR == 0) {
        print "ERROR: input CSV is empty" > "/dev/stderr"
        exit 2
    }
}
