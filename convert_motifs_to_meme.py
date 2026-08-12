#!/usr/bin/env python3
import os
import pandas as pd

samples_dir = "."  # Folder containing sample subfolders
alphabet = "ACGT"  # DNA alphabet for MEME


def write_meme_file(motif, output_path, width=4):
    """Write a minimal MEME file for a motif"""
    with open(output_path, "w") as f:
        f.write("MEME version 4\n\n")
        f.write(f"ALPHABET= {alphabet}\n\n")
        f.write(f"MOTIF {motif}\n")
        f.write(f"letter-probability matrix: alength= 4 w= {len(motif)} nsites= 10 E= 0\n")
        # Assign uniform probabilities per base
        for base in motif:
            line = []
            for b in alphabet:
                if b == base:
                    line.append("0.9")
                else:
                    line.append("0.0333")
            f.write(" ".join(line) + "\n")

# Loop through sample folders
for sample_folder in os.listdir(samples_dir):
    sample_path = os.path.join(samples_dir, sample_folder)
    if not os.path.isdir(sample_path):
        continue

    # Find motifs.csv
    csv_files = [f for f in os.listdir(sample_path) if f.endswith("motifs.csv")]
    if not csv_files:
        print(f"No motifs.csv in {sample_folder}, skipping.")
        continue

    csv_path = os.path.join(sample_path, csv_files[0])
    try:
        df = pd.read_csv(csv_path)
        motif_names = df['motifString'].dropna().unique()
    except Exception as e:
        print(f" Error reading {csv_path}: {e}")
        continue

    for motif in motif_names:
        meme_file = os.path.join(sample_path, f"{motif}.meme")
        write_meme_file(motif, meme_file)
        print(f"Created MEME file: {meme_file}")

print("🎉 All MEME files created successfully.")

