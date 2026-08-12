#!/bin/bash

echo -e "sample_id\tphage_count" > phages_per_sample.tsv

for sample_dir in */; do
    sample=$(basename "$sample_dir")

    # find provirus TSV inside *_find_proviruses folders
    provirus_tsv=$(find "$sample_dir" -type d -name "*_find_proviruses" \
        -exec find {} -name "*_provirus.tsv" \; 2>/dev/null)

    if [[ -f "$provirus_tsv" ]]; then
        # subtract 1 for header
        count=$(($(wc -l < "$provirus_tsv") - 1))
        [[ $count -lt 0 ]] && count=0
    else
        count=0
    fi

    echo -e "${sample}\t${count}" >> phages_per_sample.tsv
done

