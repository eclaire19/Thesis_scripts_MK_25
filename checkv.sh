#!/bin/bash
#SBATCH --partition=compute
#SBATCH --nodes=2

checkv end_to_end -d /home/crk_w22062555/PAseqs24/checkv-db-v1.5  ./all_imperial_proviruses.fna  ./checkv_results -t 16 
