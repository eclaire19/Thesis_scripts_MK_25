#!/bin/bash
#SBATCH --partition=compute

# Base output directory for CheckM2 results
mkdir -p checkm2_results

# Loop over all FASTA files in the current directory
for fasta_file in *.fasta; do
    # Skip if no FASTA files are found
    [[ -e "$fasta_file" ]] || { echo "No FASTA files found."; exit 1; }

    # Sample name without extension
    sample_name="${fasta_file%.fasta}"

    echo "Running CheckM2 on $fasta_file"

    # Create sample-specific output folder
    sample_output="checkm2_results/${sample_name}"
    mkdir -p "$sample_output"

    # Run CheckM2
    checkm2 predict -i "$fasta_file" -o "$sample_output" --force
done

