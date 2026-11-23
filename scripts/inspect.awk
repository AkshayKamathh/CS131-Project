BEGIN { FS = "," }

# Remove the trailing carriage return from Windows-style line endings.
{ sub(/\r$/, "", $0) }

NR == 1 {
    print "Header:", $0
    print "Header fields:", NF
    for (i = 1; i <= NF; i++)
        column[i] = $i
    next
}

{
    records++

    if (NF != 8) {
        wrong_width++
        printf "Line %d: expected 8 fields, found %d\n", NR, NF
        next
    }

    for (i = 1; i <= NF; i++) {
        if ($i ~ /^[[:space:]]*$/) {
            blanks++
            printf "Line %d (%s): blank %s\n", NR, $2, column[i]
        }
    }
}

END {
    print "Data records:", records + 0
    print "Rows with a field count other than 8:", wrong_width + 0
    print "Blank fields in eight-field records:", blanks + 0
}

NR > 1 && NF == 8 {
    if ($1 != "" && $1 !~ /^[0-9][0-9]?\/[0-9][0-9]?\/[0-9][0-9]$/)
        printf "Line %d (%s): unexpected date format %s\n", NR, $2, $1

    for (i = 3; i <= 7; i++) {
        if ($i ~ /^[+-]?[0-9]+([.][0-9]+)?$/ && $i + 0 <= 0)
            printf "Line %d (%s): nonpositive %s %s\n", NR, $2, column[i], $i
    }

    if ($5 ~ /^[0-9]+([.][0-9]+)?$/ &&
        $6 ~ /^[0-9]+([.][0-9]+)?$/ &&
        $7 ~ /^[0-9]+([.][0-9]+)?$/ &&
        ($7 + 0 < $6 + 0 - 0.0000001 || $7 + 0 > $5 + 0 + 0.0000001))
        printf "Line %d (%s): Open %s outside Low-High [%s, %s]\n",
            NR, $2, $7, $6, $5
}
