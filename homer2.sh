#!/bin/bash
#SBATCH --job-name=homer_motif_scan



FASTA_DIR="/home/crk_w22062555/Fastqs_PacBio/combined_normalized_fastqs/renamed_fastqs/flye_results_all_samples/single_contig_fastas"
WINDOWS_DIR="${FASTA_DIR}/genome_windows"
OUTPUT_DIR="/home/crk_w22062555/methylation_pcf/homer_results"
MOTIF_FILE="/home/crk_w22062555/methylation_pcf/test_motifs.motif"

mkdir -p "$OUTPUT_DIR"

for sample_fasta in "$FASTA_DIR"/*.fasta; do
    sample_base=$(basename "$sample_fasta" .fasta)
    bed_file="${WINDOWS_DIR}/${sample_base}.genome_windows.bed"
    sample_output="${OUTPUT_DIR}/${sample_base}"
    mkdir -p "$sample_output"

    echo "Running HOMER for $sample_base"

    findMotifsGenome.pl "$bed_file" "$sample_fasta" "$sample_output" -find "$MOTIF_FILE"

    echo "Done with $sample_base"
done

echo "All samples processed!"

