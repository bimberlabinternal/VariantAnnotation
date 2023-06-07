#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

#there are several cassandra data sources asscoiated with encode:
#this one is ENCDNA -  Encode DNASE1 hypersentivity sites.
#there is also Encode Genome Segmentation - Genome segmentation by ENCODE. seperate source not yet made
#there is also ENCTFBS - ENCODE transcription factor binding site score. seperate source not yet made

cd ENCODE

GENOME=hg19
TEMP_FILE=wgEncodeRegDnaseClusteredV2.bed.gz
OUTFILE=./$GENOME/ENCODE.table
NAME=ENCODE

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME

	{
	echo 'HEADER	CHROM	START	END	DNASECLUST';
	zcat $TEMP_FILE | grep -v '#' | grep -v "CHR" | awk -F'\t' -v OFS='\t' ' { print $1":"$2+1"-"$3, $1, $2+1, $3, $4 } ';
	} > $OUTFILE
	
	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	touch $DONE_FILE
fi

createConfigFileForTable $NAME $GENOME $OUTFILE

cd ../
cp -r ENCODE ../



