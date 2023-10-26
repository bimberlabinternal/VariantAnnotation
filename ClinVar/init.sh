#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

# The purpose of this script is to download conservation data from the web, and reformat as needed.
URL="https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh37/clinvar.vcf.gz"
GENOME=hg19
TEMP_FILE=clinvar.vcf.gz
OUTFILE=./$GENOME/clinvar.vcf.gz
NAME=ClinVar

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	downloadSourceFile $URL $TEMP_FILE
	
	# Position 11:15163 contains IUPAC bases, which HTSJDK does not allow:
	TEMP_FILE2=clinvar_20230702.ss.vcf.gz
	zcat $TEMP_FILE | awk -V OFS='\t' ' $5 != "YT" ' | bgzip -f > $TEMP_FILE2
	tabix -p vcf $TEMP_FILE2

	cp $TEMP_FILE2 $OUTFILE
	cp ${TEMP_FILE2}.tbi ${OUTFILE}.tbi
	
	rm -Rf $TEMP_FILE

	rm -Rf $TEMP_FILE2
	rm -Rf ${TEMP_FILE2}.tbi 
	
	touch $DONE_FILE
fi

createConfigFileForVcf $NAME $GENOME $OUTFILE
