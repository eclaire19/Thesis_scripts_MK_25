#!/bin/bash
#SBATCH --partition=compute
#SBATCH --nodes=3
#SBATCH --mail-user=w22062555@northumbria.ac.uk
#SBATCH --mail-type=END,FAIL
# Directories (adjust these paths)
reads_dir="/home/crk_w22062555/Imperial_fastqs"
assemblies_dir="."
bams_dir="bams"

# Create BAM output folder
mkdir -p "$bams_dir"

# Loop over all FASTQ files
for reads in "$reads_dir"/*.fastq; do
    [[ -e "$reads" ]] || { echo "No FASTQ files found in $reads_dir"; exit 1; }

    # Get sample name without path and extension
    sample=$(basename "$reads" .fastq)

    # Find matching assembly
    assembly="$assemblies_dir/${sample}.fasta"
    if [[ ! -f "$assembly" ]]; then
        echo "Assembly for $sample not found in $assemblies_dir, skipping..."
        continue
    fi

    echo "Processing sample: $sample"

    # Map reads to assembly with pbmm2 (choose preset based on your data type)
    # For HiFi (CCS) reads use --preset CCS
    # For CLR (subreads) use --preset SUBREAD
    pbmm2 align --sort --preset CCS "$assembly" "$reads" "$bams_dir/${sample}.sorted.bam"

    # Index BAM file
    samtools index "$bams_dir/${sample}.sorted.bam"
done
