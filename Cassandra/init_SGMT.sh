#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

#ERBSEG - Genome segment prediction based on 17 cell types from ENCODE and Roadmap by Ensembl Regulatory Build.

if [ ! -d SGMT ];then
	mkdir SGMT
	mv sgmt.* SGMT/
fi

cd SGMT


GENOME=hg19
TEMP_FILE=cell_type_segmentation.txt.gz
OUTFILE=./$GENOME/SGMT.table
NAME=SGMT

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME

	{
	echo 'HEADER	CHROM	START	END	GENE_INFO';
	zcat $TEMP_FILE | grep -v '#' | awk -F'\t' -v OFS='\t' ' { print $1":"$2+1"-"$3, $1, $2+1, $3, $4 } ' | sort -V -k2,2 -k3,3n -k4,4n;
	} > $OUTFILE
	
	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	touch $DONE_FILE
fi

createConfigFileForTable $NAME $GENOME $OUTFILE

cd ../
cp -r SGMT ../


