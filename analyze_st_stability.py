import pandas as pd
from scipy.stats import chi2_contingency

# --- load MLST results (robust parse: only need first 3 columns) ---
mlst_rows = []
with open("mlst_results.tsv") as f:
    header = f.readline()
    for line in f:
        parts = line.rstrip("\n").split("\t")
        if len(parts) < 3:
            continue
        sample, metadata, st = parts[0], parts[1], parts[2]
        mlst_rows.append({"sample": sample, "metadata": metadata, "ST": st})
mlst = pd.DataFrame(mlst_rows)

def to_isolate_id(sample):
    # "236" -> "PCF_236"; "IMP_S1" -> "imp_s1" style already used elsewhere
    if sample.upper().startswith("IMP"):
        return sample.lower()
    return f"PCF_{sample}"

mlst["isolate_id"] = mlst["sample"].apply(to_isolate_id)
mlst["ST_clean"] = mlst["ST"].apply(lambda x: "Untypeable" if x.strip() == "-" else x.strip())
st_lookup = dict(zip(mlst["isolate_id"], mlst["ST_clean"]))

# --- load patient linkage ---
comp = pd.read_csv("comparisons_parsed.tsv", sep="\t")
comp = comp[["Patient ID", "Isolate_tn", "Isolate_tn1"]]

# --- load longitudinal carriage results ---
long_df = pd.read_csv("longitudinal_carriage_summary_v2.tsv", sep="\t")

# rename to match comp's isolate columns for merge
long_df = long_df.rename(columns={"isolate_tn": "Isolate_tn", "isolate_tn1": "Isolate_tn1"})

merged = comp.merge(long_df, on=["Isolate_tn", "Isolate_tn1"], how="inner")
print(f"Matched {len(merged)}/{len(comp)} comparisons to longitudinal carriage data")

# --- per-patient aggregation ---
patient_rows = []
mismatch_patients = []

for patient_id, group in merged.groupby("Patient ID"):
    total_retained = group["retained_computed"].sum()
    total_lost = group["lost_computed"].sum()
    total_gained = group["gained_computed"].sum()
    denom = total_retained + total_lost + total_gained
    stability_score = (total_retained / denom * 100) if denom > 0 else float("nan")
    category = "Stable" if total_lost == 0 and total_gained == 0 else "Volatile"

    # gather all isolates for this patient across all their comparisons
    isolates = set(group["Isolate_tn"]).union(set(group["Isolate_tn1"]))
    sts = set(st_lookup.get(iso, "NotFound") for iso in isolates)
    sts_known = {s for s in sts if s != "NotFound"}

    if len(sts_known) == 0:
        st_category = "NotFound"
    elif len(sts_known) == 1:
        st_category = list(sts_known)[0]
    else:
        st_category = "Mixed/replacement"
        mismatch_patients.append((patient_id, sts_known))

    patient_rows.append({
        "Patient_ID": patient_id,
        "stability_score_pct": round(stability_score, 2),
        "stability_category": category,
        "ST_category": st_category,
        "n_isolates": len(isolates)
    })

patient_df = pd.DataFrame(patient_rows).sort_values("stability_score_pct", ascending=False)
patient_df.to_csv("patient_st_stability.tsv", sep="\t", index=False)

print(f"\nTotal patients/lineages analyzed: {len(patient_df)}")
print(f"\nStability category counts:\n{patient_df['stability_category'].value_counts()}")
print(f"\nPatients with ST mismatch (possible strain replacement): {len(mismatch_patients)}")
for pid, sts in mismatch_patients:
    print(f"  {pid}: {sts}")

# --- contingency table + chi-squared test ---
contingency = pd.crosstab(patient_df["ST_category"], patient_df["stability_category"])
contingency.to_csv("st_stability_contingency.tsv", sep="\t")
print(f"\nContingency table shape: {contingency.shape}")
print(contingency)

chi2, p, dof, expected = chi2_contingency(contingency)
n_low_expected = (expected < 5).sum()
print(f"\nChi-squared test: chi2={chi2:.3f}, dof={dof}, p={p:.3e}")
print(f"Cells with expected count < 5: {n_low_expected} / {expected.size} ({100*n_low_expected/expected.size:.1f}%)")
