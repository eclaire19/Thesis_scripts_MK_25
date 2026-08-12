#!/bin/sh
#SBATCH --job-name=cdhit
#SBATCH --partition=compute


/home/crk_w22062555/cdhit/cdhit/cd-hit-est -i all_high_long_phages.fna -o /home/crk_w22062555/longitudinal_batch1/all_high_long_dedup_phages.fna -c 0.95 -M 16000 -T 8 -n 10 -d 0

