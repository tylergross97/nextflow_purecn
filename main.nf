#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// Set default parameters
params.outdir_base = params.outdir_base ?: 'results'
params.outdir_purecn = params.outdir_purecn ?: "${params.outdir_base}/purecn"
params.outdir_references = params.outdir_references ?: "${params.outdir_base}/references"

include { CNS_TO_SEG } from './modules/cns_to_seg.nf'
include { PURECN } from './modules/purecn.nf'

// Parameter validation function
def validateParameters() {
    def requiredParams = [
        'samplesheet': params.samplesheet,
        'snp_blacklist': params.snp_blacklist,
        'outdir_base': params.outdir_base
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
    
    // Validate that snp_blacklist exists (handle relative/absolute paths)
    def snp_blacklist_file = params.snp_blacklist.startsWith('/') ?
        file(params.snp_blacklist) :
        file("${projectDir}/${params.snp_blacklist}")
    
    if (!snp_blacklist_file.exists()) {
        error "SNP blacklist file not found: ${params.snp_blacklist}"
    }
}

// Function to set derived parameters
def setDerivedParameters() {
    if (params.outdir_base) {
        // Always set these parameters if outdir_base is provided
        params.outdir_purecn = params.outdir_purecn ?: "${params.outdir_base}/purecn"
        params.outdir_references = params.outdir_references ?: "${params.outdir_base}/references"
    }
}

// Helper function to handle flexible file paths
def resolveFilePath(path) {
    return path.startsWith('/') ? file(path) : file("${projectDir}/${path}")
}

workflow {
    // Validate parameters (skip if using test profile)
    if (workflow.profile != 'test') {
        validateParameters()
    }
    
    // Set derived parameters
    setDerivedParameters()

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

	CNS_TO_SEG(
        ch_samplesheet.map { sample_id, tumor_cns, tumor_cnr, vcf ->
            [sample_id, tumor_cns]
        }
    )
	PURECN(
        CNS_TO_SEG.out.seg
            .join(
                ch_samplesheet.map { sample_id, tumor_cns, tumor_cnr, vcf ->
                    [sample_id, tumor_cnr, vcf]
                }
            )
            .map { sample_id, seg, tumor_cnr, vcf -> 
                [sample_id, seg, tumor_cnr, vcf]
            }
            .combine(ch_snp_blacklist)
            .map { sample_id, seg, tumor_cnr, vcf, snp_blacklist ->
                [sample_id, seg, snp_blacklist, tumor_cnr, vcf]}
    )	
}
