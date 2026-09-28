import pandas as pd

df = pd.read_csv("nucmer_confirmed_nested.tsv", sep="\t")
confirmed = df[df["confirmed_nested"] == True].copy()
confirmed["base"] = confirmed["file"].str.replace(".coords", "", regex=False).str.split("/").str[-1]
confirmed[["nested_name", "containing_name"]] = confirmed["base"].str.split("_vs_", expand=True)

counts = confirmed["nested_name"].value_counts()
n_unique_nested = len(counts)
n_recurrent = (counts > 1).sum()
n_oneoff = (counts == 1).sum()

print(f"Total confirmed pairs: {len(confirmed)}")
print(f"Unique nested phages: {n_unique_nested}")
print(f"Recurrent (appear in >1 pair): {n_recurrent} ({100*n_recurrent/n_unique_nested:.1f}%)")
print(f"One-off (appear in exactly 1 pair): {n_oneoff} ({100*n_oneoff/n_unique_nested:.1f}%)")
print(f"\nMax recurrence: {counts.max()} (phage: {counts.idxmax()})")
print(f"Median recurrence among recurrent phages: {counts[counts>1].median()}")

one_off_names = counts[counts == 1].index
one_off_pairs = confirmed[confirmed["nested_name"].isin(one_off_names)]
best_oneoff = one_off_pairs.sort_values("merged_query_coverage_pct", ascending=False).head(3)
print("\nBest one-off example candidates (high coverage, single occurrence):")
print(best_oneoff[["nested_name", "containing_name", "merged_query_coverage_pct"]].to_string())
