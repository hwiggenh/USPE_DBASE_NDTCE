<# =======================================================================
 FILE:		 	CreateNewTestArea.ps1 
 TYPE:			M$ powershell script
 PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
 PREREQUISITS:	power shell, mysql installation with database USPE installed, DBDATA directory
 USAGE:			CreateNewTestArea

 DESCRIPTION:	script opens dialog to read parameters from user
 				A TestArea is a rectangualr Area on which the tests take place
				
 OUTPUT:		creates entry in USPE database in table TestArea
 
 TODO:			
 
 AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
 COPYRIGHT: 	none -- do whatever you want to do with this script 
 WARRANTY:		none -- absolutely no warranty - use at your own risk  
 REVISION:  	2022-08-23 initial draft 
======================================================================== #>


function CreateNewTestArea()
{
write-host create new TestArea
write-host 'pls input: 
	Name (free text  may not be empty)
	Description (free text may not be empty)
	SizeX (positive integer number - no decimal point - size in mm may not be empty or 0 )
	SizeY (positive integer number - no decimal point - size in mm may not be empty or 0)
	Notes (free text if input is empty datetime and user will be stored in this field )'
write-host
write-host

$Name = Read-Host -Prompt 'TestArea Name ?> '
$Description = Read-Host -Prompt 'TestArea Description ?> '

$SizeX 			= Read-Host -Prompt 'TestArea Size X (default 1600)?> '
if ( (! $SizeX) -or $SizeX -lt 0 ) { $SizeX = 1600   }
$SizeY 			= Read-Host -Prompt 'TestArea Size Y (default 1000)?> '
if ( (! $SizeY) -or $SizeY -lt 0 ) { $SizeY = 1000   }

$Notes 			= Read-Host -Prompt 'TestArea Notes (default: creation time and user) ?> '
if ( $Notes.length -eq 0 ) {
	 $Notes = '(select concat( "created: ", CURRENT_TIMESTAMP()," by: ", current_user))' 
} else {
	$Notes = "`"$Notes`""
}

# write-host Name: $Name
# write-host Description: $Description
# write-host SizeX: $SX
# write-host SizeY: $SY
# write-host Notes: $Notes

$SQLQ = "insert into TestArea values (NULL,`"$Name`",`"$Description`",$SizeX,$SizeY,$Notes);"
# write-host $SQLQ

. ./SQLQUERY.ps1
SQLCALL $SQLQ
	
}

# . ./SQLQUERY.ps1

# uncomment if used as standalone script
<#
	$DBDATA = "/home/herotto/code/USPE_DBASE_NDTCE/DATA"
	$SQLConnectString = "server=Brix-Herb;port=3306;uid=USPEuser;pwd=NDT-CEDB;database=USPE"
	CreateNewTestArea
#>

		
