#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

cd funseq2

GENOME=hg19
TEMP_FILE=funseq2.tsv.gz
OUTFILE=./$GENOME/funseq2.table
NAME=funseq2

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	{
	echo 'HEADER	CHROM	START	END	SCORE';
	zcat $TEMP_FILE | grep -v '#' | awk -F'\t' -v OFS='\t' ' { print $1":"$2"-"$2, $1, $2, $2, $5 } ' | sort -V -k2,2 -k3,3n;
	} > $OUTFILE

	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	touch $DONE_FILE
fi

createConfigFileForTable $NAME $GENOME $OUTFILE

cd ../
cp -r funseq2 ../



