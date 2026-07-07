process SAMTOOLS_SORT_INDEX {

    tag "$sample_id"

    publishDir "${params.outdir}/dorado/sorted", mode: 'copy'

    container "${params.containers.samtools}"

    input:
    tuple val(sample_id), path(raw_bam)

    output:
    tuple val(sample_id),
          path("${sample_id}.calls.sorted.bam"),
          path("${sample_id}.calls.sorted.bam.bai"),
          emit: bams

    script:
    """
    set -euo pipefail

    samtools sort \\
        -@ ${task.cpus} \\
        -m 3G \\
        -o ${sample_id}.calls.sorted.bam \\
        ${raw_bam}

    samtools index \\
        -@ ${task.cpus} \\
        ${sample_id}.calls.sorted.bam
    """
}