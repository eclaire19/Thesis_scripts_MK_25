import pandas as pd

df = pd.read_csv("high_coverage_pairs_for_threshold_check.tsv", sep="\t")
borderline = df[df["ANI"] < 99].sort_values("ANI")
print(borderline[["Query_name", "Ref_name", "ANI", "Align_fraction_ref", "Align_fraction_query"]].to_string())
print(f"\n{len(borderline)} pairs would flip from 'lost+gained' to 'retained' if threshold dropped just below their ANI")
