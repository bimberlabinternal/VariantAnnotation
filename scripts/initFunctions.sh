#!/bin/bash

set -e
set -x
set -u

# This is the path of this script:
SCRIPT_DIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
DONE_FILE=processingDone.txt

# NOTE: if the environment variable N_THREADS is defined (which should be an integer), then it will be passed to sort
if [[ ! -v N_THREADS ]];then
	N_THREADS=4
fi

echo "Threads: "$N_THREADS

function is_bin_in_path {
	which "$1" &> /dev/null || { echo "$1 not in path"; exit 1; }
}

if [[ -z ${GATK:=} ]] ;then
	is_bin_in_path gatk
	GATK=`which gatk`
fi

is_bin_in_path samtools
is_bin_in_path bgzip

isCompressed() {
	if (file $1 | grep -q compressed ) ; then
		echo 1
	fi
	
	echo 0
}

ensureGenomeFolderExists() {
	if [ ! -e $1 ];then
		mkdir $1
	fi
	
	# Clear existing files:
	rm -Rf ./${1}/*
}

downloadSourceFile() {
	URL=$1
	WGET_OUT=$2
	
	if [[ -z ${ALLOW_DATASOURCE_REUSE:=} && -e $WGET_OUT ]];then
		echo 'Re-using existing file: '$WGET_OUT
		return
	fi
	
	if [[ -z ${DOWNLOAD_LINE_LIMIT:=} ]];then
		wget --no-check-certificate -O $WGET_OUT "$URL"
	else
		echo "Limiting downline to "$DOWNLOAD_LINE_LIMIT" lines"
		MAYBE_ZCAT='cat'
		MAYBE_ZGZIP='cat'
		if [[ $WGET_OUT == *.gz ]];then
			MAYBE_ZCAT="zcat"
			MAYBE_ZGZIP="bgzip"
		fi
		
		wget --no-check-certificate -q -O - "$URL" | $MAYBE_ZCAT | head -n $DOWNLOAD_LINE_LIMIT | $MAYBE_ZGZIP > $WGET_OUT 
	fi
}

runIndexFeatureFile() {
	$GATK IndexFeatureFile -I $1
}

ensureBedOrVcfSorted() {
	INPUT=$1
	TMP_OUT=tmp.txt
	
	COMPRESSED=`isCompressed $1`
	MAYBE_ZCAT="cat"
	MAYBE_BGZIP="cat"
	if [[ $COMPRESSED == 1 ]] ;then
		MAYBE_ZCAT="zcat"
		MAYBE_BGZIP="bgzip"
	fi

	{
	$MAYBE_ZCAT $INPUT | grep -e '#';
	$MAYBE_ZCAT $INPUT | grep -v '#' | sort --parallel $N_THREADS -V -k1,1 -k2,2n;
	} | $MAYBE_ZGZIP >> $TMP_OUT

	rm $INPUT
	mv $TMP_OUT $INPUT
}

ensureIndexed() {
	COMPRESSED=`isCompressed $1`
	
	if [[ $COMPRESSED == 1 ]] ;then
		tabix -f $1
	else
		runIndexFeatureFile $1
	fi
}

createConfigFileForBed() {
	createConfigFile $1 $2 $3 'locatableXSV'
}

createConfigFileForVcf() {
	createConfigFile $1 $2 $3 'vcf'
}

createConfigFile() {
	NAME=$1
	GENOME=$2
	SRC_FILE=`basename $3`
	TYPE=$4
	
	TEMPLATE=${SCRIPT_DIR}/template.config
	DEST=./${GENOME}/${NAME}.config
	
	cat $TEMPLATE | sed 's/<NAME>/'$NAME'/' | sed 's|<SRC_FILE>|'$SRC_FILE'|' | sed 's/<TYPE>/'$TYPE'/' > $DEST
}

isProcessingCompleted() {
	if [[ -e $DONE_FILE && ${FORCE_REPROCESS:=0} == 1 ]];then
		echo "FORCE_REPROCESS=$FORCE_REPROCESS, deleting existing "$DONE_FILE
		rm $DONE_FILE
	fi
	
	if [[ -e $DONE_FILE ]];then
		echo 1
	else
		echo 0
	fi
}