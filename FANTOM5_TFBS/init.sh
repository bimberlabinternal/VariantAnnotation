#!/bin/bash

set -e
set -x

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

# The purpose of this script is to download conservation data from the web, and reformat as needed.
GENOME=hg19
OUTFILE=./$GENOME/FANTOM5_TFBS.table
NAME=FANTOM5_TFBS

if [[ `isProcessingCompleted` == 0 ]];then
	ensureGenomeFolderExists $GENOME
	
	OUTDIR=outdir
	if [ -e $OUTDIR ]; then
		rm -Rf $OUTDIR
	fi
	
	mkdir $OUTDIR
	
	TMP_FILE=FANTOM5_TFBS.table.tmp
	truncate -s 0 $TMP_FILE
	
	URL_BASE=https://fantom.gsc.riken.jp/5/datafiles/phase1.3/extra/Motifs/TFBS/
	for file in $(curl -s $URL_BASE |
                  grep 'hg19' |
				  grep 'sites.txt.bz2' |
                  sed 's/.*href="//' |
                  sed 's/".*//'); do
		downloadSourceFile ${URL_BASE}$file ${OUTDIR}/$file
		bzcat ${OUTDIR}/$file | grep -v '#' | grep -v '^chrom' | sed 's/^chr//' | awk -F'\t' -v OFS='\t' ' { split($4,tf,";"); print $1":"$2+1"-"$3, $1, $2+1, $3, tf[1], $6, $5 } ' >> $TMP_FILE
	done

	{
	echo 'HEADER	CONTIG	START	END	TF	STRAND	SCORE';  	
	cat $TMP_FILE | sort -V -k2,2 -k3,3n -k4,4n;
	} > $OUTFILE
	
	ensureIndexed $OUTFILE
	
	rm $TMP_FILE
	rm -Rf $OUTDIR
	
	touch $DONE_FILE
fi

createConfigFileForTable $NAME $GENOME $OUTFILE
