#! /usr/bin/env python3
import subprocess
import datetime
import shutil


def main():
    print('removing outputs/')
    try:
        shutil.rmtree('./outputs/')
    except FileNotFoundError:
        pass

    print('installing software:')
    subprocess.check_call('snakemake -j 1 --use-conda install_software',
                          shell=True)

    print(datetime.datetime.now(), 'START SAMPLE PREP')
    subprocess.check_call('snakemake -j 1 --use-conda prepare_sample',
                          shell=True)
    print(datetime.datetime.now(), 'END SAMPLE PREP')

    print(datetime.datetime.now(), 'START QUERY PREP')
    subprocess.check_call('snakemake -j 1 --use-conda prepare_query',
                          shell=True)
    print(datetime.datetime.now(), 'END QUERY PREP')

    print(datetime.datetime.now(), 'START DO QUERY')
    subprocess.check_call('snakemake -j 1 --use-conda do_query', shell=True)
    print(datetime.datetime.now(), 'END DO QUERY')

if __name__ == '__main__':
    main()
