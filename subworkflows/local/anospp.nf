//
// Check input samplesheet and get read channels
//

include { ANOSPPPREP } from '../../modules/local/anosppprep'
include { ANOSPPQC } from '../../modules/local/anosppqc'
include { ANOSPPNN } from '../../modules/local/anosppnn'
include { ANOSPPVAE } from '../../modules/local/anosppvae'
include { ANOSPPPLASM } from '../../modules/local/anosppplasm'

workflow ANOSPP {
    take:
    dada_table // file: /path/to/dada_table.tsv
    adapters_fa // file: /path/to/adapters.fa
    dada_stats // file: /path/to/dada_stats.tsv
    manifest // file: /path/to/manifest.tsv
    ref_dir // dir: /path/to/ref/data
    nn_ref_version // value: nnv1
    vae_ref_version // value: gcrefv1
    plasm_ref_version // value: plasmv1

    main:
    ch_versions = Channel.empty()

    ANOSPPPREP ( dada_table, adapters_fa )
    ch_versions = ch_versions.mix ( ANOSPPPREP.out.versions )

    ANOSPPQC ( ANOSPPPREP.out.haps_tsv, manifest, dada_stats )
    ch_versions = ch_versions.mix ( ANOSPPPREP.out.versions )

    ANOSPPNN ( ANOSPPPREP.out.haps_tsv, manifest, dada_stats, ref_dir, nn_ref_version )
    ch_versions = ch_versions.mix ( ANOSPPNN.out.versions )

    ANOSPPVAE ( ANOSPPNN.out.nn_haps_tsv, ANOSPPNN.out.nn_assignment, ref_dir, vae_ref_version )
    ch_versions = ch_versions.mix ( ANOSPPVAE.out.versions )

    ANOSPPPLASM ( ANOSPPPREP.out.haps_tsv, manifest, dada_stats, ref_dir, plasm_ref_version )
    ch_versions = ch_versions.mix ( ANOSPPNN.out.versions )

    emit:
    qc_plots = ANOSPPQC.out.qc_plots // channel: [ val(meta), [ reads ] ]
    versions = ch_versions // channel: [ versions.yml ]
}


