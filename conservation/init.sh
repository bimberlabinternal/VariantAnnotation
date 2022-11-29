#!/bin/bash

set -e
set -x

SCRIPT_DIR=../scripts
source ${SCRIPT_DIR}/initFunctions.sh

# The purpose of this script is to download conservation data from the web, and reformat as needed.
URL="http://ftp.ensembl.org/pub/current_compara/conservation_scores/91_mammals.gerp_conservation_score/gerp_conservation_scores.macaca_mulatta.Mmul_10.bw"
GENOME=mmul10
TEMP_FILE=gerp_conservation_scores.macaca_mulatta.Mmul_10.bw
OUTFILE=./$GENOME/conservation.bed
NAME=conservation

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	downloadSourceFile $URL $TEMP_FILE

	echo '#CHROM	POS-0	END	CONSERVATION';
	wget -O bigWigToBedGraph http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bigWigToBedGraph
	chmod +x bigWigToBedGraph

	./bigWigToBedGraph $TEMP_FILE $OUTFILE;
	
	ensureIndexed $OUTFILE
	
	rm bigWigToBedGraph
	rm $TEMP_FILE
	
	touch $DONE_FILE
fi

createConfigFileForBed $NAME $GENOME $OUTFILE
