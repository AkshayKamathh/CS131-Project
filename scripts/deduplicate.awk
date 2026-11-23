BEGIN {
    FS = ","
    print "date\tsymbol\taction\trows_removed" > duplicate_log
}

NR == 1 { print; next }

{
    key = $1 SUBSEP $2

    if (!(key in first_row)) {
        first_row[key] = $0
        keys[++key_count] = key
    } else if ($0 != first_row[key]) {
        conflict[key] = 1
    }

    count[key]++
}

END {
    for (i = 1; i <= key_count; i++) {
        key = keys[i]
        split(key, fields, SUBSEP)

        if (conflict[key]) {
            printf "%s\t%s\tCONFLICT_QUARANTINED\t%d\n",
                fields[1], fields[2], count[key] > duplicate_log
        } else {
            print first_row[key]
            if (count[key] > 1)
                printf "%s\t%s\tDUPLICATES_REMOVED\t%d\n",
                    fields[1], fields[2], count[key] - 1 > duplicate_log
        }
    }
}
