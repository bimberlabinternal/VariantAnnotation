#!/bin/bash

# This script can be used to sanity-check the data source downloads
export DOWNLOAD_LINE_LIMIT=1000
export FORCE_REPROCESS=0
export SKIP_LARGE_SOURCES=1

bash initializeAll.sh

#VCF=simpleTest.vcf
#DATA_SOURCE=.
#OUTPUT=testFuncotator.vcf
#FASTA=
#
#gatk IndexFeatureFile -I $VCF
#
#gatk Funcotator \
#	-R $FASTA
#	--variant $VCF \
#	--ref-version hg19 \
#	--data-sources-path $DATA_SOURCE \
#	--output $OUTPUT \
#	--output-file-format MAF
