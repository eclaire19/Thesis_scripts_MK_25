#!/bin/bash
#SBATCH --job-name=IQ-TREE_Pangenome
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=24:00:00
#SBATCH --partition=compute

# 1. Load the module (Adjust this based on your cluster's naming)
# If IQ-TREE is installed via Conda, use: source activate iqtree_env


# 2. Run the command
# We tell IQ-TREE to use the 8 cores we requested via Slurm
iqtree -s core_gene_alignment_filtered.aln \
       -m MFP \
       -bb 1000 \
       -nt $SLURM_CPUS_PER_TASK \
       -pre pangenome_tree

echo "IQ-TREE finished successfully at $(date)"
