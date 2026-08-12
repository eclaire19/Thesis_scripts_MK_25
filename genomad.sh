#!/bin/bash
#SBATCH --job-name=genomad_batch
#SBATCH --partition=compute
#SBATCH --cpus-per-task=8
#SBATCH --nodes=2
#SBATCH --mail-user=w22062555@northumbria.ac.uk
#SBATCH --mail-type=END


# Set your database path
DB_PATH="/home/crk_w22062555/genomad_db"

# Input and output directories
INPUT_DIR="."
OUTPUT_DIR="./genomad_outputs"

# Create output dir if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Loop over each .fna file in the input directory
for fasta in "$INPUT_DIR"/*.fasta; do
    # Get base name (without path or extension)
    base=$(basename "$fasta" .fasta)
    
    echo "Processing $base..."
    
    # Create a subdirectory for this output
    out_dir="$OUTPUT_DIR/${base}_genomad"
    mkdir -p "$out_dir"
    
    # Run Genomad
    genomad end-to-end \
        --cleanup \
        --splits 8 \
        --conservative \
        "$fasta" \
        "$out_dir" \
        "$DB_PATH"
done

echo "All jobs completed."

