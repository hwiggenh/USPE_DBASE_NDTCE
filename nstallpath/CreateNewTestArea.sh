#!/bin/bash
# =======================================================================
# FILE:		 	CreateNewTestArea.sh 
# TYPE:			bash shell script
# PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
# PREREQUISITS:	bash, mysql installation with database USPE installed, DBDATA directory
# USAGE:			CreateNewTestArea.sh
#
# DESCRIPTION:	script opens dialog to read parameters from user
# 				A TestArea is a rectangualr Area on which the tests take place
#				
# OUTPUT:		creates entry in USPE database in table TestArea
# 
# TODO:			add transformation of TestArea into structure coordinates
# 
# AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
# COPYRIGHT: 	none -- do whatever you want to do with this script 
# WARRANTY:		none -- absolutely no warranty - use at your own risk  
# REVISION:  	2022-08-23 initial draft 
# ======================================================================== 
source ./USPE_ENV.sh

echo create new TestArea
echo 'pls input: 
	Name (free text  may not be empty)
	Description (free text may not be empty)
	SizeX (positive integer number - no decimal point - size in mm may not be empty or 0 )
	SizeY (positive integer number - no decimal point - size in mm may not be empty or 0)
	Notes (free text if input is empty datetime and user will be stored in this field )'
echo
echo

echo -n "Name: "
read -r Name

echo -n "Descriptiom: "
read -r Description

echo -n "SizeX: "
read -r SizeX
SX=$(( SizeX ))
[[ $? -ne 0 ]] && echo no valid number && exit
[[  $SX -le 0   ]]  && echo "positive integer number > 0 expected" && exit


echo -n "SizeY: "
read -r SizeY
SY=$(( SizeY ))
[[ $? -ne 0 ]] && echo no valid number && exit
[[  $SY -le 0   ]]  && echo "positive integer number > 0 expected" && exit


echo -n "Notes: "
read -r Notes
[[ $Notes == "" ]] && Notes='(select concat( "created: ", CURRENT_TIMESTAMP()," by: ", current_user))' || Notes=\"$Notes\"

echo Name: $Name
echo Description: $Description
echo SizeX: $SX
echo SizeY: $SY
echo Notes: $Notes

SQL="insert into TestArea values (NULL,\"$Name\",\"$Description\",$SX,$SY,$Notes);"
RET=$(my_sql -s -e "$SQL")	# call mysql DB USPE 
[[ $? -ne 0 ]] && echo "Error in query $SQL" && exit		# check error on call


exit
	
