#!/bin/bash
# =======================================================================
# FILE:		 	CreateNewTestSeries.sh 
# TYPE:			bash shell script
# PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
# PREREQUISITS:	power shell, mysql installation with database USPE installed, DBDATA directory
# USAGE:		CreateNewTestSeries
# 				needs TestArea and TestEquipment entries in database USPE
#
# DESCRIPTION:	script opens dialog to read parameters from user
# 				A TestSeries is a collection of tests with one type of TestEquipment
# 				on one specific TestArea. Within a testSeries, Settings of the test 
# 				device may not change
#				
# OUTPUT:		creates entry in USPE database in table TestSeries
# 
# TODO:			
# 
# AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
# COPYRIGHT: 	none -- do whatever you want to do with this script 
# WARRANTY:		none -- absolutely no warranty - use at your own risk  
# REVISION:  	2022-08-23 initial draft 
#========================================================================


echo create new TestSeries
echo 'pls input: 
	Name (free text  may not be empty)
	Description (free text may not be empty)
	TestAreaID (positive integer number references TestArea.ID must exist!)
	TestEquipmentID (positive integer number references TestEquipment.ID must exist!)
	Setting (valid json string)
	Notes (free text should not be null, default Timestamp and user)'
echo
echo

echo -n "Name: "
read -r Name

echo -n "TestAreaID: "
read -r TestAreaID

echo -n "TestEquipmentID: "
read -r TestEquipmentID

echo 'provide minimum info for MAP coordinates of Map (1/1) in TestArea and Map steps in x and y'
echo -n "x,y coordinate of Map point (1/1) (eg 124,455) : "
read -r MAP0
if [[ MAP0 == "" ]] 
then
	XMAP0=50 
	YMAP0=150
else 
	XMAP0=$(( ${MAP0%,*} ))
	YMAP0=$(( ${MAP0#*,} ))
fi

echo -n '... and dx,dy step length in Map (eg 50,150, empty input will set default values (100,150) 
		 for Device MIRA values will be overwritten with device settings on upload: ' 
read -r DMAP
if [[ DMAP == "" ]] 
then
	XMAPINC=50 
	YMAPINC=150
else 
	XMAPINC=$(( ${DMAP%,*} ))
	YMAPINC=$(( ${DMAP#*,} ))
fi

echo 'TestEquipment Settings are collected from the TestEquipment referenced. 
If necessary please change specific values with the query #10 as provided in the Queries.sql file  '

echo -n "Notes: "
read -r Notes
[[ $Notes == "" ]] && Notes='(select concat( "created: ", CURRENT_TIMESTAMP()," by: ", current_user))' || Notes=\"$Notes\"

echo Name: $Name
echo TestAreaID: $TestAreaID
echo TestEquipmentID: $TestEquipmentID
echo MAP: {"MAP": {"XMAPINC": $XMAPINC, "YMAPINC": $YMAPINC "XMAP0": $XMAP0 "YMAP0": $YMAP0 }}
echo Notes: $Notes


SQL="set @Setting = (select DeviceInfo from TestEquipment where ID = $TestEquipmentID);
	set @Setting = (select JSON_SET(@Setting, '$.MAP',JSON_OBJECT('XMAP0',$XMAP0,'YMAP0',$YMAP0,'XMAPINC',$XMAPINC,'YMAPINC',$YMAPINC))); 	
	insert into TestSeries values (NULL,\"$Name\",$TestAreaID,$TestEquipmentID,@Setting,$Notes);"
RET=$(mysql --defaults-group-suffix=7 USPE -s -e "$SQL")	# call mysql DB USPE 
[[ $? -ne 0 ]] && echo "Error in query $SQL" && exit		# check error on call


exit
	
