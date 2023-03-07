#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

if [ ! -d TFBS ];then
	mkdir TFBS
	mv tfbs.* TFBS/
fi

cd TFBS

GENOME=hg19
TEMP_FILE=TFBS.summary.bed.gz
OUTFILE=./$GENOME/TFBS.bed
NAME=TFBS

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME

	{
	echo '#CHROM	START	END	GENE_INFO';
	zcat $TEMP_FILE | grep -v '#' | awk -F'\t' -v OFS='\t' ' { print $1, $2, $3, "["$4"]" } ' | sort -V -k1,1 -k2,2n -k3,3n;
	} > $OUTFILE
	
	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	touch $DONE_FILE
fi

createConfigFileForBed $NAME $GENOME $OUTFILE
cd ../
cp -r TFBS ../



