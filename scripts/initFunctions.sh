#!/bin/bash

set -e
set -x
set -u

# This is the path of this script:
SCRIPT_DIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

GATK=`which gatk`

# NOTE: if the environment variable N_THREADS is defined (which should be an integer), then it will be passed to sort
if [[ ! -v N_THREADS ]];then
	N_THREADS=4
fi

echo "Threads: "$N_THREADS

isCompressed() {
	if (file $1 | grep -q compressed ) ; then
		return 1
	fi
	
	return 0
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
		if [[ $WGET_OUT == *.gz ]];then
			MAYBE_ZCAT="zcat"
		fi
		
		wget --no-check-certificate -q -O - "$URL" | $MAYBE_ZCAT | head -n $DOWNLOAD_LINE_LIMIT > $WGET_OUT 
	fi
}

runIndexFeatureFile() {
	$GATK IndexFeatureFile -I $1
}

bgzipAndIndexBed() {
	F=$1
	
	bgzip -f --threads $N_THREADS $F
	tabix -f ${F}.gz
}

ensureBedOrVcfSorted() {
	INPUT=$1
	TMP_OUT=tmp.txt
	
	cat $INPUT | grep -e '#' > $TMP_OUT
	cat $INPUT | grep -v '#' | sort --parallel $N_THREADS -V -k1,1 -k2,2n >> $TMP_OUT
	rm $INPUT
	mv $TMP_OUT $INPUT
}

ensureIndexed() {
	if -z isCompressed $1 ;then
		tabix -f $1
	else
		runIndexFeatureFile $1
	fi
}

ensureUnzippedInputSortedAndIndexed() {
	ensureBedOrVcfSorted $1
	runIndexFeatureFile $1
}

ensureBedSortedAndIndexed() {
	ensureUnzippedInputSortedAndIndexed $1
}

ensureVcfSortedAndIndexed() {
	ensureUnzippedInputSortedAndIndexed $1
}

ensureVcfGzIndex() {
	tabix -p vcf $1
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
