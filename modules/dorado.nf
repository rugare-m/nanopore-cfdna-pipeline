process DORADO_BASECALL {

    tag "$sample_id"

    publishDir "${params.outdir}/dorado/raw", mode: 'copy'

    container "${params.containers.dorado}"

    input:
    tuple val(sample_id), path(pod5_dir)
    path ref_fasta
    path ref_fai

    output:
    tuple val(sample_id), path("${sample_id}.calls.bam"), emit: raw_bams

    script:
    """
    set -euo pipefail

    nvidia-smi || true

    dorado basecaller \\
        --device cuda:0 \\
        --reference ${ref_fasta} \\
        hac,5mCG_5hmCG \\
        ${pod5_dir} \\
        > ${sample_id}.calls.bam
    """
}

