
process ANOSPPVAE {
    tag "npgrun"
    label 'process_low'

    conda "bioconda::anospp-analysis=0.2.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/anospp-analysis:0.2.1--pyh7cba7a3_0' :
        'quay.io/biocontainers/anospp-analysis:0.2.1--pyh7cba7a3_0' }"

    input:
    path nn_haps_tsv
    path nn_assignment
    path vae_ref_dir
    val vae_ref_version

    output:
    path "vae/final_assignments.tsv", emit: vae_assignment
    path "vae/summary.txt", emit: vae_summary
    path "vae/*.png", emit: vae_plots
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: ''
    """
    anospp-vae \\
        -a $nn_haps_tsv \\
        -m $nn_assignment \\
        -r $vae_ref_version \\
        --path_to_refversion $vae_ref_dir \\
        -o vae \\
        -v

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        anospp-analysis: \$(pip list | grep anospp-analysis | sed 's/anospp-analysis    //')
    END_VERSIONS
    """
}