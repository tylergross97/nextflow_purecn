

# Nextflow nf-core/sarek (Mutect2+CNVKit) --> PureCN

This pipeline is designed to run PureCN on the output of nf-core/sarek in tumor-normal mode with Mutect2 and CNVKit to generate clonality estaimtes of somatic variants

## Workflow
```mermaid
flowchart TB
  subgraph " "
    subgraph params
      v7["samplesheet"]
      v1["snp_blacklist"]
      v5["gtf"]
      v3["fasta"]
    end
    v9([CNS_TO_SEG])
    v10([PURECN])
    v7 --> v9
    v1 --> v10
    v3 --> v10
    v5 --> v10
    v7 --> v10
    v9 --> v10
  end
```

## How to run pipeline
```bash
nextflow run tylergross97/nextflow_purecn \
  --samplesheet /path/to/samplesheet \
  --snp_blacklist /path/to/snp_blacklist \
  --outdir_base /path/to/outdir_base \
  -profile docker_or_singularity 
```

### Command Line Arguments

#### Samplesheet

```bash
sample_id,tumor_cnr,tumor_cns,vcf
<sample_tumor_vs_normal>,<path_to_tumor.cnr>,<path_to_tumor.cns>,<path_to_filtered.vcf.gz>
<sample_tumor_vs_normal>,<path_to_tumor.cnr>,<path_to_tumor.cns>,<path_to_filtered.vcf.gz>
<sample_tumor_vs_normal>,<path_to_tumor.cnr>,<path_to_tumor.cns>,<path_to_filtered.vcf.gz>
<sample_tumor_vs_normal>,<path_to_tumor.cnr>,<path_to_tumor.cns>,<path_to_filtered.vcf.gz>
```

#### SNP Blacklist

Path to hg38_encode_blacklist.bed file

#### outdir_base

#### fasta

Path to hg38 primary assembly .fa

#### gtf

Path to hg38 primary assembly .gtf

### Testing
To test pipeline with a minimal dataset, run pipeline with:
```bash
nextflow run tylergross97/nextflow_purecn -profile test,docker_or_singularity
```
The author parameters are predefined if running test profile

## Citations
If you use this pipeline in your work, please cite: [Tyler Gross] (2025). PureCN Nextflow Pipeline [Computer Software]. https://github.com/tylergross97/nextflow_purecn

This pipeline uses the following tools that should be cited independently:
1. Di Tommaso, P., Chatzou, M., Floden, E. W., Barja, P. P., Palumbo, E., & Notredame, C. (2017). Nextflow enables reproducible computational workflows. Nature biotechnology, 35(4), 316-319.
2. Riester, M., Singh, A. P., Brannon, A. R., Yu, K., Campbell, C. D., Chiang, D. Y., & Morrissey, M. P. (2016). PureCN: copy number calling and SNV classification using targeted short read sequencing. Source code for biology and medicine, 11(1), 13.
