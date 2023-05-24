
process ANOSPPNN {
    tag "npgrun"
    label 'process_low'

    conda "bioconda::anospp-analysis=0.2.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/anospp-analysis:0.2.1--pyh7cba7a3_0' :
        'quay.io/biocontainers/anospp-analysis:0.2.1--pyh7cba7a3_0' }"

    input:
    path haps_tsv
    path manifest
    path stats_tsv
    path nn_ref_dir
    val nn_ref_version

    output:
    path "nn/non_error_haplotypes.tsv", emit: nn_haps_tsv
    path "nn/nn_assignment.tsv", emit: nn_assignment
    path "nn/summary.txt", emit: nn_summary
    path "nn/*.png", emit: nn_plots
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: ''
    """
    anospp-nn \\
        -a $haps_tsv \\
        -m $manifest \\
        -s $stats_tsv \\
        -r $nn_ref_version \\
        --path_to_refversion $nn_ref_dir \\
        -o nn \\
        -v

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        anospp-analysis: \$(pip list | grep anospp-analysis | sed 's/anospp-analysis    //')
    END_VERSIONS
    """
}
