<# =======================================================================
 FILE:		 	CreateNewTestEquipment.ps1 
 TYPE:			M$ powershell script
 PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
 PREREQUISITS:	power shell, mysql installation with database USPE installed, DBDATA directory
 FUNCTION:		CreateNewTestEquipment

 DESCRIPTION:	script opens dialog to read parameters from user
 				A TestEquipment is a definition of a test device 
 				holding 
 				- geometric information (position of transducers relativ to test point)
 				- format of the raw data file
 				- default settings of device
				it may be sensible to have multiple definitions of the same physical device for different settings 				
				
 OUTPUT:		creates entry in USPE database in table TestEquipment
 
 TODO:			
 
 AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
 COPYRIGHT: 	none -- do whatever you want to do with this script 
 WARRANTY:		none -- absolutely no warranty - use at your own risk  
 REVISION:  	2022-08-23 initial draft 
======================================================================== #>

# creates entry in USPE database table TestEquipment

function CreateNewTestEquipment() 
{
write-host create new TestEquipment
write-host 'please input: 
	Name (free text  may not be empty)
	Model (free text may not be empty)
	DeviceInfo (Json Object)
	Notes (free text if input is empty datetime and user will be stored in this field )'
write-host
write-host

$Name 			= Read-Host -Prompt 'Name ?> '						# input name
$Model 			= Read-Host -Prompt 'Model ?> '						# model

																	# show info on DeviceInfo
write-host 'DeviceInfo is a Json string of 3 JSON Objects, see default values for A1220:
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

																	# set deviceInfo
$DeviceInfo = '{"BinData":  {"DataType": "int","Width": 16,"Order": "BEF"},
			"GeomInfo": {"ZeroOffset": -30,"Pitch": 60,"NofSensors": 2 },
			"Setting": {"SampRate": 1000000}}'
			

$Notes 		= Read-Host -Prompt 'TestEquipment Notes ?> '			# notes
if ($Notes.length -eq 0 ) {											# if user does not give notes, use timestamp and user id
	$Notes = '(select concat( "created: ", CURRENT_TIMESTAMP()," by: ", current_user))' 
} else {
	$Notes = "`"$Notes`""
}

										# write input to user
write-host Name: $Name
write-host Model: $Model
write-host DeviceInfo: $DeviceInfo
write-host Notes: $Notes
										# compile sql query 
$SQLQ = "insert into TestEquipment values (NULL,`"$Name`",`"$Model`",'$DeviceInfo',$Notes);"

. ./SQLQUERY.ps1 
SQLCALL $SQLQ							# execute insert into table
	

}

# uncomment if used as standalone script
<#
	$DBDATA = "/home/herotto/code/USPE_DBASE_NDTCE/DATA"
	$SQLConnectString = "server=Brix-Herb;port=3306;uid=USPEuser;pwd=NDT-CEDB;database=USPE"
	CreateNewTestEquipment
#>

	
