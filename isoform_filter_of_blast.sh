#!/bin/bash

# Usage:
# ./filter_blast.sh -file blast.tsv -col 1 -priority length|evalue|composite -mode group|all

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -file) FILE="$2"; shift ;;
        -col) COL="$2"; shift ;;
        -priority) PRIORITY="$2"; shift ;;
        -mode) MODE="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

if [[ -z "$FILE" || -z "$COL" || -z "$PRIORITY" || -z "$MODE" ]]; then
    echo "Usage: $0 -file blast.tsv -col <column_number_of_qseqid> -priority <length|evalue|composite> -mode <group|all>"
    exit 1
fi

# Get basename of input file without extension
BASE=$(basename "$FILE")
OUTPUT="isoform_${BASE%.*}.tsv"

awk -v col="$COL" -v priority="$PRIORITY" -v mode="$MODE" '
function basename(id) {
    sub(/_[0-9]+$/, "", id)
    return id
}

BEGIN { FS=OFS="\t" }

{
    key = $col

    if (mode == "group") {
        group = basename(key)
    } else if (mode == "all") {
        group = key
    } else {
        print "Invalid mode: " mode > "/dev/stderr"
        exit 1
    }

    len1 = $4 + 0
    pid1 = $3 + 0
    eval1 = $11 + 0
    score1 = len1 * (pid1 / 100)  # composite score

    if (!(group in best)) {
        best[group] = $0
        scores[group] = score1
    } else {
        split(best[group], b)
        len2 = b[4] + 0
        pid2 = b[3] + 0
        eval2 = b[11] + 0
        score2 = scores[group]

        if (priority == "length") {
            if (len1 > len2 ||
               (len1 == len2 && pid1 > pid2) ||
               (len1 == len2 && pid1 == pid2 && eval1 < eval2)) {
                best[group] = $0
                scores[group] = score1
            }
        } else if (priority == "evalue") {
            if (eval1 < eval2 ||
               (eval1 == eval2 && pid1 > pid2) ||
               (eval1 == eval2 && pid1 == pid2 && len1 > len2)) {
                best[group] = $0
                scores[group] = score1
            }
        } else if (priority == "composite") {
            if (score1 > score2) {
                best[group] = $0
                scores[group] = score1
            }
        } else {
            print "Invalid priority: " priority > "/dev/stderr"
            exit 1
        }
    }
}

END {
    for (k in best) {
        print best[k]
    }
}
' "$FILE" > "$OUTPUT"

echo "✔ Output saved in: $OUTPUT"
