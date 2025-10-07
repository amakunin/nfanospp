
process ANOSPPPREP {
    tag "npgrun"
    label 'process_single'

    conda "bioconda::anospp-analysis=0.4.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/anospp-analysis:0.4.0--pyhdfd78af_0' :
        'quay.io/biocontainers/anospp-analysis:0.4.0--pyhdfd78af_0' }"

    input:
    path dada_table
    path adapters_fa
    path manifest
    path dada_stats
    val run_id


    output:
    path "prep/haps.tsv", emit: haps
    path "prep/comb_stats.tsv", emit: comb_stats
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: ''
    """
    anospp-prep -v \\
        -t $dada_table \\
        -a $adapters_fa \\
        -m $manifest \\
        -s $dada_stats \\
        -o prep \\
        -w work \\
        -i $run_id

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        anospp-analysis: \$(pip list | grep anospp-analysis | sed 's/anospp-analysis    //')
    END_VERSIONS
    """
}
