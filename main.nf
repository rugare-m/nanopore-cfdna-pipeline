nextflow.enable.dsl = 2

include { DORADO_BASECALL } from './modules/dorado'
include { SAMTOOLS_SORT_INDEX } from './modules/samtools'
include { ICHORCNA_READCOUNTER; ICHORCNA_RUN } from './modules/ichorcna'
include { CLAIRS } from './modules/clairs'
include { MODKIT } from './modules/modkit'


params.pod5s     = ".../pod5/*"
params.reference = ".../hg19/hg19.fa"
params.outdir    = "results"

params.dorado_model = "hac,5mCG_5hmCG"

params.chromosomes = "chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10," +
                     "chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19," +
                     "chr20,chr21,chr22,chrX,chrY"


if (!params.pod5s) {
    error "Please provide POD5 input with --pod5s '/path/to/pod5s' or --pod5s '/path/to/pod5s/barcode*'"
}

if (!params.reference) {
    error "Please provide a reference FASTA with --reference /path/to/reference.fa"
}


def get_sample_id_from_pod5(pod5_dir) {
    return pod5_dir.name
}


def pod5_pattern = params.pod5s


workflow {

    /*
     * POD5 input channel
     *
     * If params.pod5s is a single directory:
     *   sample_id = directory name
     *
     * If params.pod5s is a wildcard:
     *   each matched directory becomes one sample
     */
    pod5_ch = Channel
        .fromPath(pod5_pattern, type: 'dir', checkIfExists: true)
        .map { pod5_dir ->
            def sample_id = get_sample_id_from_pod5(pod5_dir)
            tuple(sample_id, pod5_dir)
        }


    /*
     * Reference FASTA and FASTA index
     */
    ref_fasta = file(params.reference, checkIfExists: true)
    ref_fai   = file("${params.reference}.fai", checkIfExists: true)


    /*
     * Dorado basecalling
     */
    DORADO_BASECALL(pod5_ch, ref_fasta, ref_fai)


    /*
     * Samtools sort and index
     */
    SAMTOOLS_SORT_INDEX(DORADO_BASECALL.out.raw_bams)

    bam_ch = SAMTOOLS_SORT_INDEX.out.bams


    /*
     * ichorCNA
     */
    ICHORCNA_READCOUNTER(bam_ch)
    ICHORCNA_RUN(ICHORCNA_READCOUNTER.out)


    /*
     * ClairS
     */
    clairs_ch = bam_ch.map { sample_id, bam, bai ->
        tuple(sample_id, bam, bai, ref_fasta, ref_fai)
    }

    CLAIRS(clairs_ch)


    /*
     * modkit
     */
    modkit_ch = bam_ch.map { sample_id, bam, bai ->
        tuple(sample_id, bam, bai, ref_fasta, ref_fai)
    }

    MODKIT(modkit_ch)
}
