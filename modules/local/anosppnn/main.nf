
process ANOSPPNN {
    tag "npgrun"
    label 'process_single'
    label 'process_long'

    conda "bioconda::anospp-analysis=0.4.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/anospp-analysis:0.4.0--pyhdfd78af_0' :
        'quay.io/biocontainers/anospp-analysis:0.4.0--pyhdfd78af_0' }"

    input:
    path haps
    path comb_stats
    path ref_dir
    val nn_ref_version
    val plasm_ref_version
    path plasm_assignment
    val nn_assignment_threshold

    output:
    path "nn/nn_dist_to_ref.tsv", emit: nn_dist_to_ref
    path "nn/assignment_*.tsv", emit: nn_level_assignments
    path "nn/nn_hap_summary.tsv", emit: nn_haps
    path "nn/nn_assignment.tsv", emit: nn_assignment
    path "nn/nn_summary.txt", emit: nn_summary
    path "nn/*.png", emit: nn_plots
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: ''
    """
    anospp-nn \\
        -a $haps \\
        -s $comb_stats \\
        -r ${ref_dir}/${nn_ref_version} \\
        --plasm_assignment $plasm_assignment \\
        --plasm_colors ${ref_dir}/${plasm_ref_version}/species_colours.csv \\
        --nn_assignment_threshold $nn_assignment_threshold \\
        --legend_cutoff 0.05 \\
        -o nn \\
        -v

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        anospp-analysis: \$(pip list | grep anospp-analysis | sed 's/anospp-analysis    //')
    END_VERSIONS
    """
}
