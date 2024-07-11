#!/usr/bin/env nextflow
nextflow.enable.dsl = 2
include { is_available_workflow } from './lib/nf/functions'

if (is_available_workflow(params.wf)) {
    if (params.workflows[params.wf].containsKey('is_workflow')) {
        if (params.wf == "staphopia") {
            include { STAPHOPIA } from './workflows/staphopia'
        } else if (params.wf == "cleanyerreads") {
            include { CLEANYERREADS } from './workflows/clean-yer-reads'
        } else if (params.wf == "teton") {
            include { TETON } from './workflows/teton'
        } else if (params.wf == "updater") {
            include { UPDATER } from './workflows/updater'
        } else {
            include { braseqtb } from './workflows/braseqtb'
        }
    } else {
        include { braseqtbTOOLS } from './workflows/braseqtb-tools'
    }
} else {
    log.error "${params.wf} is not an available workflow or braseqtb Tool. Use --list_wfs to see full list"
    exit 1
}

/*
========================================================================================
    RUN WORKFLOWS
========================================================================================
*/

workflow {
    if (params.workflows[params.wf].containsKey('is_workflow')) {
        if (params.wf == "staphopia") {
            STAPHOPIA()
        } else if (params.wf == "cleanyerreads") {
            CLEANYERREADS()
        } else if (params.wf == "teton") {
            TETON()
        } else if (params.wf == "updater") {
            UPDATER()
        } else {
            braseqtb()
        }
    } else {
        braseqtbTOOLS()
    }
}

/*
========================================================================================
    THE END
========================================================================================
*/
