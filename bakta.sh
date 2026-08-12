#!/bin/bash
#SBATCH --partition=compute
#SBATCH --nodes=2
#SBATCH --job-name=bakta_batch

# Set the path to your Bakta database
DB_PATH="/home/crk_w22062555/Fastqs_PacBio/combined_normalized_fastqs/renamed_fastqs/flye_results_all_samples/single_contig_fastas/db"

# Input directory containing FASTA files
INPUT_DIR="."

# Check that bakta is available
if ! command -v bakta &> /dev/null; then
    echo "âŒ ERROR: 'bakta' not found in PATH"
    exit 1
fi

echo "ðŸ” Searching for FASTA files in: $INPUT_DIR"

# Loop through all supported FASTA file types
for genome in "$INPUT_DIR"/*.fasta "$INPUT_DIR"/*.fa "$INPUT_DIR"/*.fna; do
    [ -f "$genome" ] || continue

    base=$(basename "$genome" | sed 's/\.[^.]*$//')
    gbff_out="${base}.gbff"

    # Skip if output file already exists
    if [[ -f "$gbff_out" ]]; then
        echo "â­ï¸ Skipping $base (already processed: $gbff_out exists)"
        continue
    fi

    echo "ðŸ§¬ Running Bakta on: $base"

    bakta "$genome" \
        --db "$DB_PATH" \
        --prefix "$base" \
        --threads 8 \
        --skip-trna

    echo "âœ… Finished: $base"
done

echo "ðŸŽ‰ All genomes processed (unprocessed only)!"


