#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

# The purpose of this script is to download conservation data from the web, and reformat as needed.
URL="http://ftp.ensembl.org/pub/current_regulation/homo_sapiens/homo_sapiens.GRCh38.Regulatory_Build.regulatory_features.20221007.gff.gz"
GENOME=hg19
TEMP_FILE=homo_sapiens.GRCh38.Regulatory_Build.regulatory_features.20221007.gff.gz
OUTFILE=./$GENOME/ERB.table
NAME=ERB

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	downloadSourceFile $URL $TEMP_FILE

	{
	echo 'HEADER	CONTIG	START	END	ERB_TYPE';  	
	zcat $TEMP_FILE | grep -v '#' | awk -F'\t' -v OFS='\t' ' { print $1":"$4"-"$5, $1, $4, $5, $3 } ' | sort -V -k2,2 -k3,3n -k4,4;
	} > $OUTFILE
	
	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	
	touch $DONE_FILE
fi

createConfigFileForTable $NAME $GENOME $OUTFILE
