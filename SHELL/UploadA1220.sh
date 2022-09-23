#!/bin/bash
# =======================================================================
# FILE:		 	UploadA1220.sh 
# TYPE:			bash shell script
# PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
# PREREQUISITS:	bash shell, mysql installation with database USPE installed, DBDATA directory
# USAGE:		UploadA1220  $taid $tsid 
# 				taid: ID of TestArea
# 				tsid: ID of TestSeries
# 				Directory $DBDATA/TA0<taid>/TS0<tsid> must exist and raw data file(s) 
# 				must be in this directory. 
# 				Naming of files should match the <col>-<row>.raw MAP pattern 
# 				corresponding entries in the tables TestArea and TestSeries must exist
#
# DESCRIPTION:	script gets entries in TestSeries and TestEquipment to calculate 
# 				the transformation of sensor position in the TestArea.
# 				The transformation needs the A1220 geometry info and the map info from the file names 
#				
# OUTPUT:		creates entries in USPEData for each individual A1220 raw datafile
# 
# TODO:			include rotation of test device in transformation
# 
# AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
# COPYRIGHT: 	none -- do whatever you want to do with this script 
# WARRANTY:		none -- absolutely no warranty - use at your own risk  
# REVISION:  	2022-08-23 initial draft 
# ========================================================================
source ./USPE_ENV.sh
export LC_ALL=C    												# make sure we aren't in a multibyte locale

TAD=$(printf "TA%03d" $1);
TSD=$(printf "TS%03d" $2);
for fn in $DATADIR/$TAD/$TSD/*.raw;					# loop through files in dir
do
	TS=$(date -r $fn '+%Y-%m-%d %H:%M:%S')  		# modtime of file fn
	mysql --defaults-group-suffix=7 USPE -e "set @TSID=1;set @TEID=1;\
			set @FN=\"$(basename $fn)\";\
			set @FP=\"${fn%/*}\"; \
			set @TSID=\"${2}\"; \
			set @TS=\"${TS}\"; \
			source ../SQL/CreateExampleUSPEData.sql;"
done
exit
