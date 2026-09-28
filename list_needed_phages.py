import pandas as pd

df = pd.read_csv("retained_and_borderline_pairs.tsv", sep="\t")

needed = set(df["query_phage"]).union(set(df["ref_phage"]))

print(f"Unique phage sequences needing annotation: {len(needed)}")
print(f"Unique patient comparisons: {df[['isolate_tn','isolate_tn1']].drop_duplicates().shape[0]}")

with open("phages_needing_pharokka.txt", "w") as f:
    for name in sorted(needed):
        f.write(name + "\n")
