import pandas as pd
import glob
import os

results = []

for f in glob.glob("longitudinal_skani/*.tsv"):
    base = os.path.basename(f).replace(".tsv", "")
    iso1, iso2 = base.split("_vs_")  # iso1 = tn (query), iso2 = tn+1 (ref)

    df = pd.read_csv(f, sep="\t")

    strict = df[
        (df["ANI"] >= 99) &
        (df["Align_fraction_ref"] >= 95) &
        (df["Align_fraction_query"] >= 95)
    ]

    query_phages = set(df["Query_name"].unique())
    ref_phages = set(df["Ref_name"].unique())
    matched_query = set(strict["Query_name"].unique())
    matched_ref = set(strict["Ref_name"].unique())

    retained = len(matched_query)
    lost = len(query_phages - matched_query)
    gained = len(ref_phages - matched_ref)

    results.append({
        "isolate_tn": iso1, "isolate_tn1": iso2,
        "initial_count": len(query_phages), "final_count": len(ref_phages),
        "retained_computed": retained, "lost_computed": lost, "gained_computed": gained
    })

summary = pd.DataFrame(results)
summary.to_csv("longitudinal_carriage_summary.tsv", sep="\t", index=False)
print(summary.head(10))
print(f"\nTotal comparisons processed: {len(summary)}")
