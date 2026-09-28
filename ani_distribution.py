import pandas as pd
import glob

all_hits = []

for f in glob.glob("longitudinal_skani/*.tsv"):
    df = pd.read_csv(f, sep="\t")
    all_hits.append(df)

combined = pd.concat(all_hits, ignore_index=True)

high_cov = combined[
    (combined["Align_fraction_ref"] >= 95) &
    (combined["Align_fraction_query"] >= 95)
]

print(f"Total pairwise hits across all comparisons: {len(combined)}")
print(f"High-coverage pairs (>=95% both directions): {len(high_cov)}")
print()
print("ANI distribution among high-coverage pairs:")
print(high_cov["ANI"].describe())
print()
print("Count of high-coverage pairs by ANI bracket:")
bins = [0, 90, 95, 97, 98, 98.5, 99, 99.5, 100.01]
labels = ["<90", "90-95", "95-97", "97-98", "98-98.5", "98.5-99", "99-99.5", "99.5-100"]
high_cov["ani_bin"] = pd.cut(high_cov["ANI"], bins=bins, labels=labels, right=False)
print(high_cov["ani_bin"].value_counts().sort_index())

high_cov.to_csv("high_coverage_pairs_for_threshold_check.tsv", sep="\t", index=False)
