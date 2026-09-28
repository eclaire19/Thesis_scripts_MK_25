import pandas as pd
import re

df = pd.read_csv("comparisons.tsv", sep="\t")

# extract PCF_XXX from "PCF_575 (3y) vs PCF_954 (10y)" style strings
def extract_isolates(comparison_str):
    matches = re.findall(r'(PCF_\d+)', comparison_str)
    return matches

all_isolates = set()
for comp in df["Comparison"]:
    all_isolates.update(extract_isolates(comp))

print(f"Found {len(all_isolates)} unique isolates")
with open("isolate_list.txt", "w") as f:
    for iso in sorted(all_isolates):
        f.write(iso + "\n")
