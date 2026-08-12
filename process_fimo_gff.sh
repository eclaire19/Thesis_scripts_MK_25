#!/bin/bash
# ==========================================================
# Script: process_fimo_gff.sh
# Purpose: For each subdirectory, convert FIMO TSV to BED,
#          extract CDS/gene features from GFF3, and intersect.
# Usage: bash process_fimo_gff.sh /path/to/main_directory
# ==========================================================


BASEDIR="${1:-.}"

echo "🔍 Processing directories under: $BASEDIR"

# Loop through all directories containing fimo.tsv
find "$BASEDIR" -type f -name "fimo.tsv" | while read -r FIMO_FILE; do
    DIR=$(dirname "$FIMO_FILE")
    echo "📂 Processing directory: $DIR"

    # --- Step 1: Convert FIMO TSV to BED ---
    FIMO_BED="$DIR/fimo.sorted.bed"
    awk 'BEGIN{OFS="\t"} NR>1 {
        chrom=$3
        start=$4-1
        end=$5
        name=$1":"$3":"$4"-"$5
        score=$7
        strand=$6
        print chrom, start, end, name, score, strand
    }' "$FIMO_FILE" | sort -k1,1 -k2,2n > "$FIMO_BED"
    echo "✅ Created FIMO BED: $FIMO_BED"

    # --- Step 2: Find a GFF3 file in the same directory ---
    GFF_FILE=$(find "$DIR" -maxdepth 1 -type f -name "*.gff3" | head -n 1)
    if [[ -z "$GFF_FILE" ]]; then
        echo "⚠️ No GFF3 file found in $DIR — skipping intersection."
        continue
    fi

    # --- Step 3: Extract CDS/gene features to BED ---
    GENES_BED="$DIR/genes.sorted.bed"
    awk '$3=="gene" || $3=="CDS" {
        attr=$9
        match(attr, /ID=([^;]+)/, a); gid=(a[1]?a[1]:"")
        match(attr, /Name=([^;]+)/, b); gname=(b[1]?b[1]:gid)
        print $1, $4-1, $5, gname, 0, $7
    }' OFS="\t" "$GFF_FILE" | sort -k1,1 -k2,2n > "$GENES_BED"
    echo "✅ Created genes BED: $GENES_BED"

    # --- Step 4: Intersect FIMO BED with genes BED ---
    OUTPUT="$DIR/fimo_in_genes.tsv"
    bedtools intersect -a "$FIMO_BED" -b "$GENES_BED" -wa -wb > "$OUTPUT"
    echo "✅ Intersection complete: $OUTPUT"
done

echo "🎉 All directories processed!"

