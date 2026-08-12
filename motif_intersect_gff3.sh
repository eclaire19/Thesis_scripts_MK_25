#!/bin/bash

# -----------------------------
# CONFIGURE:
SAMPLES_DIR="."     # folder containing all sample subfolders
OUTDIR="motif_intersect_results"
PROMOTER_LEN=300          # length of upstream promoter region
# -----------------------------

mkdir -p "$OUTDIR"

# Loop over sample folders
for sample_folder in "$SAMPLES_DIR"/*; do
    [ -d "$sample_folder" ] || continue

    sample=$(basename "$sample_folder")
    echo "========================================"
    echo "Processing sample: $sample"

    # Find GFF3 file
    GFF=$(find "$sample_folder" -maxdepth 1 -type f -name "*.gff3" | head -n1)
    if [[ -z "$GFF" ]]; then
        echo "❌ No GFF3 file found in $sample_folder — skipping"
        continue
    fi

    # Find FIMO TSV file
    FIMO=$(find "$sample_folder/fimo_out" -type f -name "fimo.tsv" | head -n1)
    if [[ -z "$FIMO" ]]; then
        echo "❌ No fimo.tsv found in $sample_folder/fimo_out — skipping"
        continue
    fi

    # Create output folder for this sample
    SAMPLE_OUT="$OUTDIR/$sample"
    mkdir -p "$SAMPLE_OUT"

    echo "✔ Found GFF3: $GFF"
    echo "✔ Found FIMO TSV: $FIMO"

    # ---------------------------------
    # Convert FIMO to BED (integer, tab-delimited, skip comments)
    # ---------------------------------
    awk 'BEGIN{OFS="\t"} NR>1 && $0 !~ /^#/ {
        start=int($4)-1; end=int($5);
        print $3, start, end, $1, $7, $6
    }' "$FIMO" | awk 'BEGIN{OFS="\t"} {$1=$1; print}' > "$SAMPLE_OUT/fimo.bed"

    # ---------------------------------
    # Convert GFF3 to BED (genes, CDS, promoters)
    # ---------------------------------
    # Genes
    awk -v OFS="\t" '$3=="gene"{print $1,int($4)-1,int($5),$9,".",$7}' "$GFF" \
        | awk 'BEGIN{OFS="\t"} {$1=$1; print}' > "$SAMPLE_OUT/genes.bed"

    # CDS
    awk -v OFS="\t" '$3=="CDS"{print $1,int($4)-1,int($5),$9,".",$7}' "$GFF" \
        | awk 'BEGIN{OFS="\t"} {$1=$1; print}' > "$SAMPLE_OUT/cds.bed"

    # Promoters
    awk -v OFS="\t" -v L="$PROMOTER_LEN" '$3=="gene"{
        if($7=="+"){start=int($4)-L-1; end=int($4)-1} else {start=int($5)+1; end=int($5)+L}
        if(start<0){start=0}
        print $1,start,end,$9,".",$7
    }' "$GFF" | awk 'BEGIN{OFS="\t"} {$1=$1; print}' > "$SAMPLE_OUT/promoters_${PROMOTER_LEN}bp.bed"

    # ---------------------------------
    # BEDTools intersections
    # ---------------------------------
    bedtools intersect -wa -wb -a "$SAMPLE_OUT/fimo.bed" -b "$SAMPLE_OUT/genes.bed" \
        > "$SAMPLE_OUT/motifs_in_genes.tsv"

    bedtools intersect -wa -wb -a "$SAMPLE_OUT/fimo.bed" -b "$SAMPLE_OUT/cds.bed" \
        > "$SAMPLE_OUT/motifs_in_cds.tsv"

    bedtools intersect -wa -wb -a "$SAMPLE_OUT/fimo.bed" -b "$SAMPLE_OUT/promoters_${PROMOTER_LEN}bp.bed" \
        > "$SAMPLE_OUT/motifs_in_promoters.tsv"

    # Combined annotation
    bedtools intersect -wa -wb -a "$SAMPLE_OUT/fimo.bed" -b "$SAMPLE_OUT/genes.bed" "$SAMPLE_OUT/cds.bed" "$SAMPLE_OUT/promoters_${PROMOTER_LEN}bp.bed" \
        > "$SAMPLE_OUT/motifs_annotated_all.tsv"

    # ---------------------------------
    # Summary counts
    # ---------------------------------
    echo "Motifs in genes:" > "$SAMPLE_OUT/summary.txt"
    wc -l < "$SAMPLE_OUT/motifs_in_genes.tsv" >> "$SAMPLE_OUT/summary.txt"

    echo "Motifs in CDS:" >> "$SAMPLE_OUT/summary.txt"
    wc -l < "$SAMPLE_OUT/motifs_in_cds.tsv" >> "$SAMPLE_OUT/summary.txt"

    echo "Motifs in promoters (${PROMOTER_LEN} bp):" >> "$SAMPLE_OUT/summary.txt"
    wc -l < "$SAMPLE_OUT/motifs_in_promoters.tsv" >> "$SAMPLE_OUT/summary.txt"

    echo "✔ Finished processing $sample"
    echo
done

echo "========================================"
echo "All samples processed. Results in: $OUTDIR"
