#!/bin/bash

set -e
set -x

# NOTE: the funcotator sources are huge and cannot be easily subset, so dont run this during testing
if [[ -z ${SKIP_FUNCOTATOR:=} ]] ;then
	exit 0
fi

SCRIPT_DIR=../scripts
source ${SCRIPT_DIR}/initFunctions.sh

$GATK FuncotatorDataSourceDownloader --somatic --validate-integrity --extract-after-download
$GATK FuncotatorDataSourceDownloader --germline --validate-integrity --extract-after-download

cp -r funcotator_dataSources.v1.7.20200521g/* ../
cp -r funcotator_dataSources.v1.7.20200521s/* ../


