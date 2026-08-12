#!/usr/bin/env python3
import os
import glob

# ---------------- CONFIG ----------------
root_dir = "/home/crk_w22062555/Imperial_fastqs/IMP_methylation"  # Top-level folder containing sample subfolders
# ----------------------------------------

def extract_motif_content(filepath, keep_header=False):
    """Extract motif definitions from a MEME file, optionally keeping the header"""
    with open(filepath, 'r') as f:
        lines = f.readlines()

    # Find the first MOTIF line
    for i, line in enumerate(lines):
        if line.strip().startswith("MOTIF"):
            header_end = i
            break
    else:
        return []

    if keep_header:
        return lines
    else:
        return lines[header_end:]

# Loop through each subfolder
for subdir in sorted(os.listdir(root_dir)):
    full_path = os.path.join(root_dir, subdir)
    if not os.path.isdir(full_path):
        continue

    # Find .meme files in the folder
    meme_files = sorted(glob.glob(os.path.join(full_path, "*.meme")))
    if not meme_files:
        print(f"No .meme files found in {subdir}, skipping.")
        continue

    print(f"Processing folder: {subdir}")
    combined_lines = []

    # Combine all MEME files in this folder
    for idx, meme_file in enumerate(meme_files):
        keep_header = (idx == 0)  # Only keep MEME header from the first file
        content = extract_motif_content(meme_file, keep_header=keep_header)
        combined_lines.extend(content)
        combined_lines.append("\n")  # separate motifs

    # Write combined.meme in the same folder
    output_file = os.path.join(full_path, "combined.meme")
    with open(output_file, "w") as f:
        f.writelines(combined_lines)

    print(f" Combined file written: {output_file}")

print("All sample folders processed!")

