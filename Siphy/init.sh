#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh


URL="http://www.broadinstitute.org/ftp/pub/assemblies/mammals/29mammals/hg19/hg19_29way_omega_lods_elements_12mers.chr_specific.fdr_0.1_with_scores.txt.gz"
GENOME=hg19
TEMP_FILE=hg19_29way_omega_lods_elements_12mers.chr_specific.fdr_0.1_with_scores.txt.gz
OUTFILE=./$GENOME/Siphy.table
NAME=Siphy

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	downloadSourceFile $URL $TEMP_FILE

	{
	echo 'HEADER	CHROM	START	END	LODSCORE	BranchLength';
	## NOTE: BED files are 0-based, open coordinates;
	zcat $TEMP_FILE | grep -v '#' | awk -F'\t' -v OFS='\t' ' { print $1":"$2+1"-"$3, $1, $2+1, $3, $4, $5 } ' | sort -V -k1,1 -k2,2n -k3,3n;
	} > $OUTFILE
	
	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	
	touch $DONE_FILE
fi

createConfigFileForBed $NAME $GENOME $OUTFILE
