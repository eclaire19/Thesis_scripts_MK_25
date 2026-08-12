#!/bin/bash
#SBATCH --partition=compute
#SBATCH --nodes=7
#SBATCH --cpus-per-task=16
#SBATCH --exclusive
#SBATCH --job-name=flye_batch
#SBATCH --mail-user=w22062555@northumbria.ac.uk     # your email address
#SBATCH --mail-type=BEGIN,END,FAIL  

# Ã°Å¸Å¡â‚¬ Start of Job
echo "=== SLURM job started on $(hostname) at $(date) ==="

# Activate environment if needed
# Example: conda activate flye_env

# --------- Configuration ---------
INPUT_DIR="."
OUTPUT_BASE_DIR="flye_results_all_samples"
THREADS=8
GENOME_SIZE="6m"
FILE_PATTERN="m84105_*.fastq"
# ---------------------------------

mkdir -p "$OUTPUT_BASE_DIR"

# Loop through matching input files
for file in "$INPUT_DIR"/$FILE_PATTERN; do
    [ -e "$file" ] || continue  # Skip if no files match

    # Extract sample name (remove .normalized_combined.fastq)
    filename=$(basename "$file")
    sample="${filename%.normalized_combined.fastq}"

    # Output directory for this sample
    sample_output_dir="$OUTPUT_BASE_DIR/$sample"
    mkdir -p "$sample_output_dir"

    echo "Ã°Å¸â€Â¬ Running Flye on: $filename"

    flye --pacbio-hifi "$file" \
         --genome-size "$GENOME_SIZE" \
         --out-dir "$sample_output_dir" \
         --threads "$THREADS" \
         --plasmids \
         > "$sample_output_dir/flye.log" 2>&1

    if [ $? -eq 0 ]; then
        echo "Ã¢Å“â€¦ Completed: $sample"
    else
        echo "Ã¢ÂÅ’ Failed: $sample (see $sample_output_dir/flye.log)"
    fi
done

echo "=== SLURM job completed at $(date) ==="



