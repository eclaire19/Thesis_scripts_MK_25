#!/bin/bash


set -euo pipefail

# Base directory (default is current directory)
BASEDIR="${1:-.}"

echo "Searching for fimo.tsv files under: $BASEDIR"

# Find all fimo.tsv files recursively
find "$BASEDIR" -type f -name "fimo.tsv" | while read -r FIMO_TSV; do
    DIR=$(dirname "$FIMO_TSV")
    OUTPUT_BED="$DIR/fimo.sorted.bed"

    echo "📂 Processing $FIMO_TSV in $DIR"

    awk -F'\t' 'BEGIN{OFS="\t"}
    /^#/ {next}         # skip comment lines
    /^$/ {next}         # skip empty lines
    NR==1 {next}        # skip header line
    {
        chrom = $3
        start = $4 - 1
        end = $5
        name = $1 ":" chrom ":" $4 "-" $5
        score = $7
        strand = $6
        print chrom, start, end, name, score, strand
    }' "$FIMO_TSV" | sort -k1,1 -k2,2n > "$OUTPUT_BED"

    echo "Created BED: $OUTPUT_BED"
done

echo "All FIMO TSV files processed!"

