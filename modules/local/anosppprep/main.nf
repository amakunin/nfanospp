
process ANOSPPPREP {
    tag "$meta.id"
    label 'process_low'

    conda "bioconda::anospp-analysis=0.1.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/anospp-analysis:0.1.3--pyh7cba7a3_0' :
        'quay.io/biocontainers/anospp-analysis:0.1.3--pyh7cba7a3_0' }"

    input:
    tuple val(meta), path(dada_table)
    path adapters_fa 

    output:
    tuple val(meta), path("*.tsv"), emit: haps_tsv
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
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
