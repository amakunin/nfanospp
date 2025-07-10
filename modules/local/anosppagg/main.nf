
process ANOSPPAGG {
    tag "npgrun"
    label 'process_low'

    conda "bioconda::anospp-analysis=0.4.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/anospp-analysis:0.4.0--pyhdfd78af_0' :
        'quay.io/biocontainers/anospp-analysis:0.4.0--pyhdfd78af_0' }"

    input:
    path comb_stats
    path nn_assignment
    path vae_assignment
    path plasm_assignment

    output:
    path "anospp_results.tsv", emit: anospp_results
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: ''
    """
    anospp-agg -v \\
        -s $comb_stats \\
        -n $nn_assignment \\
        -e $vae_assignment \\
        -p $plasm_assignment \\
        -o anospp_results.tsv        

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        anospp-analysis: \$(pip list | grep anospp-analysis | sed 's/anospp-analysis    //')
    END_VERSIONS
    """
}
