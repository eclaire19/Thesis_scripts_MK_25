import glob
import re
import pandas as pd

files = glob.glob("genomad_results/*_genomad_out/*_find_proviruses/*_provirus.fna")
print(f"Found {len(files)} provirus.fna files")

def get_isolate_id(path):
    m = re.search(r"IMP_S(\d+)", path)
    if m:
        return f"IMP_S{m.group(1)}"
    m = re.search(r"merged\.(\d+(?:_P\d+)?)\.", path)
    if m:
        return f"PCF_{m.group(1)}"
    return path  # fallback, flag for inspection

results = []
for f in files:
    isolate_id = get_isolate_id(f)
    n_prophages = 0
    with open(f) as fh:
        for line in fh:
            if line.startswith(">"):
                n_prophages += 1
    results.append({"isolate_id": isolate_id, "file": f, "n_intact_prophages": n_prophages})

df = pd.DataFrame(results)
df.to_csv("prophages_per_genome.tsv", sep="\t", index=False)

print(f"\nTotal genomes: {len(df)}")
print(f"\nDistribution of intact prophage counts per genome:")
print(df["n_intact_prophages"].value_counts().sort_index())

in_range = df["n_intact_prophages"].between(2, 5)
pct_in_range = in_range.mean() * 100
print(f"\nGenomes carrying 2-5 intact prophages: {in_range.sum()}/{len(df)} ({pct_in_range:.1f}%)")

print(f"\nMean prophages/genome: {df['n_intact_prophages'].mean():.2f}")
print(f"Median prophages/genome: {df['n_intact_prophages'].median():.1f}")
print(f"Range: {df['n_intact_prophages'].min()}-{df['n_intact_prophages'].max()}")

# flag any isolate IDs that didn't match either pattern (would show the raw folder path)
unmatched = df[~df["isolate_id"].str.match(r"^(PCF_|IMP_S)")]
if len(unmatched) > 0:
    print(f"\nWARNING: {len(unmatched)} files had unmatched isolate ID pattern:")
    print(unmatched[["file", "isolate_id"]])
