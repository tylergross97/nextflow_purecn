process PURECN {
    container 'community.wave.seqera.io/library/bioconductor-dnacopy_bioconductor-org.hs.eg.db_bioconductor-purecn_bioconductor-txdb.hsapiens.ucsc.hg19.knowngene_pruned:cc846801cfba58d6'
    
    publishDir params.outdir_purecn, mode: 'copy'

    input:
    tuple val(sample_id), path(seg), path(snp_blacklist), path(tumor_cnr), path(vcf)

    output:
    tuple val(sample_id), path("${sample_id}_purecn_output"), emit: purecn_results

    script:
    """    
    # Set PURECN path
    export PURECN=\$(Rscript -e "cat(system.file('extdata', package='PureCN'))")

    mkdir -p ${sample_id}_purecn_output

    # --- FILTER ALT CONTIGS FROM VCF ---
    VCF_FILE="${vcf}"
    CNR_FILE="${tumor_cnr}"
    
    # Create filtered file names (avoid double extensions)
    VCF_FILTERED="${sample_id}.filtered.vcf"
    CNR_FILTERED="${sample_id}.filtered.cnr"
    
    # Create uncompressed filtered VCF
    zcat "\$VCF_FILE" \\
      | awk '/^#/ || \$1 ~ /^chr([1-9]|1[0-9]|2[0-2]|X|Y)\$/' \\
      > "\$VCF_FILTERED"

    # --- FILTER ALT CONTIGS FROM CNR ---
    awk 'NR==1 || \$1 ~ /^chr([1-9]|1[0-9]|2[0-2]|X|Y)\$/' "\$CNR_FILE" \\
      > "\$CNR_FILTERED"

    # --- RUN PURECN ON FILTERED FILES ---
    Rscript \$PURECN/PureCN.R \\
        --out ${sample_id}_purecn_output \\
        --sampleid ${sample_id} \\
        --tumor "\$CNR_FILTERED" \\
        --seg-file ${seg} \\
        --vcf "\$VCF_FILTERED" \\
        --snp-blacklist ${snp_blacklist} \\
        --genome hg19 \\
        --fun-segmentation Hclust \\
        --min-base-quality 20 \\
        --force --post-optimize --seed 123
    """
    
    stub:
    """
    mkdir -p ${sample_id}_purecn_output
    touch ${sample_id}_purecn_output/${sample_id}.csv
    echo "Sampleid,Purity,Ploidy,Sex,Contamination,Flagged,Curated,Comment" > ${sample_id}_purecn_output/${sample_id}.csv
    echo "${sample_id},0.75,2.1,F,0.02,FALSE,FALSE,Test stub output" >> ${sample_id}_purecn_output/${sample_id}.csv
    """
}
