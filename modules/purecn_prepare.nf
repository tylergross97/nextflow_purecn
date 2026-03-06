process PURECN_PREPARE {
    container 'community.wave.seqera.io/library/bioconductor-dnacopy_bioconductor-org.hs.eg.db_bioconductor-purecn_bioconductor-txdb.hsapiens.ucsc.hg38.knowngene_pruned:781730955298c6e4'
    
    input:
    val sample_id
    
    output:
    tuple val(sample_id), stdout, emit: purecn_env

    script:
    """
    # Set PURECN path and output to stdout
    Rscript -e "cat(system.file('extdata', package='PureCN'))"
    """
    
    stub:
    """
    echo -n "/usr/local/lib/R/site-library/PureCN/extdata"
    """
}
