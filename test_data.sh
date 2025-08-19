#!/bin/bash
# Script: prepare_synthetic_hg38.sh
# Purpose: Create a tiny synthetic "hg38" FASTA and GTF for testing PureCN
# Location: tests/data/

OUTDIR="tests/data"
mkdir -p "$OUTDIR"

cd "$OUTDIR"

# --- Create synthetic FASTA ---
cat <<EOT > synthetic_hg38.fa
>chr1
ATGCGTACGTAGCTAGCTAGCTAGCTAGCTAGCTAGCTAGCTAGCTAGCTAGCTAGC
>chr2
CGTAGCTAGCTAGCTAGCTAGCTAGCTAGCTAGCTAGCTAGCTAGCTAGCTAGCTAG
EOT

# --- Index the FASTA ---
if ! command -v samtools &> /dev/null; then
    echo "samtools not found, please install it first"
    exit 1
fi
samtools faidx synthetic_hg38.fa

# --- Create synthetic GTF ---
cat <<EOT > synthetic_hg38.gtf
chr1	.	gene	1	50	.	+	.	gene_id "GENE1"; gene_name "GENE1";
chr1	.	transcript	1	50	.	+	.	gene_id "GENE1"; transcript_id "TX1";
chr1	.	exon	1	50	.	+	.	gene_id "GENE1"; transcript_id "TX1";
chr2	.	gene	1	50	.	-	.	gene_id "GENE2"; gene_name "GENE2";
chr2	.	transcript	1	50	.	-	.	gene_id "GENE2"; transcript_id "TX2";
chr2	.	exon	1	50	.	-	.	gene_id "GENE2"; transcript_id "TX2";
EOT

echo "Synthetic FASTA and GTF created in $OUTDIR"
echo " - FASTA: synthetic_hg38.fa"
echo " - FASTA index: synthetic_hg38.fa.fai"
echo " - GTF: synthetic_hg38.gtf"

