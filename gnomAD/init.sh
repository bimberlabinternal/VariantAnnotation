#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

URL=https://storage.googleapis.com/gcp-public-data--gnomad/release/2.1.1/vcf/genomes/gnomad.genomes.r2.1.1.sites.vcf.bgz

GENOME=hg19
TEMP_FILE=gnomad.genomes.r2.1.1.sites.vcf.gz
OUTFILE=./$GENOME/gnomad.genomes.r2.1.1.sites.vcf.gz
NAME=gnomAD

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	downloadSourceFile $URL $TEMP_FILE
	downloadSourceFile ${URL}.tbi ${TEMP_FILE}.tbi

	mv $TEMP_FILE $OUTFILE
	mv ${TEMP_FILE}.tbi ${OUTFILE}.tbi

	touch $DONE_FILE
fi

createConfigFileForVcf $NAME $GENOME $OUTFILE


