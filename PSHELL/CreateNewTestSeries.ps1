<# =======================================================================
 FILE:		 	CreateNewTestSeries.ps1 
 TYPE:			M$ powershell script
 PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
 PREREQUISITS:	power shell, mysql installation with database USPE installed, DBDATA directory
 USAGE:			CreateNewTestSeries
 				needs TestArea and TestEquipment entries in database USPE

 DESCRIPTION:	script opens dialog to read parameters from user
 				A TestSeries is a collection of tests with one type of TestEquipment
 				on one specific TestArea. Within a testSeries, Settings of the test 
 				device may not change
				
 OUTPUT:		creates entry in USPE database in table TestSeries
 
 TODO:			
 
 AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
 COPYRIGHT: 	none -- do whatever you want to do with this script 
 WARRANTY:		none -- absolutely no warranty - use at your own risk  
 REVISION:  	2022-08-23 initial draft 
======================================================================== #>

function CreateNewTestSeries()
{
Write-Host Create new TestSeries
Write-Host 
Write-Host  "please input: 
	Name (free text  may not be empty)
	TestAreaID (positive integer number references TestArea.ID must exist!)
	TestEquipmentID (positive integer number references TestEquipment.ID must exist!)
	Setting (valid json string)
	Notes (free text should not be null, default Timestamp and user)"

$Name 			= Read-Host -Prompt 'Name ?> '
$TestAreaID		= Read-Host -Prompt 'TestAreaID ?> '
$TestAreaID 	= $TestAreaID -as [int]
if ( (! $TestAreaID) -or $TestAreaID -lt 1 ) { 
	Write-Host "Invalid Input $TestAreaID"
	exit	
}
$TestEquipmentID = Read-Host -Prompt 'TestEquipmentID ?> '
$TestEquipmentID 	= $TestEquipmentID -as [int]
if ( (! $TestEquipmentID) -or $TestEquipmentID -lt 1 ) { 
	Write-Host "Invalid Input $TestEquipmentID"
	exit	
}
$Setting 		= Read-Host -Prompt 'Test Settings must be valid Json string ?> '
if ( $Setting.length -eq 0 )  { $Setting = "{}" }
if ( ! $(Test-Json $Setting) ) {
	Write-Host "Invalid Input $Setting"
	exit	
}
$Notes 			= Read-Host -Prompt 'TestSeries Notes ?> '
if ( $Notes.length -eq 0 ) {
	 $Notes = '(select concat( "created: ", CURRENT_TIMESTAMP()," by: ", current_user))' 
} else {
	$Notes = "`"$Notes`""
}
Write-Host 'provide MAP coordinates of Map (1/1) in TestArea'
$XMAP0 			= Read-Host -Prompt 'X of (1/1) (default 0) ?> '
if ( (! $XMAP0) -or $XMAP0 -lt 0 ) { $XMAP0 = 0   }
$YMAP0 			= Read-Host -Prompt 'Y of (1/1) (default 0) ?> '
if ( (! $YMAP0) -or $YMAP0 -lt 0 ) { $YMAP0 = 0 }

if ( $TestEquipmentID -eq 1 ) 
{
	Write-Host 'provide Map steps in x and y'
	$XMAPINC 			= Read-Host -Prompt 'X/col step in mm (default 50)?> '
	if ( (! $XMAPINC) ) {  $XMAPINC = 50 }
	$YMAPINC 			= Read-Host -Prompt 'Y/row step in mm (default 150)?> '
	if ( (! $YMAPINC) ) {  $YMAPINC = 150 }

} else { // MIRA is called from MIRA file upon upload 
	Write-Host 'MIRA Map steps will be read upon RawData upload'
	$XMAPINC = 100
	$YMAPINC = 100
}

$SQLQ = "insert into TestSeries values (NULL,`"$Name`",1,1
, JSON_SET(
	(select DeviceInfo from TestEquipment where ID = 1)
	,'$.MAP'
	,JSON_OBJECT('XMAP0',$XMAP0,'YMAP0',$YMAP0,'XMAPINC',$XMAPINC,'YMAPINC',$YMAPINC)
	), $Notes);"

. ./SQLQUERY.ps1
$RET =  SQLCALL $SQLQ

}


<# uncomment if used as standalone script
#
	$DBDATA = "/home/herotto/code/USPE_DBASE_NDTCE/DATA"
	$SQLConnectString = "server=Brix-Herb;port=3306;uid=USPEuser;pwd=NDT-CEDB;database=USPE"
	CreateNewTestSeries
#>
