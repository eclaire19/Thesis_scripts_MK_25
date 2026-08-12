#!/bin/bash

# Base directory (set to where all your motif directories are)
BASE_DIR="."

# Loop over all fimo.tsv files under fimo_out folders
find "$BASE_DIR" -type f -path "*/fimo_out/fimo.tsv" | while read -r fimo_file; do
    dir=$(dirname "$fimo_file")
    echo "Processing: $fimo_file"

    # Convert to motifs.bed using awk
    awk 'BEGIN {OFS="\t"} NR>1 {print $3, $4-1, $5, $1, $7, $6}' "$fimo_file" > "$dir/motifs.bed"

    echo "Saved BED file to: $dir/motifs.bed"
done

