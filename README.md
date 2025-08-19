# Nextflow nf-core/sarek (Mutect2+CNVKit) --> PureCN

This pipeline is designed to run PureCN on the output of nf-core/sarek in tumor-normal mode with Mutect2 and CNVKit to generate clonality estaimtes of somatic variants

## Command Line Arguments

- Samplesheet

```bash
sample_id,tumor_cnr,tumor_cns,vcf
<sample_tumor_vs_normal>,<path_to_tumor.cnr>,<path_to_tumor.cns>,<path_to_filtered.vcf.gz>
<sample_tumor_vs_normal>,<path_to_tumor.cnr>,<path_to_tumor.cns>,<path_to_filtered.vcf.gz>
<sample_tumor_vs_normal>,<path_to_tumor.cnr>,<path_to_tumor.cns>,<path_to_filtered.vcf.gz>
<sample_tumor_vs_normal>,<path_to_tumor.cnr>,<path_to_tumor.cns>,<path_to_filtered.vcf.gz>
```

- SNP Blacklist

Path to hg38_encode_blacklist.bed file

- Outdir_base

- fasta

Path to hg38 primary assembly .fa

- gtf

Path to hg38 primary assembly .gtf