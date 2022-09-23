#!/bin/bash
# =======================================================================
# FILE:		 	GetAndShowTestPosition.sh
# TYPE:			bash shell script
# PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
# PREREQUISITS:	power shell, mysql installation with database USPE installed, DBDATA directory
# USAGE:		CreateNewTestArea $ID $TAB
# 				ID: ID of TAB
# 				TAB: TestArea, TestSeries or USPEData
# 				for TestSeries, the MAP grid is included in the script
#
# DESCRIPTION:	helper script to create SVGPlot of Tests on TestArea
#				
# OUTPUT:		creates SVGplot file in temporary file and displays the plot
# 
# TODO:			include more info in plot (type, ID, size)
# 
# AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
# COPYRIGHT: 	none -- do whatever you want to do with this script 
# WARRANTY:		none -- absolutely no warranty - use at your own risk  
# REVISION:  	2022-08-23 initial draft 
# ========================================================================

export LC_ALL=C    								# make sure we aren't in a multibyte locale
source ./USPE_ENV.sh

source svgvec.sh								# get svg fucntions
												# parameter provided?
[[ ${#*} -lt 1 ]] && echo "no parameters given - abort" && exit

ID=$1											# first parameter 
TAB=${2:-US}									# default US for parameter 2 - other option TS, TA

												# sql entry to retrieve position information for selected tests 
SQL='select US.ID,TX,TY,RX,RY, TA.SizeX,TA.SizeY 
	,json_extract(TS.Setting,"$.MAP.XMAP0") 
	,json_extract(TS.Setting,"$.MAP.YMAP0") 
	,json_extract(TS.Setting,"$.MAP.XMAPINC") 
	,json_extract(TS.Setting,"$.MAP.YMAPINC") 
	from USPEData US 
	join TestSeries TS on TS.ID=US.TestSeriesID 
	join TestArea TA on TA.ID = TS.TestAreaID 
	where '$TAB'.ID='$ID';'

# call mysql 
RET=$(mysql --defaults-group-suffix=7 USPE -s -e "$SQL")
[[ $? -ne 0 ]] && echo "Error in query $SQL" && exit			# check error on call
[[ $RET == "" ]] && echo Empty return for query: $SQL && exit	# return empty --> error in SQL

SVGTestArea "$RET" $TAB

exit

