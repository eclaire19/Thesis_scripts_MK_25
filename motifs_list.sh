#!/bin/bash

MOTIFS_DIR="/home/crk_w22062555/methylation_pcf/motifs"
MOTIFS_LIST="motifs_lists.txt"

echo "🔍 Scanning $MOTIFS_DIR for motif files..."

# Generate motifs_lists.txt (overwrite if exists)
find "$MOTIFS_DIR" -maxdepth 1 -type f -name "*.motif" | sort > "$MOTIFS_LIST"

echo "✅ Generated $MOTIFS_LIST with $(wc -l < "$MOTIFS_LIST") motif files."

