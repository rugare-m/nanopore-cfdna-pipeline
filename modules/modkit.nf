process MODKIT {

    tag "$sample_id"

    cpus 8
    memory '32 GB'
    time '12h'

    publishDir "${params.outdir}/modkit", mode: 'copy'

    input:
    tuple val(sample_id), path(bam), path(bai), path(ref_fasta), path(ref_fai)

    output:
    tuple val(sample_id), path("${sample_id}.modkit.pileup.bed")

    script:
    """
    modkit pileup \\
        ${bam} \\
        ${sample_id}.modkit.pileup.bed \\
        --modified-bases 5mC 5hmC \\
        --combine-mods \\
        --ref ${ref_fasta} \\
        --cpg \\
        --threads ${task.cpus} \\
        --io-threads ${task.cpus}
    """
}