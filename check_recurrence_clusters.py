import pandas as pd

df = pd.read_csv("nucmer_confirmed_nested.tsv", sep="\t")
confirmed = df[df["confirmed_nested"] == True].copy()
confirmed["base"] = confirmed["file"].str.replace(".coords", "", regex=False).str.split("/").str[-1]
confirmed[["nested_name", "containing_name"]] = confirmed["base"].str.split("_vs_", expand=True)

counts = confirmed["nested_name"].value_counts()
print("Nested phages appearing in MORE than 1 confirmed pair (recurrent elements):")
print(counts[counts > 1].to_string())

one_off = counts[counts == 1]
print(f"\n{len(one_off)} phages appear exactly once (genuine one-off cases, good 'typical example' candidates):")
print(one_off.index.tolist()[:10])
