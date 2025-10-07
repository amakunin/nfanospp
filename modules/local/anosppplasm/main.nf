
process ANOSPPPLASM {
    tag "npgrun"
    label 'process_single'

    conda "bioconda::anospp-analysis=0.4.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/anospp-analysis:0.4.0--pyhdfd78af_0' :
        'quay.io/biocontainers/anospp-analysis:0.4.0--pyhdfd78af_0' }"
    
    input:
    path haps
    path comb_stats
    path ref_dir
    val plasm_ref_version

    output:
    path "plasm/plasm_hap_summary.tsv", emit: plasm_haps
    path "plasm/plasm_assignment.tsv", emit: plasm_assignment
    path "plasm/*.html", emit: plasm_plots
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: ''
    """
    anospp-plasm -v -i \\
        -a $haps \\
        -s $comb_stats \\
        -r ${ref_dir}/${plasm_ref_version} \\
        -o plasm 
        

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        anospp-analysis: \$(pip list | grep anospp-analysis | sed 's/anospp-analysis    //')
    END_VERSIONS
    """
}
