import pandas as pd
import glob
import os

results = []

for f in glob.glob("longitudinal_skani/*.tsv"):
    base = os.path.basename(f).replace(".tsv", "")
    iso1, iso2 = base.split("_vs_")

    query_dir = f"per_sample_split/{iso1}"
    ref_dir = f"per_sample_split/{iso2}"

    def get_seq_names(fasta_path):
        with open(fasta_path) as fh:
            for line in fh:
                if line.startswith(">"):
                    return line[1:].strip()
        return None

    query_files = glob.glob(os.path.join(query_dir, "*.fasta"))
    ref_files = glob.glob(os.path.join(ref_dir, "*.fasta"))

    query_phages = set(get_seq_names(f) for f in query_files)
    ref_phages = set(get_seq_names(f) for f in ref_files)

    df = pd.read_csv(f, sep="\t")
    strict = df[
        (df["ANI"] >= 99) &
        (df["Align_fraction_ref"] >= 95) &
        (df["Align_fraction_query"] >= 95)
    ]

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
summary.to_csv("longitudinal_carriage_summary_v2.tsv", sep="\t", index=False)
print(summary.head(10))
