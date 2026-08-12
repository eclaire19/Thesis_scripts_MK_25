#!/bin/bash
#SBATCH --partition=compute       # Partition name
#SBATCH --nodes=3

# Input directory containing the directories with _provirus suffix
input_dir="/home/crk_w22062555/pharokka_outputs_pcf_phages"
# Output base directory
output_base_dir="test_output_phold"
# Number of threads per phold run
threads=8

# Find and process each directory ending in "_provirus"
find "$input_dir" -type d -name "*_provirus" | while read -r provirus_dir; do
    # Extract base name of the provirus directory
    base_name=$(basename "$provirus_dir")

    # Define the expected path for the pharokka.gbk file
    gbk_file="${provirus_dir}/pharokka.gbk"

    # Check if the pharokka.gbk file exists
    if [[ -f "$gbk_file" ]]; then
        # Define the output directory for this specific provirus sample
        output_dir="${output_base_dir}/${base_name}"

        # Create the output directory if it doesn't exist
        mkdir -p "$output_dir"

        # Run phold with the correct input file
        phold run -i "$gbk_file" -o "$output_dir" -t "$threads" --cpu -f &

        echo "Started processing $gbk_file, results will be saved in $output_dir"
    else
        echo "Warning: pharokka.gbk not found in $provirus_dir, skipping..."
    fi
done

# Wait for all background jobs to finish before exiting
wait

echo "All phold processes completed!"

