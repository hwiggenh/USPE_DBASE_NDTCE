#!/bin/bash

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
	ARR[$(($JJ/10))]=$(( ${ARR[$(($JJ/10))]} + $(hex2signInt $c) )) 								# make it signed integer
  	# echo $JJ $(($JJ/10)) $(hex2signInt $c) ${ARR[$(($JJ/10))]}
	# [[ $(( $JJ%10 )) -eq 9 ]] && ARR+=( $(($V/10)) ) && V=0  	# average 10 samples to reduce sampling rate to 1MS/s 
																# integer division!
	JJ=$(( $JJ+1 ))												# increase loop counter
  done <<< $( hexdump -v -e '/2 "%x\n"' $1 ) 					# dump file as 16bit hex numbers into loop

  return
}

function XXA1220Read {

  JJ=0; 														# loop counter
  V=0;															# average value

  while read c;
  do
	V=$(( $V + $(hex2signInt $c) )) 							# make it signed integer
	[[ $(( $JJ%10 )) -eq 9 ]] && ARR+=( $(($V/10)) ) && V=0  	# average 10 samples to reduce sampling rate to 1MS/s 
																# integer division!
	JJ=$(( $JJ+1 ))												# increase loop counter
  done <<< $( hexdump -v -s 0 -n 400 -e '/2 "%x\n"' $1 ) 					# dump file as 16bit hex numbers into loop

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


ARR=();															# create empty array
A1220Read "/home/herotto/code/USPE_DBASE_NDTCE/DATA/TA001/TS001/1_1.raw"
echo ${ARR[@]:0:20}

