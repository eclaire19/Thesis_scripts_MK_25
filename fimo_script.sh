#!/bin/bash
#SBATCH --partition=compute
# Set a significance threshold
THRESH=1e-5

# Loop through each sample directory
for sample_dir in */ ; do
    # Remove trailing slash
    sample_dir="${sample_dir%/}"
    echo "Processing sample: $sample_dir"

    motif_file="$sample_dir/combined_fixed.meme"
    fasta_file=$(find "$sample_dir" -maxdepth 1 -type f -name "*.fasta" | head -n 1)
    output_dir="$sample_dir/fimo_out"

    # Check if required files exist
    if [[ -f "$motif_file" && -f "$fasta_file" ]]; then
        echo "  Motif:  $motif_file"
        echo "  FASTA:  $fasta_file"
        echo "  Output: $output_dir"

        # Run FIMO
        fimo --thresh "$THRESH" --oc "$output_dir" "$motif_file" "$fasta_file"
        echo "  âœ” Done"
    else
        echo "  âš  Skipping $sample_dir: missing motifs.meme or .fasta file"
    fi
done

