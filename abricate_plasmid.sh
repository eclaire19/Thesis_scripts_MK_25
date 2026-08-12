#!/bin/bash
#SBATCH --job-name=abricate_individual
#SBATCH --ntasks=1
#SBATCH --output=abricate_loop_%j.out

# 1. Load the ABRicate module (or activate your environment)
module load abricate

# 2. Set up directory paths
# Assumes you are running this from the folder containing your individual .fasta files
FASTA_DIR="."
TMP_OUT_DIR="./abricate_individual_results"

mkdir -p "$TMP_OUT_DIR"

echo "Starting individual ABRicate screening loops..."
echo "------------------------------------------------"

# 3. Loop through each individual FASTA file
for fasta in "${FASTA_DIR}"/*.fasta; do
    # Skip if no fasta files are found
    [ -e "$fasta" ] || continue
    
    # Extract the base name without path or .fasta extension
    sample=$(basename "$fasta" .fasta)
    
    echo "Screening sample: $sample"
    
    # Run each database independently for this specific sample
    abricate --db ncbi "$fasta" > "${TMP_OUT_DIR}/${sample}_ncbi.txt"
    abricate --db card "$fasta" > "${TMP_OUT_DIR}/${sample}_card.txt"
    abricate --db vfdb "$fasta" > "${TMP_OUT_DIR}/${sample}_vfdb.txt"
    abricate --db plasmidfinder "$fasta" > "${TMP_OUT_DIR}/${sample}_plasmidfinder.txt"
done

echo "------------------------------------------------"
echo "Individual screenings complete. Merging outputs cleanly..."

# 4. Clean concatenation (keeping only ONE header row at the top)

# Merge NCBI
head -n 1 $(ls "${TMP_OUT_DIR}"/*_ncbi.txt | head -n 1) > ./master_plasmids_ncbi.txt
tail -n +2 -q "${TMP_OUT_DIR}"/*_ncbi.txt >> ./master_plasmids_ncbi.txt

# Merge CARD
head -n 1 $(ls "${TMP_OUT_DIR}"/*_card.txt | head -n 1) > ./master_plasmids_card.txt
tail -n +2 -q "${TMP_OUT_DIR}"/*_card.txt >> ./master_plasmids_card.txt

# Merge VFDB
head -n 1 $(ls "${TMP_OUT_DIR}"/*_vfdb.txt | head -n 1) > ./master_plasmids_vfdb.txt
tail -n +2 -q "${TMP_OUT_DIR}"/*_vfdb.txt >> ./master_plasmids_vfdb.txt

# Merge PlasmidFinder
head -n 1 $(ls "${TMP_OUT_DIR}"/*_plasmidfinder.txt | head -n 1) > ./master_plasmids_plasmidfinder.txt
tail -n +2 -q "${TMP_OUT_DIR}"/*_plasmidfinder.txt >> ./master_plasmids_plasmidfinder.txt

echo "------------------------------------------------"
echo "Process finished successfully!"
echo "Master files generated in your current directory:"
echo " - master_plasmids_ncbi.txt"
echo " - master_plasmids_card.txt"
echo " - master_plasmids_vfdb.txt"
echo " - master_plasmids_plasmidfinder.txt"