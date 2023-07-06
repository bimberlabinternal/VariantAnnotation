#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

# The purpose of this script is to download conservation data from the web, and reformat as needed.
URL="https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh37/clinvar_20230702.vcf.gz"
GENOME=hg19
TEMP_FILE=clinvar_20230702.vcf.gz
OUTFILE=./$GENOME/clinvar_20230702.vcf.gz
NAME=ClinVar

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	downloadSourceFile $URL $TEMP_FILE
	downloadSourceFile ${URL}.tbi ${TEMP_FILE}.tbi

	cp $TEMP_FILE $OUTFILE
	cp ${TEMP_FILE}.tbi ${OUTFILE}.tbi
	
	rm -Rf $TEMP_FILE
	rm -Rf ${TEMP_FILE}.tbi 

	touch $DONE_FILE
fi

createConfigFileForVcf $NAME $GENOME $OUTFILE
