#!/bin/bash

# Set number of threads
THREADS=4

# Directory where all BAM files are located
BAM_DIR="."  # <-- set your BAM directory here

# Output base directory for reports
OUT_BASE_DIR="./output_reports"  # <-- set your desired output directory here

mkdir -p "$OUT_BASE_DIR"

# Loop over all BAM files in BAM_DIR
for bam_file in "$BAM_DIR"/*.bam; do
    # Check if any BAM files exist
    [ -e "$bam_file" ] || { echo "No BAM files found in $BAM_DIR"; exit 1; }

    # Extract basename without extension for sample name
    sample_name=$(basename "$bam_file" .bam)

    echo "Processing sample: $sample_name"

    # Define output directory per sample
    outdir="${OUT_BASE_DIR}/${sample_name}_qualimap_qc"

    mkdir -p "$outdir"

    # Run Qualimap
    qualimap bamqc -bam "$bam_file" -outdir "$outdir" -outformat PDF:HTML -nt "$THREADS"
    echo "  Qualimap QC complete: $outdir"
done

echo "All samples processed."

