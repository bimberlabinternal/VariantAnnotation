#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

if [ ! -d FANTOM ];then
	mkdir FANTOM
fi

cd FANTOM

GENOME=hg19
TEMP_FILE=DPIcluster.txt.gz
OUTFILE=./$GENOME/FANTOM.bed
NAME=FANTOM

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME

	{
	echo '#CHROM	START	END	INFO';
	zcat $TEMP_FILE | grep -v '#' | awk -F'\t' -v OFS='\t' ' { print $1, $2, $3, $11 } ' | sort -V -k1,1 -k2,2n -k3,3n;
	} > $OUTFILE 
	
	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	touch $DONE_FILE
fi

createConfigFileForBed $NAME $GENOME $OUTFILE

cd ../
cp -r FANTOM/ ../