process PURECN_PARSE_RESULTS {
    container 'community.wave.seqera.io/library/bioconductor-dnacopy_bioconductor-org.hs.eg.db_bioconductor-purecn_bioconductor-txdb.hsapiens.ucsc.hg38.knowngene_pruned:781730955298c6e4'
    
    publishDir params.outdir_purecn, mode: 'copy', pattern: "*_summary.txt"

    input:
    tuple val(sample_id), path(purecn_output_dir)
    
    output:
    tuple val(sample_id), path("${sample_id}_summary.txt"), emit: summary
    tuple val(sample_id), path(purecn_output_dir), emit: full_results

    script:
    """
    #!/usr/bin/env Rscript
    
    # Read the main PureCN results CSV
    results_file <- file.path("${purecn_output_dir}", "${sample_id}.csv")
    
    if (file.exists(results_file)) {
        results <- read.csv(results_file, stringsAsFactors = FALSE)
        
        # Create a summary text file
        sink("${sample_id}_summary.txt")
        cat("PureCN Results Summary for Sample: ${sample_id}\\n")
        cat(paste(rep("=", 50), collapse = ""), "\\n\\n")
        
        if (nrow(results) > 0) {
            cat("Purity:", results\$Purity[1], "\\n")
            cat("Ploidy:", results\$Ploidy[1], "\\n")
            cat("Sex:", results\$Sex[1], "\\n")
            cat("Contamination:", results\$Contamination[1], "\\n")
            cat("Flagged:", results\$Flagged[1], "\\n")
            
            if ("Comment" %in% colnames(results) && !is.na(results\$Comment[1]) && results\$Comment[1] != "") {
                cat("Comment:", results\$Comment[1], "\\n")
            }
        } else {
            cat("No results found in CSV file\\n")
        }
        
        sink()
    } else {
        # Create empty summary if file doesn't exist
        writeLines(c(
            "PureCN Results Summary for Sample: ${sample_id}",
            paste(rep("=", 50), collapse = ""),
            "",
            "ERROR: Results file not found"
        ), "${sample_id}_summary.txt")
    }
    """
    
    stub:
    """
    cat > ${sample_id}_summary.txt << EOF
PureCN Results Summary for Sample: ${sample_id}
==================================================

Purity: 0.75
Ploidy: 2.1
Sex: F
Contamination: 0.02
Flagged: FALSE
EOF
    """
}
