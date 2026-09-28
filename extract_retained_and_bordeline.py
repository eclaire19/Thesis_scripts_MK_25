import pandas as pd
import glob
import os

pairs = []

for f in glob.glob("longitudinal_skani/*.tsv"):
    base = os.path.basename(f).replace(".tsv", "")
    iso1, iso2 = base.split("_vs_")

    df = pd.read_csv(f, sep="\t")

    high_cov = df[
        (df["Align_fraction_ref"] >= 95) &
        (df["Align_fraction_query"] >= 95)
    ]

    for _, row in high_cov.iterrows():
        if row["ANI"] >= 99:
            category = "retained_strict"
        elif row["ANI"] >= 98:
            category = "retained_borderline"
        else:
            continue

        pairs.append({
            "isolate_tn": iso1,
            "isolate_tn1": iso2,
            "query_phage": row["Query_name"],
            "ref_phage": row["Ref_name"],
            "ANI": row["ANI"],
            "af_ref": row["Align_fraction_ref"],
            "af_query": row["Align_fraction_query"],
            "category": category
        })

pairs_df = pd.DataFrame(pairs).sort_values(["category", "ANI"], ascending=[True, False])
pairs_df.to_csv("retained_and_borderline_pairs.tsv", sep="\t", index=False)

print(pairs_df["category"].value_counts())
print()
print(pairs_df.head(15).to_string())
