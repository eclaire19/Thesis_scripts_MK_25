#!/bin/bash


BASEDIR="${1:-.}"

echo "🔍 Searching for directories containing fimo.sorted.bed and genes.sorted.bed under: $BASEDIR"

# Recursively loop through all directories
find "$BASEDIR" -type f -name "fimo.sorted.bed" | while read -r FIMO_FILE; do
    DIR=$(dirname "$FIMO_FILE")

    # Look for the genes.sorted.bed file in the same directory
    GENES_FILE=$(find "$DIR" -maxdepth 1 -type f -name "*genes.sorted.bed" | head -n 1)

    if [[ -n "$GENES_FILE" ]]; then
        OUTPUT="${DIR}/fimo_in_genes.tsv"

        echo "📂 Processing directory: $DIR"
        echo "   ➜ FIMO file:   $(basename "$FIMO_FILE")"
        echo "   ➜ Genes file:  $(basename "$GENES_FILE")"
        echo "   ➜ Output file: $(basename "$OUTPUT")"

        # Run bedtools intersect
        bedtools intersect -a "$FIMO_FILE" -b "$GENES_FILE" -wa -wb > "$OUTPUT"

        echo "Created: $OUTPUT"
    else
        echo " No genes.sorted.bed file found in: $DIR — skipping."
    fi
done

echo "Intersection complete for all matching directories!"

