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
    
    mkdir purecn_output
    
    Rscript \$PURECN/PureCN.R \\
        --out ${sample_id}_purecn_output \\
        --sampleid ${sample_id} \\
        --tumor ${tumor_cnr} \\
        --seg-file ${seg} \\
        --vcf ${vcf} \\
	    --snp-blacklist ${snp_blacklist} \\
        --genome hg19 \\
        --fun-segmentation Hclust \\
	    --min-base-quality 20 \\
        --force --post-optimize --seed 123
    """
}
