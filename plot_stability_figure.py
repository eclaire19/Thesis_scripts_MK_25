import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv("patient_st_stability.tsv", sep="\t")
df = df.sort_values("stability_score_pct", ascending=False).reset_index(drop=True)

stable_pct = df["stability_score_pct"]
volatile_pct = 100 - stable_pct
mean_stability = stable_pct.mean()

fig, ax = plt.subplots(figsize=(12, 5))
x = range(len(df))

ax.bar(x, stable_pct, color="#4C72B0", label="Stable (conserved without variation)", width=0.9)
ax.bar(x, volatile_pct, bottom=stable_pct, color="#C44E52", label="Volatile (structural variation)", width=0.9)

ax.axhline(mean_stability, color="black", linestyle="--", linewidth=1,
           label=f"Cohort mean stability ({mean_stability:.1f}%)")

ax.set_xlabel("Patient lineage (ordered by decreasing prophage stability)")
ax.set_ylabel("Proportion of prophage elements (%)")
ax.set_title("Prophage stability profile across host clonal lineages")
ax.set_xlim(-0.5, len(df) - 0.5)
ax.set_ylim(0, 100)
ax.set_xticks([])  # too many patients (69) to label individually
ax.legend(loc="upper right", bbox_to_anchor=(1.0, -0.12), ncol=3, frameon=False)

plt.tight_layout()
plt.savefig("figure_4.6_prophage_stability.png", dpi=300, bbox_inches="tight")
plt.savefig("figure_4.6_prophage_stability.pdf", bbox_inches="tight")
print(f"Saved figure. Cohort mean stability: {mean_stability:.2f}%")
print(f"Number of lineages at 100% stability: {(stable_pct == 100).sum()}")
print(f"Number of lineages at 0% stability: {(stable_pct == 0).sum()}")
