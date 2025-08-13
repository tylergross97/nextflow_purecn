process CNS_TO_SEG {
	container "community.wave.seqera.io/library/cnvkit:0.9.12--0f8b2dcdee7508b0"
	publishDir params.outdir_references, mode: 'copy'

	input:
	tuple val(sample_id), path(cns_file)

	output:
	tuple val(sample_id), path("${sample_id}.seg"), emit: seg

	script:
	"""
    # Generate seg file with CNVkit
    cnvkit.py export seg ${cns_file} --enumerate-chroms -o ${sample_id}.seg
	
    # Replace the ID column with our sample_id
    awk -v id="${sample_id}" 'BEGIN {OFS="\\t"} NR==1 {\$1="ID"} NR>1 {\$1=id} {print}' ${sample_id}.seg > ${sample_id}.seg.tmp

    mv ${sample_id}.seg.tmp ${sample_id}.seg
	"""

    stub:
    """
    # Create a mock SEG file with proper format for testing
    cat > ${sample_id}.seg << 'EOF'
		ID	chrom	loc.start	loc.end	num.mark	seg.mean
		${sample_id}	chr1	1000000	2000000	100	0.1
		${sample_id}	chr1	3000000	4000000	150	-0.2
		${sample_id}	chr2	1000000	1500000	75	0.3
	EOF
    """
}
