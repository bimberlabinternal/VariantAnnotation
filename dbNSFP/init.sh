#!/bin/bash

set -e
set -x

# NOTE: the dbNSFP sources are huge and cannot be easily subset, so dont run this during testing
if [[ ${SKIP_LARGE_SOURCES:=0} == 1 ]] ;then
	echo 'Skipping dbNSFP since SKIP_LARGE_SOURCES is set'
	exit 0
fi

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh


URL="https://dbnsfp.s3.amazonaws.com/dbNSFP4.4a.zip"
GENOME=hg19
TEMP_FILE=./dbNSFP4/dbNSFP4.4a.zip
OUTFILE=./$GENOME/dbNSFP.vcf.gz
NAME=dbNSFP

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	
	if [ ! -e dbNSFP4 ];
		then mkdir -p dbNSFP4
	fi
	
	downloadSourceFile $URL $TEMP_FILE

	unzip $TEMP_FILE -d dbNSFP4
	
	{
		cat dbNSFP_Header.txt;
		python dbNsfpToVcf.py;
	} | bgzip --threads $N_THREADS > $OUTFILE
	
	ensureIndexed $OUTFILE

	rm -Rf dbNSFP4
	
	touch $DONE_FILE
fi

createConfigFileForVcf $NAME $GENOME $OUTFILE
