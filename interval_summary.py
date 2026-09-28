import pandas as pd
import re

df = pd.read_csv("comparisons_parsed.tsv", sep="\t")

def extract_ages(comp_str):
    ages = re.findall(r'\((\d+)y\)', comp_str)
    return int(ages[0]), int(ages[1])

df[["age_tn", "age_tn1"]] = df["Comparison"].apply(lambda x: pd.Series(extract_ages(x)))
df["interval_years"] = df["age_tn1"] - df["age_tn"]

print(df["interval_years"].describe())
print()
print(f"Min interval: {df['interval_years'].min()} years")
print(f"Max interval: {df['interval_years'].max()} years")
print(f"Median interval: {df['interval_years'].median()} years")
