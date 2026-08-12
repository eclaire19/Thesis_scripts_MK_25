#!/bin/bash
#SBATCH --partition=compute
#SBATCH --nodes=1
#SBATCH --job-name=homer_motif_scan

BED_DIR="/home/crk_w22062555/Fastqs_PacBio/combined_normalized_fastqs/renamed_fastqs/flye_results_all_samples/single_contig_fastas/genome_windows"
FASTA_DIR="/home/crk_w22062555/Fastqs_PacBio/combined_normalized_fastqs/renamed_fastqs/flye_results_all_samples/single_contig_fastas"
OUTPUT_BASE="homer_results"
MOTIFS_LIST="/home/crk_w22062555/methylation_pcf/motifs/motifs_lists.txt"
COMBINED_MOTIF="/home/crk_w22062555/methylation_pcf/motifs/combined.motifs"
TAG_DIR_BASE="/home/crk_w22062555/homer_tagdirs"

mkdir -p "$OUTPUT_BASE"
mkdir -p "$TAG_DIR_BASE"

# Combine motif files
if [[ ! -f "$MOTIFS_LIST" ]]; then
  echo "ERROR: motifs_list.txt not found at $MOTIFS_LIST"
  exit 1
fi

echo "Combining motif files listed in $MOTIFS_LIST"
cat $(cat "$MOTIFS_LIST") > "$COMBINED_MOTIF"
echo "Combined motif file created: $COMBINED_MOTIF"

# Process each BED/FASTA pair
for bed_file in "$BED_DIR"/*.bed; do
  sample_name=$(basename "$bed_file" .bed)
  sample_prefix="${sample_name/.genome_windows/}"
  fasta_file="$FASTA_DIR/${sample_prefix}.fasta"

  if [[ ! -f "$fasta_file" ]]; then
    echo "Skipping $sample_name: FASTA not found at $fasta_file"
    continue
  fi

  echo "Processing $sample_name"
  output_dir="$OUTPUT_BASE/$sample_prefix"
  mkdir -p "$output_dir"

  # Create tag directory if it doesn't already exist
  tag_dir="$TAG_DIR_BASE/$sample_prefix"
  if [[ ! -d "$tag_dir" ]]; then
    echo "Indexing genome FASTA with makeTagDirectory for $sample_prefix"
    makeTagDirectory "$tag_dir" -fasta "$fasta_file"
  fi

  # Run HOMER with -find
  echo "Running HOMER motif scan..."
  findMotifsGenome.pl "$bed_file" "$tag_dir" "$output_dir" -find "$COMBINED_MOTIF" > "$output_dir/homer.log" 2>&1

  echo " Done with $sample_name"
done

echo "🎉 All motif searches completed!"

