// Import generic module functions
include { get_resources } from '../../../../lib/nf/functions'
RESOURCES   = get_resources(workflow.profile, params.max_memory, params.max_cpus)
conda_tools = "bioconda::gnu-wget=1.18"
conda_name  = conda_tools.replace("=", "-").replace(":", "-").replace(" ", "-")
conda_env   = file("${params.condadir}/${conda_name}").exists() ? "${params.condadir}/${conda_name}" : conda_tools

process DATASETS {
    label "process_low"
    storeDir params.datasets_cache
    publishDir params.datasets_cache

    conda (params.enable_conda ? conda_env : null)
    container "${ workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gnu-wget:1.18--h60da905_7' :
        'quay.io/biocontainers/gnu-wget:1.18--h60da905_7' }"

    output:
    path("${braseqtb_version}/amrfinderplus.tar.gz")   , emit: amrfinderplus_db
    path("${braseqtb_version}/mlst.tar.gz")            , emit: mlst_db
    path("mash-refseq88.k21.msh.xz")                   , emit: mash_db
    path("gtdb-rs207.genomic-reps.dna.k31.lca.json.gz"), emit: sourmash_db

    script:
    braseqtb_version = params.amrfinder_url.replace("https://datasets.braseqtb.com/datasets/","").replace("/amrfinderplus.tar.gz","")
    """
    mkdir -p ${braseqtb_version}
    wget -O ${braseqtb_version}/amrfinderplus.tar.gz ${params.amrfinder_url}
    wget -O ${braseqtb_version}/mlst.tar.gz ${params.mlst_url}
    wget -O gtdb-rs207.genomic-reps.dna.k31.lca.json.gz ${params.sourmash_url}
    wget -O mash-refseq88.k21.msh.xz ${params.mash_url}
    """
}
