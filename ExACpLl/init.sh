#!/bin/bash

set -e
set -x

SCRIPT_DIR=../scripts
source ${SCRIPT_DIR}/initFunctions.sh

# The purpose of this script is to download conservation data from the web, and reformat as needed.
URL="https://storage.googleapis.com/gcp-public-data--gnomad/legacy/exac_browser/ExAC.r1.sites.vep.vcf.gz"
GENOME=hg19
TEMP_FILE=ExAC.r1.sites.vep.vcf.gz
OUTFILE=./$GENOME/ExAC.bed
NAME=ExAC

DONE_FILE=processingDone.txt
if [ ! -e $DONE_FILE ];then
	ensureGenomeFolderExists $GENOME
	downloadSourceFile $URL $TEMP_FILE

	echo "#CHROM	START-0	END-1	Exac" > $OUTFILE
	zcat $TEMP_FILE | awk -v OFS='\t' ' { print $1, $2-1, $2, $5 } ' >> $OUTFILE

	# This is a possible pattern for making VCFs:
	#cat vcfHeader.txt > Exac.test.vcf
	#zcat $TEMP_FILE | awk -v OFS='\t' ' { print $1, $2, ".", $3, $4, ".", "PASS", "EXAC="$5 } ' >> test.vcf
	
	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	touch $DONE_FILE
fi

createConfigFileForBed $NAME $GENOME $OUTFILE


