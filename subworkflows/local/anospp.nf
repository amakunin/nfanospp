//
// Check input samplesheet and get read channels
//

include { ANOSPPPREP } from '../../modules/local/anosppprep'
include { ANOSPPQC } from '../../modules/local/anosppqc'

workflow ANOSPP {
    take:
    dada_table // file: /path/to/dada_table.tsv
    adapters_fa // file: /path/to/adapters.fa
    dada_stats // file: /path/to/dada_stats.tsv
    manifest // file: /path/to/manifest.tsv

    main:
    ch_versions = Channel.empty()

    ANOSPPPREP ( dada_table, adapters_fa )
    ch_versions = ch_versions.mix ( ANOSPPPREP.out.versions )

    ANOSPPQC ( ANOSPPPREP.out.haps_tsv, manifest, dada_stats )
    ch_versions = ch_versions.mix ( ANOSPPPREP.out.versions )

    emit:
    qc_plots = ANOSPPQC.out.qc_plots // channel: [ val(meta), [ reads ] ]
    versions = ch_versions // channel: [ versions.yml ]
}


