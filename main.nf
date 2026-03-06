#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// Set default parameters
params.outdir_base = params.outdir_base ?: 'results'
params.outdir_purecn = params.outdir_purecn ?: "${params.outdir_base}/purecn"
params.outdir_references = params.outdir_references ?: "${params.outdir_base}/references"

include { CNS_TO_SEG } from './modules/cns_to_seg.nf'
include { PURECN_PREPARE } from './modules/purecn_prepare.nf'
include { PURECN_RUN } from './modules/purecn_run.nf'
include { PURECN_PARSE_RESULTS } from './modules/purecn_parse_results.nf'

// Parameter validation function
def validateParameters() {
    def requiredParams = [
        'samplesheet': params.samplesheet,
        'snp_blacklist': params.snp_blacklist,
        'outdir_base': params.outdir_base,
    ]
    
    def missingParams = []
    requiredParams.each { name, value ->
        if (value == null || value == '') {
            missingParams.add("--${name}")
        }
    }
    
    if (missingParams.size() > 0) {
        error """
        Missing required parameters: ${missingParams.join(', ')}
        
        Please provide all required parameters on the command line:
        
        Example usage:
        nextflow run main.nf \\
            --samplesheet 'samplesheet.csv' \\
            --snp_blacklist 'tests/data/hg38_encode_blacklist.bed' \\
            --outdir_base 'results'
        
        Or use the test profile:
        nextflow run main.nf -profile test
        """
    }
    
    // Validate that samplesheet exists
    if (!file(params.samplesheet).exists()) {
        error "Samplesheet file not found: ${params.samplesheet}"
    }
    
    // Validate that snp_blacklist exists (handle relative/absolute/S3 paths)
    def snp_blacklist_file = (params.snp_blacklist.startsWith('/') || params.snp_blacklist.contains('://')) ?
        file(params.snp_blacklist) :
        file("${projectDir}/${params.snp_blacklist}")
    
    if (!snp_blacklist_file.exists()) {
        error "SNP blacklist file not found: ${params.snp_blacklist}"
    }
}

// Helper function to handle flexible file paths (local absolute, relative, or S3/cloud URIs)
def resolveFilePath(path) {
    return (path.startsWith('/') || path.contains('://')) ? file(path) : file("${projectDir}/${path}")
}

workflow {
    // Validate parameters (skip if using test profile)
    if (workflow.profile != 'test') {
        validateParameters()
    }

    ch_snp_blacklist = Channel.value(resolveFilePath(params.snp_blacklist))

    ch_samplesheet = Channel
        .fromPath(params.samplesheet)
        .splitCsv(header: true)
        .map { row ->
            tuple(
                row.sample_id,
                resolveFilePath(row.tumor_cns),
                resolveFilePath(row.tumor_cnr),
                resolveFilePath(row.vcf)
            )
        }

    // Step 1: Convert CNS to SEG format
    CNS_TO_SEG(
        ch_samplesheet.map { sample_id, tumor_cns, _tumor_cnr, _vcf ->
            [sample_id, tumor_cns]
        }
    )

    // Step 2: Prepare PureCN environment for each sample
    PURECN_PREPARE(
        ch_samplesheet.map { sample_id, _tumor_cns, _tumor_cnr, _vcf ->
            sample_id
        }
    )

    // Step 3: Run main PureCN analysis with prepared environment
    PURECN_RUN(
        PURECN_PREPARE.out.purecn_env
            .join(CNS_TO_SEG.out.seg)
            .join(
                ch_samplesheet.map { sample_id, _tumor_cns, tumor_cnr, vcf ->
                    [sample_id, tumor_cnr, vcf]
                }
            )
            .combine(ch_snp_blacklist)
            .map { sample_id, purecn_path, seg, tumor_cnr, vcf, snp_blacklist ->
                [sample_id, purecn_path, seg, snp_blacklist, tumor_cnr, vcf]
            }
    )

    // Step 4: Parse and summarize results
    PURECN_PARSE_RESULTS(
        PURECN_RUN.out.purecn_results
    )
}
