#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

GENOME=hg19
REPORT_FILE=hg37Report.txt

OUTFILE_PLACENTAL=./$GENOME/phylop_placental.table
NAME_PLACENTAL=phylop_placental

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	
	PLACENTAL_TEMP=phylop_placental.sga.gz
	downloadSourceFile https://ccg.epfl.ch/mga/hg19/phylop/phylop_placental.sga.gz $PLACENTAL_TEMP

	# NOTE: the input is in GRCh38, so translate into GRCh37:
	wget -q -O $REPORT_FILE https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/001/405/GCA_000001405.14_GRCh37.p13/GCA_000001405.14_GRCh37.p13_assembly_report.txt
	
	{
 	echo 'HEADER	CHROM	START	END	PHYLOP_PLACENTAL';
	python ./hg19translation.py $PLACENTAL_TEMP | sort -V -k1,1 -k3,3n | awk -v OFS='\t' ' { print $1":"$3"-"$3, $1, $3, $3, $5 } ';
	} > $OUTFILE_PLACENTAL
	
	ensureIndexed $OUTFILE_PLACENTAL
	
	rm $PLACENTAL_TEMP
	rm $REPORT_FILE
	
	touch $DONE_FILE
fi

createConfigFileForTable $NAME_PLACENTAL $GENOME $OUTFILE_PLACENTAL

