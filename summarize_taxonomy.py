import pandas as pd

df = pd.read_csv("taxmyphage_out/Summary_taxonomy.tsv", sep="\t")

def get_cohort(name):
    return "IMP" if ("imp_s" in name.lower() or name.lower().startswith("ctg")) else "PCF"

df["cohort"] = df["Genome"].apply(get_cohort)

print(f"Total classified genomes: {len(df)}")
print(df["cohort"].value_counts())
print()
print("Unique Genus values:")
print(df["Genus"].value_counts())
print()
print("Unique Realm values:")
print(df["Realm"].value_counts())
print()
print("Unique Message values:")
print(df["Message"].value_counts())
