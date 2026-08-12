#!/bin/bash
#SBATCH --partition=compute
#SBATCH --nodes=2
#SBATCH --exclusive
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=w22062555@northumbria.ac.uk
set -u

# Directory containing FASTA assemblies
READS_BASE_DIR="."                   # Where your .fasta assemblies are
# Directory containing FASTQ read files
FASTQ_BASE_DIR="/home/crk_w22062555/Imperial_fastqs"      # CHANGE this to your fastq directory
OUTPUT_DIR="consensus_outputs"
THREADS=16

mkdir -p "$OUTPUT_DIR"

# Loop over all fasta assemblies
for ASSEMBLY_FILE in "$READS_BASE_DIR"/*.fasta; do
    SAMPLE_NAME=$(basename "$ASSEMBLY_FILE" .fasta)
    FAI_FILE="$READS_BASE_DIR/${SAMPLE_NAME}.fasta.fai"

    # Skip if .fai exists
    if [[ -f "$FAI_FILE" ]]; then
        echo "✅ Skipping $SAMPLE_NAME — .fai file exists."
        continue
    fi

    echo "🔍 Processing sample: $SAMPLE_NAME"

    # Find the matching FASTQ in the FASTQ directory
    READ_FILE=$(find "$FASTQ_BASE_DIR" -maxdepth 1 -type f \
        \( -iname "${SAMPLE_NAME}*.fastq" -o -iname "${SAMPLE_NAME}*.fq" \
        -o -iname "${SAMPLE_NAME}*.fastq.gz" -o -iname "${SAMPLE_NAME}*.fq.gz" \) \
        | head -n 1)

    if [[ ! -f "$READ_FILE" ]]; then
        echo "⚠️ No FASTQ file found for sample $SAMPLE_NAME — skipping"
        continue
    fi

    echo "📂 Reads:    $READ_FILE"
    echo "📂 Assembly: $ASSEMBLY_FILE"

    SAMPLE_OUTDIR="$OUTPUT_DIR/$SAMPLE_NAME"
    mkdir -p "$SAMPLE_OUTDIR"

    BAM="$SAMPLE_OUTDIR/aligned.bam"
    VCF="$SAMPLE_OUTDIR/calls.vcf.gz"
    CONSENSUS_FASTA="$SAMPLE_OUTDIR/consensus.fasta"

    echo "🧬 Aligning reads to assembly..."
    pbmm2 align "$ASSEMBLY_FILE" "$READ_FILE" "$BAM" --preset CCS --sort --num-threads "$THREADS"
    samtools index "$BAM"

    echo "🔧 Indexing assembly..."
    samtools faidx "$ASSEMBLY_FILE"

    echo "📊 Calling variants..."
    bcftools mpileup -Ou -f "$ASSEMBLY_FILE" "$BAM" | \
      bcftools call -mv -Oz -o "$VCF"
    bcftools index "$VCF"

    echo "🧬 Creating consensus FASTA..."
    bcftools consensus "$VCF" -f "$ASSEMBLY_FILE" > "$CONSENSUS_FASTA"
    samtools faidx "$CONSENSUS_FASTA"

    echo "✅ Done: $SAMPLE_NAME → $CONSENSUS_FASTA"
    echo "-----------------------------------------"

done

