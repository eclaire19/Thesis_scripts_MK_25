#!/bin/bash

output="filtered_plasmid_features.tsv"
> "$output"

# Find at least one matching file to extract header
first_file=$(find . -type f -name "pcf_plasmid_len*.tsv" | head -n 1)

if [[ -z "$first_file" ]]; then
    echo "No files matching pcf_plasmid_ln*.tsv found."
    exit 1
fi

# Extract header and prepend 'source_file' column
header=$(head -n 1 "$first_file")
echo -e "source_file\t$header" > "$output"

# Define keywords (case-insensitive)
keywords="transposase|integrase|relaxase|replication|toxin|antitoxin|hicA|hicB|relE|relB|vapC|vapB"

# Loop through files
find . -type f -name "pcf_plasmid_len*.tsv" | while read -r file; do
    # Check if file is non-empty and has more than just header
    lines=$(wc -l < "$file")
    if (( lines < 2 )); then
        echo "Skipping empty or header-only file: $file"
        continue
    fi

    # Search keywords in whole line (case-insensitive)
    # Skip header (tail -n +2)
    tail -n +2 "$file" | grep -iE "$keywords" | awk -v src="$file" 'BEGIN{OFS="\t"} {print src, $0}' >> "$output"
done

echo "Filtered plasmid features saved to $output"

