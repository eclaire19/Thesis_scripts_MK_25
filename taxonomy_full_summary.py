import pandas as pd

df = pd.read_csv("taxmyphage_out/Summary_taxonomy.tsv", sep="\t")

def get_cohort(name):
    return "IMP" if ("imp_s" in name.lower() or name.lower().startswith("ctg")) else "PCF"

df["cohort"] = df["Genome"].apply(get_cohort)

def classify_status(row):
    if row["Genus"] == "New_genus":
        return "novel"
    else:
        return "classified"

df["status"] = df.apply(classify_status, axis=1)

print("=== Overall ===")
print(df["status"].value_counts())
print(f"Novel: {100*(df['status']=='novel').sum()/len(df):.1f}%")
print()

print("=== By cohort ===")
for cohort in ["PCF", "IMP"]:
    sub = df[df["cohort"] == cohort]
    n = len(sub)
    novel = (sub["status"] == "novel").sum()
    classified = (sub["status"] == "classified").sum()
    print(f"{cohort}: n={n}, novel={novel} ({100*novel/n:.1f}%), classified={classified} ({100*classified/n:.1f}%)")
print()

print("=== Genus breakdown among classified, by cohort ===")
classified_df = df[df["status"] == "classified"]
genus_table = classified_df.groupby(["Genus", "cohort"]).size().unstack(fill_value=0)
print(genus_table.sort_values(by=genus_table.columns.tolist(), ascending=False))
print()

print("=== Realm/Family check for classified entries ===")
print(classified_df[["Realm", "Family", "Genus"]].drop_duplicates().to_string())

df.to_csv("taxonomy_summary_full.tsv", sep="\t", index=False)
classified_df.to_csv("taxonomy_classified_only.tsv", sep="\t", index=False)
