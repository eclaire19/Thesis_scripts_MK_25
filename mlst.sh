#!/bin/bash

# === Configuration ===
BASE_DIR="."        # Directory containing FASTA files
OUTPUT_FILE="mlst_results.tsv"

# === Header ===
echo -e "Sample\tScheme\tST\tAlleles\tFASTA" > "$OUTPUT_FILE"

# === Loop through FASTA files in BASE_DIR ===
find "$BASE_DIR" -maxdepth 1 -type f -name "*.fasta" | while read -r fasta; do
    # Sample name is the fasta filename without extension
    sample=$(basename "$fasta" .fasta)

    echo "🔍 Processing $sample ($fasta)..."

    result=$(mlst "$fasta" | awk -v sample="$sample" -v fasta="$fasta" '{
        scheme = $2
        st = $3
        alleles = ""
        for (i=4; i<=NF; i++) {
            alleles = alleles $i (i<NF ? ";" : "")
        }
        print sample "\t" scheme "\t" st "\t" alleles "\t" fasta
    }')

    echo "$result" >> "$OUTPUT_FILE"
done

echo "✅ All MLST results written to $OUTPUT_FILE"
