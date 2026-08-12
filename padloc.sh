#!/bin/bash
#SBATCH --job-name=padloc_batch
#SBATCH --partition=compute

# Activate conda environment with PADLOC installed

# Paths
INPUT_DIR="."
OUTPUT_DIR="./padloc_results"

mkdir -p $OUTPUT_DIR

# Loop through each genome
for fna in $INPUT_DIR/*.fna; do
    base=$(basename "$fna" .fna)
    echo "Running PADLOC on $base"

    padloc --fna "$fna" --outdir "$OUTPUT_DIR"
done

# Optional: merge all PADLOC TSV results into one summary table
cat $OUTPUT_DIR/*/*.tsv > $OUTPUT_DIR/padloc_summary_all.tsv

