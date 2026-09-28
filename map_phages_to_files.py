import glob
import os

with open("phages_needing_pharokka.txt") as f:
    needed = set(line.strip() for line in f)

found = {}
missing = set(needed)

for fasta in glob.glob("per_sample_split/*/*.fasta"):
    with open(fasta) as fh:
        header = fh.readline().strip().lstrip(">")
    if header in needed:
        found[header] = fasta
        missing.discard(header)

print(f"Matched: {len(found)} / {len(needed)}")
if missing:
    print(f"MISSING ({len(missing)}):")
    for m in sorted(missing):
        print(f"  {m}")

with open("phage_name_to_file.tsv", "w") as f:
    f.write("phage_name\tfile_path\n")
    for name, path in found.items():
        f.write(f"{name}\t{path}\n")
