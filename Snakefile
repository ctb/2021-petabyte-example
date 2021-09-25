SAMPLE='data/genome-s10+s11.fa.gz'
QUERY='data/genome-s10.fa.gz'

rule prepare_sample:
    output: directory("prep.sample")
    shell: """
       rm -fr {output}
       mkdir -p {output}
       sourmash sketch dna -p k=31 {SAMPLE} -o {output}/sample.sig
    """

rule prepare_query:
    output: directory("prep.query")
    shell: """
       rm -fr {output}
       mkdir -p {output}
       sourmash sketch dna -p k=31 {QUERY} -o {output}/query.sig
    """

rule do_query:
    input:
        query = "prep.query/query.sig",
        sample = "prep.sample/sample.sig",
    output: directory("results")
    shell: """
       rm -fr {output}
       mkdir -p {output}
       sourmash search --containment prep.query/query.sig prep.sample/sample.sig -o {output}/results.csv
    """

rule install_software:
    shell: ""
