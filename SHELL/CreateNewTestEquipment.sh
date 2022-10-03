#!/bin/bash
# =======================================================================
# FILE:		 	CreateNewTestArea.ps1 
# TYPE:			M$ powershell script
# PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
# PREREQUISITS:	power shell, mysql installation with database USPE installed, DBDATA directory
# USAGE:			CreateNewTestArea
#
# DESCRIPTION:	script opens dialog to read parameters from user
# 				A TestArea is a rectangualr Area on which the tests take place
#				
# OUTPUT:		creates entry in USPE database in table TestArea
# 
# TODO:			
# 
# AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
# COPYRIGHT: 	none -- do whatever you want to do with this script 
# WARRANTY:		none -- absolutely no warranty - use at your own risk  
# REVISION:  	2022-08-23 initial draft 
# ========================================================================
source ./USPE_ENV.sh


echo create new TestEquipment
echo 'pls input: 
	Name (free text  may not be empty)
	Model (free text may not be empty)
	DeviceInfo (Json Object)
	Notes (free text if input is empty datetime and user will be stored in this field )'
echo
echo

echo -n "Name: "
read -r Name

echo -n "Model: "
read -r Model

echo 'DeviceInfo is a Json string of 3 JSON Objects, see default values below
	1) "BinData":  {
			"DataType": "int",			number type					REQUIRED
			"Width": 16,				in bits						REQUIRED
			"Order": "BEF				bigEndian					REQUIRED
			}
	2) "GeomInfo": {
			"ZeroOffset": -30,			distance TestPoint-Sensor#1 REQUIRED
			"Pitch": 60,				sensor pitch				REQUIRED
			"NofSensors": 2				ebd							REQUIRED
			}
	3) "Setting":  {
			"SensorType":"M2502",		free text
			"SampRate": 10000000,		Sampling Rate in 1/s 		REQUIRED
			"Frequency":50000,			free value
			"DevDelay":"5.0E-6",		if != 0 					REQUIRED
			"DevGain":80,				if absolute Values needed 	REQUIRED
			}
	Please change default settings and/or add values if necessary'

DeviceInfo='{"BinData":  {"DataType": "int","Width": 16,"Order": "BEF"},
			"GeomInfo": {"ZeroOffset": -30,"Pitch": 60,"NofSensors": 2 },
			"Setting": {"SampRate": 1000000}}'
echo -n "Notes: "
read -r Notes
[[ $Notes == "" ]] && Notes='(select concat( "created: ", CURRENT_TIMESTAMP()," by: ", current_user))' || Notes=\"$Notes\"

echo Name: $Name
echo Model: $Model
echo DeviceInfo: $DeviceInfo
echo Notes: $Notes

SQL="set @DeviceInfo = '$DeviceInfo';"
SQL="insert into TestEquipment values (NULL,\"$Name\",\"$Model\",'$DeviceInfo', $Notes);"

echo $SQL
	
RET=$(my_sql -s -e "$SQL")	# call mysql DB USPE 
[[ $? -ne 0 ]] && echo "Error in query $SQL" && exit		# check error on call

exit
	
