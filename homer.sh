#!/bin/bash
#SBATCH --partition=compute
#SBATCH --nodes=4

SAMPLE_DIR="/home/crk_w22062555/Fastqs_PacBio/combined_normalized_fastqs/renamed_fastqs/flye_results_all_samples/single_contig_fastas"          # Directory with genome FASTA files
MOTIFS="test_motifs.motif"  # Motif file
OUTPUT_DIR="homer_results"          # Directory to store results

mkdir -p "$OUTPUT_DIR"

for SAMPLE in "$SAMPLE_DIR"/*.fasta; do
    BASENAME=$(basename "$SAMPLE" .fasta)
    OUTDIR="$OUTPUT_DIR/$BASENAME"
    mkdir -p "$OUTDIR"
    
    echo "Scanning $SAMPLE using its own genome as reference..."
    
    # Scan motifs using the sample itself as reference
    findMotifsGenome.pl "$SAMPLE" "$SAMPLE" "$OUTDIR" -find "$MOTIFS"
done

echo "All samples processed."

