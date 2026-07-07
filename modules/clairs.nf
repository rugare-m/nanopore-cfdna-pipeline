process CLAIRS {

    tag "$sample_id"

    cpus 8
    memory '64 GB'
    time '24h'

    publishDir "${params.outdir}/clairs", mode: 'copy'

    input:
    tuple val(sample_id), path(bam), path(bai), path(ref_fasta), path(ref_fai)

    output:
    tuple val(sample_id), path("${sample_id}_clairs")

    script:
    """
    run_clairs_to \\
        -T ${bam} \\
        -R ${ref_fasta} \\
        -o ${sample_id}_clairs \\
        -t ${task.cpus} \\
        -p ont_r10_dorado_sup_4khz
    """
}