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
OUTFILE=./$GENOME/FantomEnhancer.table
NAME=FANTOM_ENHANCER

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	downloadSourceFile $URL $TEMP_FILE

   	{
	echo 'HEADER	CHROM	START	END	ENHANCERID	SCORE	STRAND';
	zcat $TEMP_FILE | grep -v '#' | awk -F'\t' -v OFS='\t' ' { print $1":"$2+1"-"$3, $1, $2+1, $3, $4, $5, $6 } ' | sort -V -k2,2 -k3,3n -k4,4n;
	} > $OUTFILE
	
	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	touch $DONE_FILE
fi

createConfigFileForTable $NAME $GENOME $OUTFILE