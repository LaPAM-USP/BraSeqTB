//
// bracken - Estimate taxonomic abundance of samples from Kraken2 results
//
include { initOptions } from '../../../lib/nf/functions'
options = initOptions(params.containsKey("options") ? params.options : [:], 'bracken')
options.is_module = params.wf == 'bracken' ? true : false
options.args = [
    params.kraken2_quick_mode ? "--quick" : "",
    params.kraken2_use_mpa_style ? "--use-mpa-style" : "",
    params.kraken2_report_zero_counts ? "--report-zero-counts" : "",
    params.kraken2_report_minimizer_data ? "--report-minimizer-data" : "",
    params.kraken2_use_names ? "--use-names" : "",
    params.kraken2_memory_mapping ? "--memory-mapping" : "",
    "--confidence ${params.kraken2_confidence}",
    "--minimum-hit-groups ${params.kraken2_minimum_hit_groups}",
    "--minimum-base-quality ${params.kraken2_minimum_base_quality}"
].join(' ').replaceAll("\\s{2,}", " ").trim()

options.args2 = [
    "-l ${params.bracken_level}",
    "-t ${params.bracken_threshold}"
].join(' ').replaceAll("\\s{2,}", " ").trim()
DATABASE = params.kraken2_db ? file(params.kraken2_db) : []

include { BRACKEN as BRACKEN_MODULE } from '../../../modules/nf-core/bracken/main' addParams( options: options )

workflow BRACKEN {
    take:
    reads // channel: [ val(meta), [ fasta ] ]

    main:
    ch_versions = Channel.empty()

    BRACKEN_MODULE(reads, DATABASE)
    ch_versions = ch_versions.mix(BRACKEN_MODULE.out.versions)

    emit:
    tsv = BRACKEN_MODULE.out.tsv
    classified = BRACKEN_MODULE.out.classified
    unclassified = BRACKEN_MODULE.out.unclassified
    kraken2_report = BRACKEN_MODULE.out.kraken2_report
    kraken2_output = BRACKEN_MODULE.out.kraken2_output
    bracken_report = BRACKEN_MODULE.out.bracken_report
    abundances = BRACKEN_MODULE.out.abundances
    versions = ch_versions // channel: [ versions.yml ]
}
