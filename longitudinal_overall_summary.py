import pandas as pd

df = pd.read_csv("longitudinal_carriage_summary_v2.tsv", sep="\t")

total_initial = df["initial_count"].sum()
total_final = df["final_count"].sum()
total_retained = df["retained_computed"].sum()
total_lost = df["lost_computed"].sum()
total_gained = df["gained_computed"].sum()

print(f"Total comparisons: {len(df)}")
print(f"Total initial phage instances: {total_initial}")
print(f"Total final phage instances: {total_final}")
print(f"Total retained: {total_retained}")
print(f"Total lost: {total_lost}")
print(f"Total gained: {total_gained}")
print()
print(f"Proportion of initial phages retained: {100*total_retained/total_initial:.1f}%")
print()
print("Distribution of retained count per comparison:")
print(df["retained_computed"].describe())
print()
print(f"Comparisons with zero retained phages (complete turnover): {(df['retained_computed']==0).sum()} / {len(df)}")
print(f"Comparisons with 100% retention (no loss or gain): {((df['lost_computed']==0) & (df['gained_computed']==0)).sum()} / {len(df)}")
