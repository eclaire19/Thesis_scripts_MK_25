import pandas as pd

original = pd.read_csv("comparisons_parsed.tsv", sep="\t")
computed = pd.read_csv("longitudinal_carriage_summary.tsv", sep="\t")

merged = original.merge(
    computed,
    left_on=["Isolate_tn", "Isolate_tn1"],
    right_on=["isolate_tn", "isolate_tn1"],
    how="left"
)

merged["retained_match"] = merged["Identical Retained"] == merged["retained_computed"]
merged["lost_match"] = merged["Phages Lost"] == merged["lost_computed"]
merged["gained_match"] = merged["Phages Gained"] == merged["gained_computed"]

cols = ["Patient ID", "Isolate_tn", "Isolate_tn1",
        "Identical Retained", "retained_computed", "retained_match",
        "Phages Lost", "lost_computed", "lost_match",
        "Phages Gained", "gained_computed", "gained_match"]

pd.set_option("display.max_columns", None)
pd.set_option("display.width", 200)

print(merged[cols].head(15).to_string())
print(f"\nRetained matches: {merged['retained_match'].sum()} / {len(merged)}")
print(f"Lost matches: {merged['lost_match'].sum()} / {len(merged)}")
print(f"Gained matches: {merged['gained_match'].sum()} / {len(merged)}")

merged.to_csv("validation_comparison.tsv", sep="\t", index=False)
