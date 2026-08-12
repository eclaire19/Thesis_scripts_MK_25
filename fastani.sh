#!/bin/bash
#SBATCH --partition=compute
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20

fastANI --ql ref_list.txt --rl ref_list.txt -t 20 -o bigmatrix.tbl

