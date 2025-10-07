
process ANOSPPQC {
    tag "npgrun"
    label 'process_single'

    conda "bioconda::anospp-analysis=0.4.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/anospp-analysis:0.4.0--pyhdfd78af_0' :
        'quay.io/biocontainers/anospp-analysis:0.4.0--pyhdfd78af_0' }"

    input:
    path haps
    path comb_stats

    output:
    path "qc/*.png", emit: qc_plots
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: ''
    """
    anospp-qc \\
        -a $haps \\
        -s $comb_stats \\
        -o qc \\
        -v

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        anospp-analysis: \$(pip list | grep anospp-analysis | sed 's/anospp-analysis    //')
    END_VERSIONS
    """
}
