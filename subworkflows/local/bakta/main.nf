//
// bakta - Rapid annotation of bacterial genomes and plasmids
//
include { initOptions } from '../../../lib/nf/functions'
options = initOptions(params.containsKey("options") ? params.options : [:], 'bakta')
options.is_module = params.wf == 'bakta' ? true : false
options.args = [
    params.skip_trna ? "--skip-trna" : "",
    params.skip_tmrna ? "--skip-tmrna" : "",
    params.skip_rrna ? "--skip-rrna" : "",
    params.skip_ncrna ? "--skip-ncrna" : "",
    params.skip_ncrna_region ? "--skip-ncrna-region" : "",
    params.skip_crispr ? "--skip-crispr" : "",
    params.skip_cds ? "--skip-cds" : "",
    params.skip_sorf ? "--skip-sorf" : "",
    params.skip_gap ? "--skip-gap" : "",
    params.skip_ori ? "--skip-ori" : "",
    params.compliant ? "--compliant" : "",
    params.keep_contig_headers ? "--keep-contig-headers" : "",
    "--min-contig-length ${params.min_contig_length}",
    "${params.bakta_opts}"
].join(' ').replaceAll("\\s{2,}", " ").trim()
DATABASE = params.bakta_db ? file(params.bakta_db) : []
PROTEINS = params.proteins ? file(params.proteins) : []
PRODIGAL_TF = params.prodigal_tf ? file(params.prodigal_tf) : []
REPLICONS = params.replicons ? file(params.replicons) : []

include { BAKTA_DOWNLOAD } from '../../../modules/nf-core/bakta/download/main' addParams( )
include { BAKTA_RUN } from '../../../modules/nf-core/bakta/run/main' addParams( options: options )

workflow BAKTA {
    take:
    fasta // channel: [ val(meta), [ fasta ] ]

    main:
    ch_versions = Channel.empty()

    if (params.download_bakta) {
        // Force BAKTA_DOWNLOAD to wait
        BAKTA_DOWNLOAD()

        if (params.bakta_save_as_tarball) {
            BAKTA_RUN(fasta, BAKTA_DOWNLOAD.out.db_tarball, PROTEINS, PRODIGAL_TF, REPLICONS)
        } else {
            BAKTA_RUN(fasta, BAKTA_DOWNLOAD.out.db, PROTEINS, PRODIGAL_TF, REPLICONS)
        }
    } else {
        BAKTA_RUN(fasta, DATABASE, PROTEINS, PRODIGAL_TF, REPLICONS)
    }

    ch_versions = ch_versions.mix(BAKTA_RUN.out.versions.first())

    emit:
    annotations = BAKTA_RUN.out.annotations
    embl = BAKTA_RUN.out.embl
    faa = BAKTA_RUN.out.faa
    ffn = BAKTA_RUN.out.ffn
    fna = BAKTA_RUN.out.fna
    gbff = BAKTA_RUN.out.gbff
    gff = BAKTA_RUN.out.gff
    hypotheticals_tsv = BAKTA_RUN.out.hypotheticals_tsv
    hypotheticals_faa = BAKTA_RUN.out.hypotheticals_faa
    tsv = BAKTA_RUN.out.tsv
    blastdb = BAKTA_RUN.out.blastdb
    versions = ch_versions // channel: [ versions.yml ]
}
