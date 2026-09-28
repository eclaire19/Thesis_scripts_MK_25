import pandas as pd
import os

df = pd.read_csv("retained_and_borderline_pairs.tsv", sep="\t")

os.makedirs("clinker_inputs", exist_ok=True)

comparisons = df.groupby(["isolate_tn", "isolate_tn1"])

manifest = []

for (iso1, iso2), group in comparisons:
    comp_dir = f"clinker_inputs/{iso1}_vs_{iso2}"
    os.makedirs(comp_dir, exist_ok=True)

    phages_in_comparison = set(group["query_phage"]).union(set(group["ref_phage"]))

    linked = 0
    for phage_name in phages_in_comparison:
        gbk_path = f"pharokka_longitudinal_out/{phage_name}/{phage_name}.gbk"
        dest = f"{comp_dir}/{phage_name}.gbk"

        if not os.path.exists(gbk_path):
            print(f"WARNING: missing gbk for {phage_name} (needed for {iso1}_vs_{iso2})")
            continue

        if not os.path.exists(dest):
            os.symlink(os.path.abspath(gbk_path), dest)
        linked += 1

    manifest.append({
        "comparison": f"{iso1}_vs_{iso2}",
        "n_phages": len(phages_in_comparison),
        "n_linked": linked,
        "categories": ",".join(group["category"].unique())
    })

manifest_df = pd.DataFrame(manifest)
manifest_df.to_csv("clinker_manifest.tsv", sep="\t", index=False)
print(f"Built {len(manifest_df)} comparison folders")
print(manifest_df.head(10).to_string())
