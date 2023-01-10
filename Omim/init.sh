#!/bin/bash

set -e
set -x

SCRIPT_DIR=../../scripts
source ${SCRIPT_DIR}/initFunctions.sh

# The purpose of this script is to download A tab-delimited file containing OMIM's Synopsis of the Human Gene Map including additional information such as genomic coordinates and inheritance
URL="https://data.omim.org/downloads/1vPFkocFQqKBDomTPknwYg/genemap2.txt"
GENOME=hg19
TEMP_FILE=genemap2.txt
OUTFILE=./$GENOME/omim.bed.gz
NAME=omim

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	downloadSourceFile $URL $TEMP_FILE

	{
	echo '#CHROM	START	END	PMID';
	## NOTE: BED files are 0-based, open coordinates:
	cat $TEMP_FILE | grep -v '#' | awk -F'\t' -v OFS='\t' ' { print $1-1, $2, $3, $6 } ' | sort --parallel $N_THREADS -V -k1,1 -k2,2n -k3,3n;
	} | bgzip --threads $N_THREADS > $OUTFILE

	ensureIndexed $OUTFILE
	rm $TEMP_FILE
	touch $DONE_FILE
fi

createConfigFileForBed $NAME $GENOME $OUTFILE