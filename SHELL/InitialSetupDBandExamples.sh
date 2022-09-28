#!/bin/bash
# =======================================================================
# FILE:		 	InitialSetupDBandExamples.sh 
# TYPE:			bash shell script
# PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
# PREREQUISITS:	bash shell, mysql installation with database USPE installed with user USPEuser, DBDATA directory
# USAGE:		./InitialSetupDBandExamples.sh
# DESCRIPTION:	creates database USPE 
# 				includes sample raw data
#				with tables TestEquipment, TestArea, TestSeries, USPEData
#				creates definitions for TestEquipment ACS 1220 and A1040_MIRA
#				creates sample TestAreas
#				creates sample TestSeries for A1220 and MIRA scans
#				reads data from DB and visualizes data and TestArea
#
# OUTPUT:		DataBase USPE, sample data, svg plots of sample data
# 
# TODO:			
# 
# AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
# COPYRIGHT: 	none -- do whatever you want to do with this script 
# WARRANTY:		none -- absolutely no warranty - use at your own risk  
# REVISION:  	2022-08-23 initial draft 
#========================================================================

export LC_ALL=C    												# make sure we aren't in a multibyte locale

# set environment
source ./USPE_ENV.sh

# check if alias my_sql is set
[[ "$(type -t my_sql)" = 'alias' ]] || { echo my_sql alias not set; exit; }

# create DB from scratch

# create user uspeuser with create insert delete 
# CREATE USER 'uspeuser'@'%' IDENTIFIED BY 'NDT-CEDB';
# GRANT ALL PRIVILEGES ON USPE .* TO 'uspeuser'@'%';
# GRANT SYSTEM_USER ON *.* TO 'uspeuser'@'%';
# FLUSH PRIVILEGES;
# SHOW GRANTS FOR 'uspeuser'@'%';

# create tables
my_sql < ../SQL/CreateExampleDB.sql				
[[ $? -ne 0 ]] && echo "Error in CreateExampleDB.sql" && exit
# define TestEquipment #1 A1220
my_sql < ../SQL/CreateExampleEquipment.sql				
[[ $? -ne 0 ]] && echo "Error in CreateExampleEquipment.sql" && exit

# define TestAreas #1 and #2
my_sql < ../SQL/CreateExampleTestArea.sql				
[[ $? -ne 0 ]] && echo "Error in CreateExampleTestArea.sql" && exit

# create stored procedures
my_sql < ../SQL/StoredProcedures.sql		

# create DIRs for TA001 and TA002
mkdir $DATADIR/TA001
mkdir $DATADIR/TA002

# define TestSeries #1 and #2
my_sql  < ../SQL/CreateExampleTestSeries.sql	
[[ $? -ne 0 ]] && echo "Error in CreateExampleTestSeries.sql" && exit

# upload usdata short line scan MIRA
mkdir $DATADIR/TA002/TS002
# copy data to dir
cp $DATADIR/RAW/A1040/*.lbv $DATADIR/TA002/TS002/
TAID=2;
TSID=2;
UploadMIRA.sh $TAID $TSID
USPEID=35;
ReadAScan.sh $USPEID

# upload usdata small area scan A1220 upload requires two parameters TAID and TSID
mkdir $DATADIR/TA001/TS001
# copy data to dir
cp $DATADIR/RAW/A1020/*.raw $DATADIR/TA001/TS001/
TAID=1;
TSID=1
UploadA1220.sh $TAID $TSID

# read Ascan from USPEData ID=3 and plot it 
USPEID=3;
ReadAScan.sh $USPEID


# plot TestArea with positions of Map and USPEData Entry
GetAndShowTestPosition.sh 1 TA
GetAndShowTestPosition.sh 2 TA
GetAndShowTestPosition.sh 1 TS
GetAndShowTestPosition.sh 2 TS
GetAndShowTestPosition.sh 2 US


echo "D O N E"
