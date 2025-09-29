
process ANOSPPVAE {
    tag "npgrun"
    label 'process_single'

    conda "bioconda::anospp-analysis=0.4.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/anospp-analysis:0.4.0--pyhdfd78af_0' :
        'quay.io/biocontainers/anospp-analysis:0.4.0--pyhdfd78af_0' }"

    input:
    path nn_haps
    path nn_assignment
    path ref_dir
    val vae_ref_version

    output:
    path "vae/vae_assignment.tsv", emit: vae_assignment
    path "vae/summary.txt", emit: vae_summary
    path "vae/*.png", optional: true, emit: vae_plots
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: ''
    """
    anospp-vae \\
        -a $nn_haps \\
        -m $nn_assignment \\
        -r ${ref_dir}/${vae_ref_version} \\
        -o vae \\
        -v

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        anospp-analysis: \$(pip list | grep anospp-analysis | sed 's/anospp-analysis    //')
    END_VERSIONS
    """
}
