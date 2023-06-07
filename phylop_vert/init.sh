#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

GENOME=hg19
REPORT_FILE=hg37Report.txt

OUTFILE_VERT=./$GENOME/phylop_vert.table
NAME_VERT=phylop_vert

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	
	VERT_TEMP=phylop_vert.sga.gz
	downloadSourceFile https://ccg.epfl.ch/mga/hg19/phylop/phylop_vert.sga.gz $VERT_TEMP

	# NOTE: the input is in GRCh38, so translate into GRCh37:
	wget -q -O $REPORT_FILE https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/001/405/GCA_000001405.14_GRCh37.p13/GCA_000001405.14_GRCh37.p13_assembly_report.txt
	
	{
 	echo 'HEADER	CHROM	START	END	PHYLOP_VERT';
	python ./hg19translation.py $VERT_TEMP | sort -V -k1,1 -k2,2n -k3,3n | awk -v OFS='\t' ' { print $1":"$2"-"$3, $1, $2, $3, $5 } ';
	} > $OUTFILE_VERT
	
	ensureIndexed $OUTFILE_VERT
		
	rm $VERT_TEMP
	rm $REPORT_FILE
	
	touch $DONE_FILE
fi

createConfigFileForTable $NAME_VERT $GENOME $OUTFILE_VERT


