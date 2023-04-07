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

$GATK FuncotatorDataSourceDownloader --somatic --validate-integrity --extract-after-download
$GATK FuncotatorDataSourceDownloader --germline --validate-integrity --extract-after-download

cp -r funcotator_dataSources.v1.7.20200521g/* ../
cp -r funcotator_dataSources.v1.7.20200521s/* ../


