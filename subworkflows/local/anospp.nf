//
// Check input samplesheet and get read channels
//

include { ANOSPPPREP } from '../../modules/local/anosppprep'
include { ANOSPPQC } from '../../modules/local/anosppqc'
include { ANOSPPPLASM } from '../../modules/local/anosppplasm'
include { ANOSPPNN } from '../../modules/local/anosppnn'
include { ANOSPPVAE } from '../../modules/local/anosppvae'
include { ANOSPPAGG } from '../../modules/local/anosppagg'


workflow ANOSPP {
    take:
    dada_table // file: /path/to/dada_table.tsv
    adapters_fa // file: /path/to/adapters.fa
    dada_stats // file: /path/to/dada_stats.tsv
    manifest // file: /path/to/manifest.tsv
    ref_dir // dir: /path/to/ref/data
    nn_ref_version // value: nnv2
    vae_ref_version // value: gcrefv1
    plasm_ref_version // value: plasmv1
    nn_assignment_threshold // value: 0.7
    run_id // value: 12345

    main:
    ch_versions = Channel.empty()

    ANOSPPPREP ( dada_table, adapters_fa, manifest, dada_stats, run_id )
    ch_versions = ch_versions.mix ( ANOSPPPREP.out.versions )

    ANOSPPQC ( ANOSPPPREP.out.haps, ANOSPPPREP.out.comb_stats )
    ch_versions = ch_versions.mix ( ANOSPPPREP.out.versions )

    ANOSPPPLASM ( ANOSPPPREP.out.haps, ANOSPPPREP.out.comb_stats, ref_dir, plasm_ref_version )
    ch_versions = ch_versions.mix ( ANOSPPPLASM.out.versions )

    ANOSPPNN ( 
        ANOSPPPREP.out.haps, 
        ANOSPPPREP.out.comb_stats, 
        ref_dir, 
        nn_ref_version, 
        plasm_ref_version, 
        ANOSPPPLASM.out.plasm_assignment,
        nn_assignment_threshold
    )
    ch_versions = ch_versions.mix ( ANOSPPNN.out.versions )

    ANOSPPVAE ( ANOSPPNN.out.nn_haps, ANOSPPNN.out.nn_assignment, ref_dir, vae_ref_version )
    ch_versions = ch_versions.mix ( ANOSPPVAE.out.versions )

    ANOSPPAGG ( ANOSPPPREP.out.comb_stats, ANOSPPNN.out.nn_assignment, ANOSPPVAE.out.vae_assignment, ANOSPPPLASM.out.plasm_assignment )
    ch_versions = ch_versions.mix ( ANOSPPVAE.out.versions )

    emit:
    qc_plots = ANOSPPQC.out.qc_plots // channel: [ val(meta), [ reads ] ]
    versions = ch_versions // channel: [ versions.yml ]
}


