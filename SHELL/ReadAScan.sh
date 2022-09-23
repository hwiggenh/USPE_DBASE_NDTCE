#!/bin/bash
# =======================================================================
# FILE:		 	ReadAScan.sh
# TYPE:			bash shell script
# PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
# PREREQUISITS:	bash shell, mysql installation with database USPE installed, DBDATA directory
# FUNCTIONS:	MIRAVecRead [string[]]$FP [int]$DO [int]$DR [int]$DL
#				A1220Read [string]$FP
# DESCRIPTION:	shell script reads file as binary and converts content into 16bit 
#				signed integer array - very slow
# 				for simplicity and demonstration 
#				for production should be done with more appropriate tools (e.g. phyton)
# OUTPUT:		creates SVGPlot of AScan
#
# TODO:			add more TestEquipment read routines
# 
# AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
# COPYRIGHT: 	none -- do whatever you want to do with this script 
# WARRANTY:		none -- absolutely no warranty - use at your own risk  
# REVISION:  	2022-08-23 initial draft 
# ========================================================================
export LC_ALL=C    												# make sure we aren't in a multibyte locale
source ./USPE_ENV.sh

#
# MIRAVecRead reads one vector from MIRA binary file and converts to signed 16bit integer array
# USAGE: MIRAVecRead	"$FP/$FN" $DO $DR $DL											
# DO: Header Offset DR: Vector offset DL: Vector length
# stores vector in ARR
#
function MIRAVecRead {

  while read c;
  do
	ARR+=( $(hex2signInt $c) ) 							# make it signed integer
  done <<< $( hexdump -v -s $((2*$3+$2)) -n $((2*$4)) -e '/2 "%x\n"' $1 ) # dump file as 16bit hex numbers into loop

  return
}
#
# reads A1220 binary file and converts to signed 16bit integer array
# btw: reads any file as binary and converts content to 16 bit signed integers
# averages 10 values to reduce sampling rate by factor of 10
# stores vector in global array ARR
#
function A1220Read {

  JJ=0; 														# loop counter
  V=0;															# average value

  while read c;
  do
	ARR[$(($JJ/10))]=$(( ${ARR[$(($JJ/10))]} + $(hex2signInt $c) )) # make it signed integer

	# V=$(( $V + $(hex2signInt $c) )) 							# make it signed integer
	# [[ $(( $JJ%10 )) -eq 9 ]] && ARR+=( $(($V/10)) ) && V=0  	# average 10 samples to reduce sampling rate to 1MS/s 
																# integer division!
	JJ=$(( $JJ+1 ))												# increase loop counter
  done <<< $( hexdump -v -e '/2 "%x\n"' $1 ) 					# dump file as 16bit hex numbers into loop

  return
}
#
# hex2signInt performs conversion of hex to 16 bit signed integer -- very slow!!
# https://onlinetoolz.net/unsigned-signed
#
function hex2signInt() {
																# conversion of 16bit hex to signed decimal:
																# if highest bit is set 			(16#$1 & 16#8000) -gt 1
																# invert binary  					(16#$1 ^ 16#FFFF)
																# subtract 1 						(16#$1 ^ 16#FFFF)-1
																# take result as negative number 	-((16#$1 ^ 16#FFFF)-1)
	[[ $(( 16#$1 & 16#8000 )) -ge 1 ]] && echo  $(( -((16#$1 ^ 16#FFFF) - 1) )) && return
	echo $(( 16#$1 )) 
}

#
# main function
#
																
[[ ${#*} -lt 1 ]] && echo "no parameters given - abort" && exit # requires min 1 parameter

USID=$1;														# use parameter 1 as USDataID
DPLOT=${2:-true}												# default is svgplot  
																# otherwise it does not make sense to run the script

																# get FileInfo, Offset, DataRange 
																# for USData Entry qith ID USID
SQL='select
	JSON_UNQUOTE( json_extract(U.FileInfo,"$.FileName"))
	,JSON_UNQUOTE( json_extract(U.FileInfo,"$.FilePath")) 
	,JSON_UNQUOTE( json_extract(U.FileInfo,"$.FileType")) 
	,JSON_UNQUOTE( ifnull(json_extract(U.FileInfo,"$.DataRange"),0)) 
	,JSON_UNQUOTE( ifnull(json_extract(TS.Setting,"$.BinData.ByteOffsetFile"),0))
	,JSON_UNQUOTE( ifnull(json_extract(TS.Setting,"$.BinData.VecLength"),2048))
	from USPEData U 
	join TestSeries TS on TS.ID=U.TestSeriesID 
	where U.ID='$USID';'
	
					# echo $SQL
RET=$(mysql --defaults-group-suffix=7 USPE -s -e "$SQL")	# call mysql DB USPE 
[[ $? -ne 0 ]] && echo "Error in query $SQL" && exit		# check error on call
					# echo len ${#RET[@]}  ${RET[@]} 
arr=(${RET// / }); 											# split return at spcaes
					# echo len ${#arr[@]}  ${arr[@]} 
					# for v in ${arr[@]}; do echo $v; done;
[[ ${#arr[@]} -ne 6 ]] && echo wrong length of return for $SQL - abort && exit; # exact 6 elements in return required
FN=${arr[0]};		# FileName
FP=${arr[1]};		# FilePath
					# [[ ${arr[2]} != "MIRA_A1040" ]] && echo not MIRA data! - abort && exit; # is data of type MIRA_A1040?
DR=${arr[3]};		# Vector offset 
DO=${arr[4]};		# FileOffset
DL=${arr[5]};		# Vector Length
					# echo $DO $DL $DR

ARR=();															# create empty array
#
# get the data
#
source svgvec.sh	# get svg function

					# read binary data
					# A1220 needs 1 parameter 1: Filepath 
[[ ${arr[2]} == "A1220" ]] && A1220Read "$FP/$FN" 			

					# A1040_MIRA needs 4 parameters 1: Filepath 2: Offset DO 3: offset DR 4: DataLength DL
					# extracts the AScan USID from the MIRA file
[[ ${arr[2]} == "A1040_MIRA" ]]  && MIRAVecRead "$FP/$FN" $DO $DR $DL			

					# read file and convert to int16 array ARR
[[ $DPLOT == "true" && ${#ARR[@]} > 0 ]] && SVGVEC;  			# create SVG plot of AScan and opens viewer


exit

