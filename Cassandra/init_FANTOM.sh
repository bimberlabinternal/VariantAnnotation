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
OUTFILE=./$GENOME/FANTOM.table
NAME=FANTOM

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME

	{
	echo 'HEADER	CHROM	START	END	INFO';
	zcat $TEMP_FILE | grep -v '#' | awk -F'\t' -v OFS='\t' ' { print $1":"$2+1"-"$3, $1, $2+1, $3, $11 } ' | sort -V -k2,2 -k3,3n -k4,4n;
	} > $OUTFILE 
	
	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	touch $DONE_FILE
fi

createConfigFileForTable $NAME $GENOME $OUTFILE

cd ../
cp -r FANTOM/ ../