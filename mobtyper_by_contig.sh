#!/bin/bash
#SBATCH --job-name=mobtyper_per_contig
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2


FASTA_DIR="."
TMP_SPLIT_DIR="./tmp_split_contigs"
TMP_OUT_DIR="./mobtyper_individual_results"

mkdir -p "$TMP_SPLIT_DIR"
mkdir -p "$TMP_OUT_DIR"

echo "Splitting multi-FASTAs and running MOB-typer per contig..."
echo "--------------------------------------------------------"

# 1. Loop through your multi-FASTA files
for fasta in "${FASTA_DIR}"/*.fasta; do
    [ -e "$fasta" ] || continue
    sample=$(basename "$fasta" .fasta)
    
    # 2. Use awk to split the multi-FASTA into individual contigs inside the temp folder
    # Named like: tmp_split_contigs/sample_IMP_01_contig_1.fasta
    awk -v prefix="$TMP_SPLIT_DIR/${sample}" '/^>/{
        # Extract the contig name, removing the ">" symbol and any spaces
        match($0, />([^ ]+)/, arr);
        contig_name = arr[1];
        f = prefix "_" contig_name ".fasta"
    } 
    { print > f }' "$fasta"
done

# 3. Now loop through every single individual contig FASTA file we just created
for contig_fasta in "${TMP_SPLIT_DIR}"/*.fasta; do
    [ -e "$contig_fasta" ] || continue
    contig_base=$(basename "$contig_fasta" .fasta)
    
    echo "Processing separate contig: $contig_base"
    
    # Run mob_typer strictly on this single contig
    mob_typer --infile "$contig_fasta" --out_file "${TMP_OUT_DIR}/${contig_base}_mobtyper.txt"
done

echo "--------------------------------------------------------"
echo "Merging individual contig profiles cleanly..."

# 4. Concatenate all individual contig reports keeping only ONE header row
head -n 1 $(ls "${TMP_OUT_DIR}"/*_mobtyper.txt | head -n 1) > ./master_plasmids_mobtyper.txt
tail -n +2 -q "${TMP_OUT_DIR}"/*_mobtyper.txt >> ./master_plasmids_mobtyper.txt

# 5. Clean up the temporary split fasta files to keep your cluster neat
rm -rf "$TMP_SPLIT_DIR"

echo "Success! Your master_plasmids_mobtyper.txt now has a unique row for every single contig."
