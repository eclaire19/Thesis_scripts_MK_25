#!/bin/bash
#SBATCH --partition=compute
#SBATCH --nodes=6
#SBATCH --exclusive
#SBATCH --job-name=plassembler_flye

# Path to Flye assemblies (.clean.fasta)
FLYE_ASSEMBLY_DIR="/home/crk_w22062555/Imperial_fastqs/plassembler_outputs/all_assemblies/cleaned_assemblies/clean_fasta_files"

# Path to corresponding FASTQ files
FASTQ_DIR="home/crk_w22062555/Imperial_fastqs/Imperial_fastqs/"

# Plassembler database path
DB_DIR="/home/crk_w22062555/database"

# Output directory for Plassembler results
OUTPUT_BASE="./plassembler_outputs"

# Parameters
CHROM_SIZE=5000000
THREADS=16

mkdir -p "$OUTPUT_BASE"

# Check that database exists
if [[ ! -d "$DB_DIR" ]]; then
  echo "Error: Database directory not found at $DB_DIR"
  exit 1
fi

echo " Flye assemblies directory: $FLYE_ASSEMBLY_DIR"
echo " FASTQ directory: $FASTQ_DIR"
echo " Output directory: $OUTPUT_BASE"


# Loop over all assemblies ending in .clean.fasta
for flye in "$FLYE_ASSEMBLY_DIR"/*.clean.fasta; do
  [[ -f "$flye" ]] || continue

  # Extract sample name (before .clean.fasta)
  sample=$(basename "$flye" .clean.fasta)
  echo "Processing sample: $sample"

  # Find matching FASTQ file by sample name
  fastq=$(find "$FASTQ_DIR" -maxdepth 1 -type f -name "${sample}*.fastq*" | head -n1)
  if [[ -z "$fastq" ]]; then
    echo " No matching FASTQ found for $sample — skipping."
    continue
  fi

  # Prepare output directory
  outdir="$OUTPUT_BASE/$sample"
  mkdir -p "$outdir"

  # Skip if already processed
  if [[ -f "$outdir/plassembler_summary.tsv" ]]; then
    echo "Already processed ($outdir/plassembler_summary.tsv found). Skipping."
   continue
  fi

  # Count contigs
  contigs=$(grep -c '^>' "$flye")
  if (( contigs <= 1 )); then
    echo "Only $contigs contig(s) in assembly — skipping."
    continue
  fi

  # Run Plassembler
  echo "Running Plassembler for $sample..."
  if plassembler long \
      -d "$DB_DIR" \
      -l "$fastq" \
      -o "$outdir" \
      -c "$CHROM_SIZE" \
      --flye_assembly "$flye" \
      -t "$THREADS" \
      -f; then
    echo "Plassembler finished for $sample"
  else
    echo "Plassembler failed for $sample (see logs in $outdir)"
  fi
done

echo " All available Flye assemblies processed."

