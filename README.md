# Nanopore cfDNA Nextflow Pipeline

A containerised Nextflow workflow for Oxford Nanopore cfDNA analysis on HPC.
This pipeline supports basecalling, BAM processing, methylation extraction, variant calling, and copy-number analysis using tools including Dorado, samtools, modkit, ClairS, and ichorCNA. It is designed to run on a SLURM cluster using Apptainer/Singularity containers.

## Overview

This workflow was developed for analysing Oxford Nanopore cfDNA sequencing data in a reproducible HPC environment. It combines multiple stages of long-read sequencing analysis into a single Nextflow pipeline, with each major tool isolated in its own container.

The pipeline currently includes:

* Dorado basecalling
* BAM sorting and indexing with samtools
* Methylation extraction with modkit
* Somatic/small variant calling with ClairS-TO
* CNV analysis with ichorCNA
* SLURM-based resource management
* Apptainer/Singularity container support

## Repository structure

```text
.
├── main.nf
├── nextflow.config
├── README.md
└── containers/
```

## Requirements

This pipeline is intended for Linux HPC environments and requires:

* Nextflow
* SLURM
* Apptainer or Singularity
* Access to GPU nodes for Dorado basecalling
* Oxford Nanopore input data
* Reference genome files 

The workflow has been configured for a SLURM executor and uses Apptainer containers for reproducibility.

## Tools used

| Tool     | Purpose                                                |
| -------- | ------------------------------------------------------ |
| Dorado   | Oxford Nanopore basecalling                            |
| samtools | BAM sorting and indexing                               |
| modkit   | Methylation extraction from modified-base BAMs         |
| ClairS-TO| Somatic variant calling from long-read sequencing data in tumour only mode |
| ichorCNA | Copy-number and tumour fraction estimation             |

## Configuration

The workflow uses a Nextflow configuration file to define container paths, SLURM resources, work directories, and Apptainer bind mounts.

Example container configuration:

```groovy
params {
    containers = [
        dorado  : "/path/to/dorado.sif",
        samtools: "/path/to/samtools.sif",
        clairs  : "/path/to/clairs.sif",
        modkit  : "/path/to/modkit.sif",
        ichorcna: "/path/to/ichorcna.sif"
    ]
}
```

The work directory can be configured as:

```groovy
workDir = "/path/to/nextflow_work"
```

SLURM resources are assigned per process using `withName` blocks. For example:

```groovy
process {
    executor = "slurm"

    withName: "CLAIRS" {
        cpus   = 64
        memory = "256 GB"
        time   = "48h"
    }
```

GPU hardware is required for Dorado basecalling:

```groovy
withName: DORADO_BASECALL {
    cpus = 16
    memory = "96 GB"
    time = "48h"
    clusterOptions = "--gres=gpu:1"
    containerOptions = "--nv"
}
```

## Apptainer configuration

Apptainer is enabled in the Nextflow config:

```groovy
apptainer {
    enabled = true
    autoMounts = true
    runOptions = "--bind /scratch,/users,/tmp"
}
```

## Running the pipeline

A typical run may look like:

```bash
nextflow run main.nf \
    -profile slurm \
    --input /path/to/input \
    --outdir /path/to/results \
    --reference /path/to/reference.fa
```

## Development status

This pipeline is under active development and was designed for research use in an HPC setting. Additional validation, parameterisation, and documentation may be required before use in production or clinical workflows.

## Author

Rugare Maruzani
