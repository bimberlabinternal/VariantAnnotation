#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

# The purpose of this script is to download conservation data from the web, and reformat as needed.
URL="https://storage.googleapis.com/gcp-public-data--gnomad/legacy/exac_browser/ExAC.r1.sites.vep.vcf.gz"
GENOME=hg19
TEMP_FILE=ExAC.r1.sites.vep.vcf.gz
OUTFILE=./$GENOME/ExAC.vcf.gz
NAME=ExAC

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	downloadSourceFile $URL $TEMP_FILE

	cp $TEMP_FILE $OUTFILE

	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	touch $DONE_FILE
fi

createConfigFileForVcf $NAME $GENOME $OUTFILE


