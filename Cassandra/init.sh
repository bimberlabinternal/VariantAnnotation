#!/bin/bash

set -e
set -x

# NOTE: the cassandra sources are huge and cannot be easily subset, so dont run this during testing
if [[ ${SKIP_LARGE_SOURCES:=0} == 1 ]] ;then
	echo 'Skipping Cassandra since SKIP_LARGE_SOURCES is set'
	exit 0
fi

if [[ -z ${SCRIPT_DIR:=} ]] ;then
	SCRIPT_DIR=../scripts
fi

source ${SCRIPT_DIR}/initFunctions.sh

# The purpose of this script is to download cassandra data sources from the web, and reformat as needed.

URL=ftp.hgsc.bcm.edu/Software/Cassandra/version_15.4.10/dataSourcesApr15.tar.gz
TEMP_FILE=dataSourcesApr15.tar.gz
downloadSourceFile $URL $TEMP_FILE

tar -zxvf $TEMP_FILE

# Remove duplicate data sources
rm -r CADD
rm -r ORegAnno
rm -r Exac

# the following datasources are adapted from cassandra 15.4 and are structured for funcotator
./init_ARIC.sh
./init_DBSCSNV.sh
./init_ENCODE.sh
./init_ERB.sh
./init_FANTOM.sh
./init_funseq2.sh
./init_funseqlike.sh
./init_Grasp.sh
./init_Phylop.sh
./init_SGMT.sh
./init_SiPhy.sh
./init_TFBS.sh

# Clean up directory to rm extra files
rm !(dataSourcesApr15.tar.gz|init.sh|init_*|)