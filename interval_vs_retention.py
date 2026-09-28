import pandas as pd
import re

comparisons = pd.read_csv("comparisons_parsed.tsv", sep="\t")
def extract_ages(comp_str):
    ages = re.findall(r'\((\d+)y\)', comp_str)
    return int(ages[0]), int(ages[1])
comparisons[["age_tn", "age_tn1"]] = comparisons["Comparison"].apply(lambda x: pd.Series(extract_ages(x)))
comparisons["interval_years"] = comparisons["age_tn1"] - comparisons["age_tn"]

computed = pd.read_csv("longitudinal_carriage_summary_v2.tsv", sep="\t")

merged = comparisons.merge(computed, left_on=["Isolate_tn","Isolate_tn1"], right_on=["isolate_tn","isolate_tn1"], how="left")

merged["proportion_retained"] = merged["retained_computed"] / merged["initial_count"]
merged["complete_turnover"] = merged["retained_computed"] == 0

print("Correlation between interval length and proportion retained:")
print(merged[["interval_years", "proportion_retained"]].corr())
print()

bins = [0, 2, 5, 10, 16]
labels = ["0-2y", "3-5y", "6-10y", "11-15y"]
merged["interval_bin"] = pd.cut(merged["interval_years"], bins=bins, labels=labels, include_lowest=True)

print("Mean proportion retained by interval bracket:")
print(merged.groupby("interval_bin", observed=True)["proportion_retained"].agg(["mean", "count"]))
print()

print("Proportion with complete turnover, by interval bracket:")
print(merged.groupby("interval_bin", observed=True)["complete_turnover"].agg(["mean", "count"]))
