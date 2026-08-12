#!/bin/bash
#SBATCH --job-name=amrfinder_batch           # Adjust to your cluster's partition names
#SBATCH --nodes=1


# 2. Define Directories
INPUT_DIR="."
OUTPUT_DIR="./amr_results"
mkdir -p $OUTPUT_DIR

# 3. Run the loop
# This processes all .fasta files in the input directory
for fasta in ${INPUT_DIR}/*.fasta; do
    
    # Get the filename without the path or extension
    sample_name=$(basename "$fasta" .fasta)
    
    echo "Processing sample: ${sample_name}"

    # 4. Run AMRFinderPlus
    # -O Pseudomonas_aeruginosa enables SNP/Point Mutation detection
    # --plus searches for virulence and biocide resistance
    # --threads 8 speeds up the process using the allocated CPUs
    amrfinder -n "$fasta" \
              -O Pseudomonas_aeruginosa \
              --plus \
              --threads 8 \
              -o "${OUTPUT_DIR}/${sample_name}_amr_results.tsv"

done

echo "Workflow complete at $(date)"
