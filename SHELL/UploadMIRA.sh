#!/bin/bash
# =======================================================================
# FILE:		 	UploadMIRA.sh 
# TYPE:			M$ powershell script
# PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
# PREREQUISITS:	power shell, mysql installation with database USPE installed, DBDATA directory
# USAGE:		UploadMIRA  $taid $tsid 
# 				taid: ID of TestArea
# 				tsid: ID of TestSeries
# 				Directory $DBDATA/TA0<taid>/TS0<tsid> must exist and raw data file(s) 
# 				must be in this directory. 
# 				Naming of files should match the <col>_<row>.lbv MAP pattern 
#				corresponding entries in the tables TestArea and TestSeries must exist
#
# DESCRIPTION:	script reads entries in TestSeries and TestEquipment to calculate 
# 				the transformation of sensor position in the TestArea.
# 				The transformation needs the MIRA geometry info and the map info from the file names
#				and user input 
#				
# OUTPUT:		creates entries in USPEData for each individual AScan
# 
# TODO:			include rotation of test device in transformation
# 
# AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
# COPYRIGHT: 	none -- do whatever you want to do with this script 
# WARRANTY:		none -- absolutely no warranty - use at your own risk  
# REVISION:  	2022-08-23 initial draft 
# ========================================================================
source ./USPE_ENV.sh

export LC_ALL=C   						# make sure we aren't in a multibyte locale
#
# TSSettUpdate updates json object in testSeries with values in MIRA header
#
function TSSettUpdate() {
	SQL="update TestSeries set Setting=JSON_SET(Setting,\"$.$1.$2\",$3) where ID=$TSID;"
	# echo $SQL
	my_sql -e "$SQL"
	[[ $? -ne 0 ]] && echo "Error inUpdateJson in TS $S $SQL" && exit
}
#
# returns reads MIRA header and initiates update of TestSeries
#
function MIRAHEAD() {

  MH=("NofSensors" "Pitch" "SampRate" "Frequency" "Periods" "Delay" "DevVelocity" "DevGain" "XMAPINC" "YMAPINC" "NAScans" "VecLength" "BinDataWidth") 
  declare -i J
  J=0;

  while read c;
  do
  	VAL=$(( 16#$c ))

  	[[ ${MH[J]} == "Pitch" 		]] && VAL=$((-1 * $VAL)) && TSSettUpdate "GeomInfo" ${MH[J]} $VAL
  	[[ ${MH[J]} == "SampRate" 	]] && VAL=$((1000 * $VAL)) && TSSettUpdate "Setting" ${MH[J]} $VAL

  	[[ ${MH[J]} == "VecLength" 	]] && TSSettUpdate "BinData" ${MH[J]} $VAL
  	
  	[[ ${MH[J]} == "Frequency" 	]] && TSSettUpdate "Setting" ${MH[J]} $VAL
  	[[ ${MH[J]} == "Periods" 	]] && TSSettUpdate "Setting" ${MH[J]} $VAL
  	[[ ${MH[J]} == "Delay" 		]] && TSSettUpdate "Setting" ${MH[J]} $VAL
  	[[ ${MH[J]} == "DevVelocity" ]] && TSSettUpdate "Setting" ${MH[J]} $VAL
  	[[ ${MH[J]} == "DevGain" 	]] && TSSettUpdate "Setting" ${MH[J]} $VAL
  	[[ ${MH[J]} == "XMAPINC" || ${MH[J]} == "YMAPINC"  ]] && TSSettUpdate "MAP" ${MH[J]} $VAL    	
  	J+=1; 
  done <<< $( hexdump -v -n 52 -e '/4 "%x\n"' $1 ) 		# dump first 52 bytes of file as 32bit hex numbers into loop


  return
}

TAD=$(printf "TA%03d" $1);
TSD=$(printf "TS%03d" $2);
TSID=$2;
TEID=2; # MIRA

											# test if testSeries exists
RET=$(my_sql -s -e "select ID from TestSeries where ID=$TSID;")
[[ $? -ne 0 ]] && echo "Error in Query select ID from TestSeries where ID=$TSID; - abort" && exit
[[ ${RET[0]} == "" ]] && echo "TestSeries $TSID does not exist - abort" && exit

declare -i SEQ								# each MIRA test (=66 AScans) gets its individual SEQ 
SEQ=0;
HEAD=0										# flag for MIRA Head read
for fn in $DATADIR/$TAD/$TSD/*.lbv;
do
	(( ! $HEAD )) && HEAD=1 && MIRAHEAD $fn;
	TS=$(date -r $fn '+%Y-%m-%d %H:%M:%S')  # modtime of file fn
	my_sql -s -e "set @TSID=$TSID;set @TEID=$TEID;set @SEQ=$SEQ;\
			set @FN=\"$(basename $fn)\";\
			set @FP=\"${fn%/*}\"; \
			set @TS=\"${TS}\"; \
			set @TSID=\"${TSID}\"; \
			source ../SQL/CreateExampleMIRAData.sql;"
	SEQ+=1;

done

exit
