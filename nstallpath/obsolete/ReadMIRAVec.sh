#!/bin/bash
#
# FILE:		 	ReadMIRAVec.sh
# AUTHOR:	 	Herbert Wiggenhauser
# USAGE:		<path to file>/ReadA1200.sh USDataID [flag for svgplot, default: true]
# COPYRIGHT: 	
# REVISION:  	2022-08-23 initial draft 
# 
# shell script reads file as binary and converts content into 16bit signed integer array - very slow
# for simplicity and demonstration - should be done with more appropriate tools (e.g. phyton)
# 
# creates very simple SVG plot of integer array in temporaray file and opens viewer to display
#
export LC_ALL=C    												# make sure we aren't in a multibyte locale

																
[[ ${#*} -lt 1 ]] && echo "no parameters given - abort" && exit # requires min 1 parameter

USID=$1;														# use parameter 1 as USDataID
DPLOT=${2:-true}												# default is svgplot  
																# otherwise it does not make sense to run the script

# get FileInfo, Offset, DataRange for USData Entry qith ID USID
SQL='select
	JSON_UNQUOTE( json_extract(U.FileInfo,"$.FileName"))
	,JSON_UNQUOTE( json_extract(U.FileInfo,"$.FilePath")) 
	,JSON_UNQUOTE( json_extract(U.FileInfo,"$.FileType")) 
	,JSON_UNQUOTE( json_extract(U.FileInfo,"$.DataRange")) 
	,JSON_UNQUOTE(json_extract(TS.Setting,"$.BinData.ByteOffsetFile"))
	,JSON_UNQUOTE(json_extract(TS.Setting,"$.BinData.VecLength"))
	from USPEData U 
	join TestSeries TS on TS.ID=U.TestSeriesID 
	where U.ID='$USID';'
	
# echo $SQL
RET=$(mysql --defaults-group-suffix=1 USPE -s -e "$SQL")	# call mysql DB USPE 
[[ $? -ne 0 ]] && echo "Error in query $SQL" && exit		# check error on call
# echo len ${#RET[@]}  ${RET[@]} 
arr=(${RET// / }); 											# split return at spcaes
# echo len ${#arr[@]}  ${arr[@]} 
# for v in ${arr[@]}; do echo $v; done;
[[ ${#arr[@]} -ne 6 ]] && echo wrong length of return for $SQL - abort && exit; # exact 6 elements in return required
FN=${arr[0]};		# FileName
FP=${arr[1]};		# FilePath
[[ ${arr[2]} != "MIRA_A1040" ]] && echo not MIRA data! - abort && exit; # is data of type MIRA_A1040?
DR=${arr[3]};		# Vector offset 
DO=${arr[4]};		# FileOffset
DL=${arr[5]};		# Vector Length
# echo $DO $DL $DR

FILESIZE=$(stat -c%s "$FP/$FN")									# get and check filesize in bytes
[[ $FILESIZE -ne 270464 ]] && echo Filesize $FILESIZE is not 270464  - abort && exit
#echo FILESIZE: $FILESIZE

ARR=();															# create empty array
#
# main program
#
source svgvec.txt
source ReadBinary.txt

	# needs 4 parameters 1: Filepath 2: Offset DO 3: offset DR 4: DataLength DL
MIRAVecRead	"$FP/$FN" $DO $DR $DL												# read file and convert to int16 array ARR
[[ $DPLOT == "true" ]] && SVGVEC;  							# create SVG plot of AScan and opens viewer

echo "D O N E"
exit

