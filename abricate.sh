#!/bin/sh
#SBATCH --partition=compute

abricate prophage_regions_imperial_derep.fna --db card > abricate_results_card.csv

abricate prophage_regions_imperial_derep.fna --db argannot > abricate_results_argannot.csv

abricate prophage_regions_imperial_derep.fna --db megares > abricate_results_megares.csv

abricate prophage_regions_imperial_derep.fna --db vfdb > abricate_results_vfdb.csv

abricate prophage_regions_imperial_derep.fna --db ncbi > abricate_results_ncbi.csv

abricate prophage_regions_imperial_derep.fna --db resfinder > abricate_results_resfinder.csv

cat *csv > abricate_results_imperial_dedup.csv
