import re
import pandas as pd

LOCI = ["acsA", "aroE", "guaA", "mutL", "nuoD", "ppsA", "trpE"]

def to_isolate_id(sample):
    if sample.upper().startswith("IMP"):
        return sample.lower()
    return f"PCF_{sample}"

def clean_allele(val):
    # strip uncertainty markers (~, ?) but keep the underlying call for comparison
    v = val.strip()
    if v == "-" or v == "":
        return None
    v = v.lstrip("~").rstrip("?")
    return v

# --- parse full allele profiles ---
allele_profiles = {}
with open("mlst_results.tsv") as f:
    header = f.readline()
    for line in f:
        parts = line.rstrip("\n").split("\t")
        if len(parts) < 4:
            continue
        sample = parts[0]
        isolate_id = to_isolate_id(sample)
        profile = {}
        for field in parts[4:]:
            m = re.match(r"(\w+)\(([^)]*)\)", field.strip())
            if m:
                locus, val = m.group(1), m.group(2)
                profile[locus] = clean_allele(val)
        allele_profiles[isolate_id] = profile

# --- load patient-level ST-mismatch list from previous step ---
patient_df = pd.read_csv("patient_st_stability.tsv", sep="\t")
comp = pd.read_csv("comparisons_parsed.tsv", sep="\t")[["Patient ID", "Isolate_tn", "Isolate_tn1"]]

results = []
for _, row in comp.iterrows():
    pid, iso_tn, iso_tn1 = row["Patient ID"], row["Isolate_tn"], row["Isolate_tn1"]
    p1 = allele_profiles.get(iso_tn, {})
    p2 = allele_profiles.get(iso_tn1, {})

    n_compared = 0
    n_matching = 0
    for locus in LOCI:
        v1, v2 = p1.get(locus), p2.get(locus)
        if v1 is not None and v2 is not None:
            n_compared += 1
            if v1 == v2:
                n_matching += 1
    n_differing = n_compared - n_matching

    if n_compared == 0:
        category = "Insufficient data"
    elif n_differing == 0:
        category = "Identical (0 loci differ)"
    elif n_differing == 1:
        category = "Single-locus variant (SLV)"
    else:
        category = f"Multi-locus variant ({n_differing} loci differ)"

    results.append({
        "Patient_ID": pid, "Isolate_tn": iso_tn, "Isolate_tn1": iso_tn1,
        "n_loci_compared": n_compared, "n_loci_differing": n_differing,
        "allele_category": category
    })

allele_df = pd.DataFrame(results)
allele_df.to_csv("patient_allele_level_comparison.tsv", sep="\t", index=False)

print("Allele-level category counts (all 108 patient comparisons):")
print(allele_df["allele_category"].value_counts())

# --- cross-reference against the ST-mismatch ("Mixed/replacement") patients ---
mixed_patients = patient_df[patient_df["ST_category"] == "Mixed/replacement"]["Patient_ID"]
mixed_detail = allele_df[allele_df["Patient_ID"].isin(mixed_patients)]
print(f"\nOf the {len(mixed_patients)} patients flagged as ST 'Mixed/replacement', allele-level breakdown:")
print(mixed_detail["allele_category"].value_counts())
print("\nFull detail:")
print(mixed_detail[["Patient_ID", "n_loci_differing", "allele_category"]].to_string(index=False))
