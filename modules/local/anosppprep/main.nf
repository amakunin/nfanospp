
process ANOSPPPREP {
    tag "npgrun"
    label 'process_low'

    conda "bioconda::anospp-analysis=0.2.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/anospp-analysis:0.2.1--pyh7cba7a3_0' :
        'quay.io/biocontainers/anospp-analysis:0.2.1--pyh7cba7a3_0' }"

    input:
    path dada_table
    path adapters_fa 

    output:
    path "*.tsv", emit: haps_tsv
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: ''
    """
    anospp-prep \\
        -t $dada_table \\
        -a $adapters_fa \\
        -o haps.tsv \\
        -w work \\
        -v

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        anospp-analysis: \$(pip list | grep anospp-analysis | sed 's/anospp-analysis    //')
    END_VERSIONS
    """
}
