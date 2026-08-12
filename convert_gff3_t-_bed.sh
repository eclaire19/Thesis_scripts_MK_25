#!/bin/bash



BASEDIR="${1:-.}"

echo "Searching for GFF3 files in: $BASEDIR"

find "$BASEDIR" -type f -name "*.gff3" | while read -r GFF; do
    DIR=$(dirname "$GFF")
    BASENAME=$(basename "$GFF" .gff3)
    BED_FILE="${DIR}/${BASENAME}.genes.bed"
    SORTED_BED="${DIR}/${BASENAME}.genes.sorted.bed"

    echo "Processing: $GFF"

    # Extract gene or CDS features and convert to BED
    awk '$3 == "gene" || $3 == "CDS" {
        attr = $9
        match(attr, /ID=([^;]+)/, a); gid = (a[1] ? a[1] : "")
        match(attr, /Name=([^;]+)/, b); gname = (b[1] ? b[1] : gid)
        print $1, $4-1, $5, gname, 0, $7
    }' OFS="\t" "$GFF" > "$BED_FILE"

    # Sort the BED file
    sort -k1,1 -k2,2n "$BED_FILE" > "$SORTED_BED"

    echo "Created: $SORTED_BED"
done

echo "All GFF3 files processed successfully!"

