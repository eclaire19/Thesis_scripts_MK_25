import pandas as pd

cols = ["ref_id", "query_id", "distance", "pvalue", "shared_hashes"]
df = pd.read_csv("best_hits.tsv", sep="\t", names=cols)

print(df["distance"].describe())
print()
bins = [0, 0.05, 0.1, 0.15, 0.2, 0.3, 0.5, 1.0]
labels = ["0-0.05", "0.05-0.1", "0.1-0.15", "0.15-0.2", "0.2-0.3", "0.3-0.5", "0.5-1.0"]
df["dist_bin"] = pd.cut(df["distance"], bins=bins, labels=labels, include_lowest=True)
print(df["dist_bin"].value_counts().sort_index())

df.to_csv("best_hits_labeled.tsv", sep="\t", index=False)
