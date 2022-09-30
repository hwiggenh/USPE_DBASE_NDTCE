
<# =======================================================================
 FILE:		 	InitialSetupDBandExamples.ps1 
 TYPE:			M$ powershell script
 PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
 PREREQUISITS:	power shell, mysql installation with database USPE installed with user USPEuser, DBDATA directory
 USAGE:			./InitialSetupDBandExamples.ps1
 DESCRIPTION:	creates database USPE 
 				includes sample raw data
				with tables TestEquipment, TestArea, TestSeries, USPEData
				creates definitions for TestEquipment ACS 1220 and A1040_MIRA
				creates sample TestAreas
				creates sample TestSeries for A1220 and MIRA scans
				reads data from Db and visualizes data and TestArea
 
 OUTPUT:		DataBase USPE, sample data, svg plots of sample data
 
 TODO:			
 
 AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
 COPYRIGHT: 	none -- do whatever you want to do with this script 
 WARRANTY:		none -- absolutely no warranty - use at your own risk  
 REVISION:  	2022-08-23 initial draft 
======================================================================== #>


# create DB from scratch
# define path of DataDir

# $DBDATA: 					set in $PROFILE
if ( ! ( Get-Variable 'DBDATA' -Scope 'Global' -ErrorAction 'ignore') ) 
{ute
    write-host "DBDATA not defined -- abort"
    exit 
}
# $SQLConnectString: 		set in $PROFILE
if ( ! ( Get-Variable 'SQLConnectString' -Scope 'Global' -ErrorAction 'ignore') ) 
{
    write-host "SQLConnectString not defined -- abort"
    exit 
}

# create user USPEuser with create insert delete 
# CREATE USER 'USPEuser'@'%' IDENTIFIED BY 'NDT-CEDB';
# GRANT ALL PRIVILEGES ON USPE .* TO 'USPEuser'@'%';
# GRANT SYSTEM_USER ON *.* TO 'USPEuser'@'%';
# FLUSH PRIVILEGES;
# SHOW GRANTS FOR 'USPEuser'@'%';

# create tables
mysql --defaults-group-suffix=7 USPE -e "source ../SQL/CreateExampleDB.sql"				
# [[ $? -ne 0 ]] && echo "Error in CreateExampleDB.sql" && exit
# define TestEquipment #1 A1220
mysql --defaults-group-suffix=7 USPE  -e "source ../SQL/CreateExampleEquipment.sql"			
# [[ $? -ne 0 ]] && echo "Error in CreateExampleEquipment.sql" && exit

# define TestAreas #1 and #2
mysql --defaults-group-suffix=7 USPE -e "source  ../SQL/CreateExampleTestArea.sql"				
# [[ $? -ne 0 ]] && echo "Error in CreateExampleTestArea.sql" && exit

# create stored procedures
# mysql --defaults-group-suffix=7 USPE -e "source ../SQL/StoredProcedures.sql"		

# create DIRs for TA001 and TA002
mkdir $DBDATA/TA001
mkdir $DBDATA/TA002

# define TestSeries #1 and #2
mysql --defaults-group-suffix=7 USPE -e "source  ../SQL/CreateExampleTestSeries.sql"	
# [[ $? -ne 0 ]] && echo "Error in CreateExampleTestSeries.sql" && exit

# upload usdata short line scan MIRA
mkdir $DBDATA/TA002/TS002
$TAID=2;
$TSID=2;
. ./UploadMIRA.ps1 
UploadMIRA $TAID $TSID

$USPEID=35;
. ./ReadAScan.ps1 
ReadAScan $USPEID

# upload usdata small area scan A1220 upload requires two parameters TAID and TSID
mkdir $DBDATA/TA001/TS001
cp $DBDATA/RAW/A1220/*.raw $DBDATA/TA001/TS001/
$TAID=1;
$TSID=1
. ./UploadA1220.ps1 
UploadA1220 $TAID $TSID

# read Ascan from USPEData ID=3 and plot it 
$USPEID=3;
ReadAScan $USPEID

# plot TestArea with positions of Map and USPEData Entry
. ./GetAndShowTestPosition.ps1
$nix = GetAndShowTestPosition 1 TA
$nix = GetAndShowTestPosition 2 TA
$nix = GetAndShowTestPosition 1 TS
$nix = GetAndShowTestPosition 2 TS
$nix = GetAndShowTestPosition 2 US


write-host "D O N E"
exit
