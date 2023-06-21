#!/bin/bash

set -e
set -x

# This script can be used to sanity-check the data source downloads
export DOWNLOAD_LINE_LIMIT=1000
export FORCE_REPROCESS=0
export SKIP_LARGE_SOURCES=1

bash initializeAll.sh

VCF=simpleTest.vcf
DATA_SOURCE=.
OUTPUT=testFuncotator.vcf

FASTA=Homo_sapiens.GRCh37.75.fasta

# NOTE: this is too large to work on github's agents:
#wget -O ${FASTA}.gz https://ftp.ensembl.org/pub/release-75/fasta/homo_sapiens/dna/Homo_sapiens.GRCh37.75.dna_sm.toplevel.fa.gz
#gunzip ${FASTA}.gz
#
#samtools faidx $FASTA
#gatk CreateSequenceDictionary -R $FASTA
#
#gatk IndexFeatureFile -I $VCF
#
#gatk Funcotator \
#	-R $FASTA \
#	--variant $VCF \
#	--ref-version hg19 \
#	--data-sources-path $DATA_SOURCE \
#	--output $OUTPUT \
#	--output-file-format MAF
#
#rm $FASTA