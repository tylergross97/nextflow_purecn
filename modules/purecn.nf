process PURECN {
    container "community.wave.seqera.io/library/bioconductor-dnacopy_bioconductor-org.hs.eg.db_bioconductor-purecn_bioconductor-txdb.hsapiens.ucsc.hg38.knowngene_pruned:781730955298c6e4"
    
    publishDir params.outdir_purecn, mode: 'copy'

    input:
    tuple val(sample_id), path(seg), path(snp_blacklist), path(tumor_cnr), path(vcf), path(fasta), path(gtf)
    
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
        --fasta ${fasta} \\
        --gtf ${gtf} \\
        --fun-segmentation Hclust \\
	    --min-base-quality 20 \\
        --force --post-optimize --seed 123
    """
    
    stub:
    """
    # Create the output directory structure that PureCN would normally create
    mkdir -p ${sample_id}_purecn_output
    
    # Create typical PureCN output files for testing
    touch ${sample_id}_purecn_output/${sample_id}.csv
    touch ${sample_id}_purecn_output/${sample_id}.pdf
    touch ${sample_id}_purecn_output/${sample_id}_amplification_pvalues.csv
    touch ${sample_id}_purecn_output/${sample_id}_chromosomes.pdf
    touch ${sample_id}_purecn_output/${sample_id}_coverage_loess.pdf
    touch ${sample_id}_purecn_output/${sample_id}_genes.csv
    touch ${sample_id}_purecn_output/${sample_id}_local_optima.pdf
    touch ${sample_id}_purecn_output/${sample_id}_loh.csv
    touch ${sample_id}_purecn_output/${sample_id}_segmentation.pdf
    touch ${sample_id}_purecn_output/${sample_id}_variants.csv
    touch ${sample_id}_purecn_output/${sample_id}.log
    
    # Create a simple CSV with headers for the main results file
    echo "Sampleid,Purity,Ploidy,Sex,Contamination,Flagged,Curated,Comment" > ${sample_id}_purecn_output/${sample_id}.csv
    echo "${sample_id},0.75,2.1,F,0.02,FALSE,FALSE,Test stub output" >> ${sample_id}_purecn_output/${sample_id}.csv
    """
}