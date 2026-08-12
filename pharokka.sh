#!/bin/sh
#SBATCH --job-name=pharokka
#SBATCH --partition=compute


for infile in all_imp_proviruses_renamed.fna
do
base=$(basename ${infile} .fasta)
pharokka.py -i ${infile} -o pharokka_out -d /home/crk_w22062555/miniconda3/envs/pharokka/databases  -g prodigal 
done
