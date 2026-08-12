find . -type f -name "plassembler_plasmids.gfa" | while read -r gfa; do
    # Get the directory and base name so we can name the output image
    dir=$(dirname "$gfa")
    base=$(basename "$gfa" .gfa)
    
    echo "Generating plot for $gfa..."
    
    # Run Bandage to output a high-res image colored by coverage depth
    Bandage image "$gfa" "$dir/${base}_bandage.png" --colour random --width 2000 --height 2000
done