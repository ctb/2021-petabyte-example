import sys, os

# load stuff from config file
SAMPLES=config.get('metagenome_files', [])
QUERY=config.get('query_file', '')
ksize = config.get('ksize', 'unset')

# don't change these :)
OUTPUT_DIR='outputs'
SAMPLE_PREP=os.path.join(OUTPUT_DIR, 'prep.sample')
QUERY_PREP=os.path.join(OUTPUT_DIR, 'prep.query')

###
### check configuration
###

print("Checking configuration...", file=sys.stderr)

do_fail = False

SAMPLES = [ x.strip() for x in SAMPLES ]
SAMPLES = [ x for x in SAMPLES if x ]

if not SAMPLES:
    print("No files in 'metagenome_files' in the config?", file=sys.stderr)
    do_fail = True

if not QUERY:
    print("No 'query' in the config?", file=sys.stderr)
    do_fail = True

try:
    ksize = int(ksize)
except ValueError:
    print(f"Invalid ksize {repr(ksize)}", file=sys.stderr)
    do_fail = True

for sample in SAMPLES:
    if not os.path.exists(sample):
        print(f"metagenome file '{sample}' does not exist.", file=sys.stderr)
        do_fail = True

if not os.path.exists(QUERY):
    print(f"query file '{QUERY}' does not exist.", file=sys.stderr)
    do_fail = True

if do_fail:
    print('Snakefile config checks FAILED.', file=sys.stderr)
    sys.exit(-1)

print("Configuration PASSED!", file=sys.stderr)

###
### actual rules to run something
###

rule prepare_sample:
    output: directory(SAMPLE_PREP)
    shell: """
       rm -fr {output}
       mkdir -p {output}
       sourmash sketch dna -p k=31 {SAMPLES} -o {output}/sample.sig
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
