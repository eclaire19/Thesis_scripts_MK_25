import pandas as pd
import subprocess
import os
import glob

comparisons = pd.read_csv("comparisons_parsed.tsv", sep="\t")

os.makedirs("longitudinal_skani", exist_ok=True)

for _, row in comparisons.iterrows():
    iso1, iso2 = row["Isolate_tn"], row["Isolate_tn1"]
    dir1 = f"per_sample_split/{iso1}"
    dir2 = f"per_sample_split/{iso2}"

    if not os.path.isdir(dir1) or not os.path.isdir(dir2):
        print(f"Missing split folder for {iso1} or {iso2}, skipping")
        continue

    out_file = f"longitudinal_skani/{iso1}_vs_{iso2}.tsv"
    if os.path.exists(out_file):
        print(f"Skipping {iso1}_vs_{iso2} — already done")
        continue

    query_files = glob.glob(os.path.join(dir1, "*.fasta"))
    ref_files = glob.glob(os.path.join(dir2, "*.fasta"))

    if not query_files or not ref_files:
        print(f"No fasta files found for {iso1} or {iso2}, skipping")
        continue

    with open("query_list.txt", "w") as qf:
        qf.write("\n".join(query_files))
    with open("ref_list.txt", "w") as rf:
        rf.write("\n".join(ref_files))

    print(f"Running skani: {iso1} vs {iso2}")
    result = subprocess.run([
        "skani", "dist", "--ql", "query_list.txt", "--rl", "ref_list.txt",
        "-o", out_file, "--min-af", "0"
    ], capture_output=True, text=True)

    if result.returncode != 0:
        print(f"skani FAILED for {iso1}_vs_{iso2}: {result.stderr}")
