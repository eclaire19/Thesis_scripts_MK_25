#!/bin/bash
set -e

VCF_DIR="."
OUT_DIR="./pao1_analysis"
mkdir -p $OUT_DIR/temp_vcf

echo "--- Fixing Duplicate Sample Names ---"

# 1. Create unique VCFs in a temp folder
for f in $VCF_DIR/*.vcf.gz; do
    # Extract the filename without path or extension to use as the new ID
    SAMPLE_ID=$(basename "$f" .vcf.gz)
    
    echo "$SAMPLE_ID" > "$OUT_DIR/temp_vcf/${SAMPLE_ID}.name"
    
    # Rehead the VCF so the internal name matches the filename
    bcftools reheader -s "$OUT_DIR/temp_vcf/${SAMPLE_ID}.name" "$f" -o "$OUT_DIR/temp_vcf/${SAMPLE_ID}.relabeled.vcf.gz"
    
    # Index the new file (Required for merging)
    tabix -p vcf "$OUT_DIR/temp_vcf/${SAMPLE_ID}.relabeled.vcf.gz"
done

# 2. Create the new list of RELABELED files
ls $OUT_DIR/temp_vcf/*.relabeled.vcf.gz > $OUT_DIR/renamed_samples.list

# 3. Perform the Merge
echo "Merging 341 unique samples..."
bcftools merge -l $OUT_DIR/renamed_samples.list -Oz -o $OUT_DIR/merged_pao1.vcf.gz

# 4. Filter for Core SNPs (Sites present in 90% of samples)
bcftools view -i 'F_MISSING < 0.1' $OUT_DIR/merged_pao1.vcf.gz -v snps -Oz -o $OUT_DIR/core_snps.vcf.gz

echo "--- SUCCESS! ---"