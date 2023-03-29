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
OUTFILE=./$GENOME/funseq2.bed
NAME=funseq2

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	{
	echo '#CHROM	START	END	SCORE';
	zcat $TEMP_FILE | grep -v '#' | awk -F'\t' -v OFS='\t' ' { print $1, $2-1, $2, $5 } ' | sort -V -k1,1 -k2,2n;
	} > $OUTFILE

	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	touch $DONE_FILE
fi

createConfigFileForBed $NAME $GENOME $OUTFILE

cd ../
cp -r funseq2 ../



