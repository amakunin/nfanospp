
process ANOSPPQC {
    tag "npgrun"
    label 'process_low'

    conda "bioconda::anospp-analysis=0.1.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/anospp-analysis:0.1.3--pyh7cba7a3_0' :
        'quay.io/biocontainers/anospp-analysis:0.1.3--pyh7cba7a3_0' }"

    input:
    path haps_tsv
    path manifest
    path stats_tsv

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
        -a $haps_tsv \\
        -m $manifest \\
        -s $stats_tsv \\
        -o qc \\
        -v

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        anospp-analysis: \$(pip list | grep anospp-analysis | sed 's/anospp-analysis    //')
    END_VERSIONS
    """
}
