SAMPLE='data/genome-s10+s11.fa.gz'
QUERY='data/genome-s10.fa.gz'
OUTPUT_DIR='outputs'
SAMPLE_PREP=os.path.join(OUTPUT_DIR, 'prep.sample')
QUERY_PREP=os.path.join(OUTPUT_DIR, 'prep.query')

rule prepare_sample:
    output: directory(SAMPLE_PREP)
    shell: """
       rm -fr {output}
       mkdir -p {output}
       sourmash sketch dna -p k=31 {SAMPLE} -o {output}/sample.sig
    """

rule prepare_query:
    output: directory(QUERY_PREP)
    shell: """
       rm -fr {output}
       mkdir -p {output}
       sourmash sketch dna -p k=31 {QUERY} -o {output}/query.sig
    """

rule do_query:
    input:
        query = f"{QUERY_PREP}/query.sig",
        sample = f"{SAMPLE_PREP}/sample.sig",
    output: directory("results")
    shell: """
       rm -fr {output}
       mkdir -p {output}
       sourmash search --containment {input.query} {input.sample} -o {output}/results.csv
    """

rule install_software:
    conda: "conf/env/sourmash4.yml"
    shell: """
       sourmash --version
    """
