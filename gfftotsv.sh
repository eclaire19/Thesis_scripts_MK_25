#!/bin/bash

mkdir -p results

for dir in analysis-*; do
  gff=$(find "$dir" -maxdepth 1 -name "*-basemods.gff")
  if [[ -f "$gff" ]]; then
    sample=$(echo "$dir" | sed -E 's/^.*_([0-9]+)(_.*)?$/\1/')
    echo "Processing $sample from $gff"

    awk -v sample="$sample" 'BEGIN{OFS="\t"} !/^#/ {
      chrom = $1
      start = $4 - 1
      end = $5
      strand = $7
      mod = $3
      cov = "."
      ipd = "."

      split($9, a, ";")
      for(i in a){
        if(a[i] ~ /^coverage=/) { split(a[i], b, "="); cov = b[2] }
        if(a[i] ~ /^IPDRatio=/) { split(a[i], b, "="); ipd = b[2] }
      }

      print chrom, start, end, strand, mod, cov, ipd, sample
    }' "$gff" > "results/${sample}.tsv"

  else
    echo "⚠️ No basemods.gff found in $dir, skipping..."
  fi
done

