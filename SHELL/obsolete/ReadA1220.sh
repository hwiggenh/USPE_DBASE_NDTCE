#!/bin/bash
#
# FILE:		 	ReadA1220.sh
# AUTHOR:	 	Herbert Wiggenhauser
# USAGE:		<path to file>/ReadA1200.sh <filepath> [flag for svgplot, default: true]
# COPYRIGHT: 	
# REVISION:  	2022-08-23 initial draft 
# 
# shell script reads file as binary and converts content into 16bit signed integer array - very slow
# for simplicity and demonstration - should be done with more appropriate tools (e.g. phyton)
# 
# creates very simple SVG plot of integer array in temporaray file and opens viewer to display
#
# testfile: /opt-brix/Daten/IZFP_BASF_RISSE/Examples/A1220Point/2.raw
export LC_ALL=C    												# make sure we aren't in a multibyte locale

																# filepath provided?
[[ ${#*} -lt 1 ]] && echo "no parameters given - abort" && exit
USID=$1;
DPLOT=${2:-true}												# default is svgplot  

# get FileInfo from USPEData for USID
SQL='select
	JSON_UNQUOTE( json_extract(U.FileInfo,"$.FileName"))
	,JSON_UNQUOTE( json_extract(U.FileInfo,"$.FilePath")) 
	,JSON_UNQUOTE( json_extract(U.FileInfo,"$.FileType")) 
	from USPEData U 
	where U.ID='$USID';'
	
# echo $SQL
RET=$(mysql --defaults-group-suffix=1 USPE -s -e "$SQL")
[[ $? -ne 0 ]] && echo "Error in query $SQL" && exit

# echo len ${#RET[@]}  ${RET[@]} 

arr=(${RET// / });	#split return array at spaces 
# echo len ${#arr[@]}  ${arr[@]} 
# for v in ${arr[@]}; do echo $v; done;

[[ ${#arr[@]} -ne 3 ]] && echo wrong length of return for $SQL - abort && exit;
FN=${arr[0]}; # Filename
FP=${arr[1]}; # Path
[[ ${arr[2]} != "A1220" ]] && echo not A1220 data! - abort && exit;

# echo $FN $FP																# file exists and is readable?

FILESIZE=$(stat -c%s "$FP/$FN")			# get filesize in bytes and check
[[ $FILESIZE -ne 80000 ]] && echo Filesize $FILESIZE is not 80000 - abort && exit
# echo FILESIZE: $FILESIZE

ARR=();															# create empty array
#
# main program
#
source svgvec.txt
source ReadBinary.txt

A1220Read "$FP/$FN"												# read file and convert to int16 array ARR

[[ $DPLOT == "true" ]] && SVGVEC;  							# create SVG plot of AScan and opens viewer

echo "D O N E"
exit

