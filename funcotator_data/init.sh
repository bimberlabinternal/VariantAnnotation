#!/bin/bash

set -e
set -x

# NOTE: the funcotator sources are huge and cannot be easily subset, so dont run this during testing
if [[ ${SKIP_LARGE_SOURCES:=0} == 1 ]] ;then
	echo 'Skipping Funcotator since SKIP_LARGE_SOURCES is set'
	exit 0
fi

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

if [[ `isProcessingCompleted` == 0 ]];then
	exit 0
fi

$GATK FuncotatorDataSourceDownloader --somatic --validate-integrity --extract-after-download
$GATK FuncotatorDataSourceDownloader --germline --validate-integrity --extract-after-download

rm -Rf funcotator_dataSources.v1.7.20200521s/gencode
rm -Rf funcotator_dataSources.v1.7.20200521s/gencode_xhgnc
rm -Rf funcotator_dataSources.v1.7.20200521s/gencode_xrefseq
rm -Rf funcotator_dataSources.v1.7.20200521s/clinvar

rm -Rf funcotator_dataSources.v1.7.20200521g/gencode

find ./funcotator_dataSources.v1.7.20200521g type -d -exec cp -r {} ../ \;
find ./funcotator_dataSources.v1.7.20200521s type -d -exec cp -r {} ../ \;

rm -Rf funcotator_dataSources.v1.7.20200521g/
rm -Rf funcotator_dataSources.v1.7.20200521s/

touch $DONE_FILE
