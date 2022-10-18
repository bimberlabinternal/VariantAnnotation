#!/bin/bash

set -e
set -x

# This will let the init scripts re-use previously downloaded files:
export ALLOW_DATASOURCE_REUSE=0

# This can be set to increase threads
#export N_THREADS=8

# This can be set to increase threads
#export N_THREADS=8

# The purpose of this script will be to iterate all subdirs and call init.sh within that data source
for DIR in */;do
	SCRIPT=$DIR/init.sh
	if [ -e $SCRIPT ];then
		cd $DIR
		export SCRIPT_DIR=../scripts
		bash init.sh
		cd ../
	fi
done
