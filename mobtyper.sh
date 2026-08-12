#!/bin/bash
#SBATCH --job-name=mobtyper_batch
#SBATCH --output=mobtyper_run_%j.out

# 1. Load the MOB-suite module (or activate its conda environment)

# or: conda activate mob_suite_env

# 2. Set up directory paths
FASTA_DIR="."
TMP_OUT_DIR="./mobtyper_individual_results"

mkdir -p "$TMP_OUT_DIR"

echo "Starting individual MOB-typer runs..."
echo "------------------------------------------------"

# 3. Loop through each individual FASTA file
for fasta in "${FASTA_DIR}"/*.fasta; do
    # Skip if no fasta files match
    [ -e "$fasta" ] || continue
    
    # Extract the base name for the output file
    sample=$(basename "$fasta" .fasta)
    
    echo "Typing sample: $sample"
    
    # Run mob_typer on the individual fasta file
    # --infile: input plasmid FASTA
    # --out_file: path to save this sample's tab-separated report
    mob_typer --infile "$fasta" --out_file "${TMP_OUT_DIR}/${sample}_mobtyper.txt"
done

echo "------------------------------------------------"
echo "Individual typing complete. Merging outputs cleanly..."

# 4. Clean concatenation (keeping only ONE header row at the top)
# Grabs the header from the first report, then appends rows starting from line 2 from all reports
head -n 1 $(ls "${TMP_OUT_DIR}"/*_mobtyper.txt | head -n 1) > ./master_plasmids_mobtyper.txt
tail -n +2 -q "${TMP_OUT_DIR}"/*_mobtyper.txt >> ./master_plasmids_mobtyper.txt

echo "------------------------------------------------"
echo "Process finished successfully!"
echo "Master report generated: ./master_plasmids_mobtyper.txt"