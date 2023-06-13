#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

# The purpose of this script is to download conservation data from the web, and reformat as needed.
URL="https://zenodo.org/record/3928295/files/capice_v1.0_build37_indels.tsv.gz"
GENOME=hg19
TEMP_FILE=capice_v1.0_build37_indels.tsv.gz
OUTFILE=./$GENOME/capice.vcf.gz
NAME=capice

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	downloadSourceFile $URL $TEMP_FILE

	{
	echo '##fileformat=VCFv4.2';
	echo '##INFO=<ID=CAPICE,Number=A,Type=Float,Description="Contains precomputed scores for InDels in genome build 37">';
	echo '#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO';
	zcat $TEMP_FILE | grep -v '#' | awk -F'\t' -v OFS='\t' ' { print $1, $2, ".", $3, $4, ".", "PASS", "CAPICE="$5 } ';
	} | bgzip --threads $N_THREADS > $OUTFILE
	
	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	
	touch $DONE_FILE
fi

createConfigFileForVcf $NAME $GENOME $OUTFILE