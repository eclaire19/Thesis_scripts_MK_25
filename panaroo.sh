#!/bin/bash
#SBATCH --job-name=panaroo_run
#SBATCH --partition=compute  # Change to your cluster's partition name
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=w22062555@northumbria.ac.uk
#SBATCH --nodes=2

# Make sure output directory exists
mkdir -p panaroo_out

# Run Panaroo
panaroo -i ./pcf*.gff3 -o panaroo_out \
  -a core \
  --aligner mafft \
  --codons \
  --clean-mode strict \
  --remove-invalid-genes \
  --core_threshold 0.95 \
  --threads 16
