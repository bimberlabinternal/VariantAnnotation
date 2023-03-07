#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

# The purpose of this script is to download A tab-delimited file containing OMIM's Synopsis of the Human Gene Map including additional information such as genomic coordinates and inheritance
URL="https://fantom.gsc.riken.jp/5/datafiles/latest/extra/Enhancers/human_permissive_enhancers_phase_1_and_2.bed.gz"
GENOME=hg19
TEMP_FILE=human_permissive_enhancers_phase_1_and_2.bed.gz
OUTFILE=./$GENOME/FantomEnhancer.bed
NAME=FANTOM_ENHANCER

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	downloadSourceFile $URL $TEMP_FILE

	{
	echo '#CHROM	START	END	ENHANCERID	SCORE	STRAND';
	#(columns 1-6 as chromosome, start coordinate, end coordinate, enhancer ID, score and strand)
	zcat $TEMP_FILE | grep -v '#' | awk -F'\t' -v OFS='\t' ' { print $1, $2, $3, $4, $5, $6 } ' | sort -V -k1,1 -k2,2n -k6,6;
	} > $OUTFILE
	
	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	touch $DONE_FILE
fi

createConfigFileForBed $NAME $GENOME $OUTFILE