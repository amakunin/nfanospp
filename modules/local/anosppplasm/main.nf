
process ANOSPPPLASM {
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
    path plasm_ref_dir
    val plasm_ref_version

    output:
    path "plasm/Plasmodium_haplotypes_for.tsv", emit: plasm_haps
    path "plasm/plasmodium_predictions.tsv", emit: plasm_assignments
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: ''
    """
    anospp-plasm \\
        -a $haps_tsv \\
        -m $manifest \\
        -s $stats_tsv \\
        -b ${plasm_ref_dir}/${plasm_ref_version}/plasmomito_P1P2_DB_v1.0 \\
        -d ${plasm_ref_dir}/${plasm_ref_version} \\
        -o plasm \\
        -i \\
        -v

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        anospp-analysis: \$(pip list | grep anospp-analysis | sed 's/anospp-analysis    //')
    END_VERSIONS
    """
}
