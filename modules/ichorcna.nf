process ICHORCNA_READCOUNTER {

    tag "$sample_id"

    publishDir "${params.outdir}/ichorcna/wig", mode: 'copy'

    cpus 8
    memory '32 GB'
    time '12h'

    input:
    tuple val(sample_id), path(bam), path(bai)

    output:
    tuple val(sample_id), path("${sample_id}.wig")

    script:
    def chroms = [
        'chr1','chr2','chr3','chr4','chr5','chr6','chr7','chr8','chr9','chr10',
        'chr11','chr12','chr13','chr14','chr15','chr16','chr17','chr18','chr19',
        'chr20','chr21','chr22','chrX','chrY'
    ].join(',')

    """
    readCounter \\
        --window 1000000 \\
        --quality 20 \\
        --chromosome "${chroms}" \\
        ${bam} > ${sample_id}.wig
    """
}


process ICHORCNA_RUN {

    tag "$sample_id"

    publishDir "${params.outdir}/ichorcna/results", mode: 'copy'

    cpus 4
    memory '16 GB'
    time '12h'

    input:
    tuple val(sample_id), path(wig)

    output:
    tuple val(sample_id), path("ichorcna_${sample_id}")

    script:
    """
    mkdir -p ichorcna_${sample_id}

     Rscript /usr/local/bin/ichorCNA/scripts/runIchorCNA.R \\
        --id ${sample_id} \\
        --WIG ${wig} \\
        --gcWig /usr/local/bin/ichorCNA/inst/extdata/gc_hg19_1000kb.wig \\
        --mapWig /usr/local/bin/ichorCNA/inst/extdata/map_hg19_1000kb.wig \\
        --genomeBuild hg38 \\
        --genomeStyle UCSC \\
        --chrs "c(paste0('chr', 1:22), 'chrX')" \\
        --chrTrain "c(paste0('chr', 1:22))" \\
        --outDir ichorcna_${sample_id}
    """
}