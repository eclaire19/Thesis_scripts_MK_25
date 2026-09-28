import pandas as pd

df = pd.read_csv("nucmer_confirmed_nested.tsv", sep="\t")
confirmed = df[df["confirmed_nested"] == True].copy()

confirmed["base"] = confirmed["file"].str.replace(".coords", "", regex=False).str.split("/").str[-1]
confirmed[["nested_name", "containing_name"]] = confirmed["base"].str.split("_vs_", expand=True)

print("=== Top 5 highest-coverage confirmed pairs (cleanest containment) ===")
top_coverage = confirmed.sort_values("merged_query_coverage_pct", ascending=False).head(5)
print(top_coverage[["nested_name", "containing_name", "merged_query_coverage_pct"]].to_string())

print("\n=== pcf_936 pairs (most recurrent nested phage) ===")
pcf_936_pairs = confirmed[confirmed["nested_name"].str.contains("pcf_936")]
print(pcf_936_pairs[["nested_name", "containing_name", "merged_query_coverage_pct"]].to_string())
