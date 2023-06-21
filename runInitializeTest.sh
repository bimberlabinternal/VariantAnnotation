#!/bin/bash

set -e

# This script can be used to sanity-check the data source downloads
export DOWNLOAD_LINE_LIMIT=1000
export FORCE_REPROCESS=0
export SKIP_LARGE_SOURCES=1

bash initializeAll.sh

VCF=simpleTest.vcf
DATA_SOURCE=.
OUTPUT=testFuncotator.vcf

FASTA=genome.fasta

wget -O ${FASTA}.gz https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.25_GRCh37.p13/GCF_000001405.25_GRCh37.p13_genomic.fna.gz
gunzip ${FASTA}.gz

samtools faidx $FASTA
gatk CreateSequenceDictionary -R $FASTA

gatk IndexFeatureFile -I $VCF

gatk Funcotator \
	-R $FASTA \
	--variant $VCF \
	--ref-version hg19 \
	--data-sources-path $DATA_SOURCE \
	--output $OUTPUT \
	--output-file-format MAF

rm genome.fasta