<# =======================================================================
 FILE:		 	welcome.ps1 
 TYPE:			M$ powershell script
 PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
 PREREQUISITS:	power shell, mysql installation with database USPE installed, DBDATA directory
 USAGE:			<path to file>/welcome.ps1 
 				needs DBDATA and SQLConnectString set to local values

 DESCRIPTION:	shell script opens dialog to basic database actions
				
 OUTPUT:		none
 
 TODO:			add more actions
 
 AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
 COPYRIGHT: 	none -- do whatever you want to do with this script 
 WARRANTY:		none -- absolutely no warranty - use at your own risk  
 REVISION:  	2022-08-23 initial draft 
======================================================================== #>

function welcome()
{
# set global variables

if ( ! ( Get-Variable 'DBDATA' -Scope 'Global' -ErrorAction 'ignore') ) 
{
    write-host "DBDATA not defined -- abort"
    exit 
}
# $SQLConnectString: 		set in $PROFILE
if ( ! ( Get-Variable 'SQLConnectString' -Scope 'Global' -ErrorAction 'ignore') ) 
{
    write-host "SQLConnectString not defined -- abort"
    exit 
}

Write-Host 
Write-Host 

Write-Host  "Welcome, what would you like to do
	0 - Quit
	1 - Create TestSeries
	2 - Create TestArea
	3 - Create TestEquipment
	4 - Upload A1220 tests
	5 - Upload A1040-MIRA tests
	6 - Display AScan (USData.ID needed)
	7 - Display TestArea (TestArea.ID needed)
	8 - Display Testseries (TestSeries.ID needed)
"	
$Cho = Read-Host -Prompt 'Default=0 ?> '
$Cho = $Cho -as [int]

if ( (! $Cho) -or $Cho -gt 8 -or $Cho -lt 0 ) { $Cho = 0 }

Write-Host "Your Choice '$Cho'"

switch ( $Cho )
{
	0 { "bye, bye ..."
		exit
	}
	1 { "Create TestSeries"
		. ./CreateNewTestSeries.ps1
		CreateNewTestSeries
	}
	2 { "Create TestArea"
		. ./CreateNewTestArea.ps1
		CreateNewTestArea
	}
	3 { "Create TestEquipment"
		. ./CreateNewTestEquipment.ps1
		CreateNewTestSeries
	}
	4 { "Upload A1220 test(s)" 
		$ChoTA = Read-Host -Prompt 'TestArea.ID Default=1 ?> '
		$ChoTA = $ChoTA -as [int]

		if ( (! $ChoTA)  -or $ChoTA -lt 1 ) { $ChoTA = 1 }
		$ChoTS = Read-Host -Prompt 'TestSeries.ID Default=1 ?> '
		$ChoTS = $ChoTS -as [int]

		if ( (! $ChoTS)  -or $ChoTS -lt 1 ) { $ChoTS = 1 }
		. ./UploadA1220.ps1
		$nix = UploadA1220 $ChoTA $ChoTS
	  }
	5 { "Upload A1040-MIRA test(s)" 
		$ChoTA = Read-Host -Prompt 'TestArea.ID Default=1 ?> '
		$ChoTA = $ChoTA -as [int]

		if ( (! $ChoTA)  -or $ChoTA -lt 1 ) { $ChoTA = 1 }
		$ChoTS = Read-Host -Prompt 'TestSeries.ID Default=1 ?> '
		$ChoTS = $ChoTS -as [int]

		if ( (! $ChoTS)  -or $ChoTS -lt 1 ) { $ChoTS = 1 }
		$nix = UploadMIRA $ChoTA $ChoTS	
	}
	6 { "Display AScan"
		$Cho2 = Read-Host -Prompt 'USData.ID Default=1 ?> '
		$Cho2 = $Cho2 -as [int]

		if ( (! $Cho2)  -or $Cho2 -lt 1 ) { $Cho2 = 1 }

		. ./ReadAScan.ps1
		$nix = ReadAScan $Cho2
	  }
	7 { "Display TestArea" 
		$Cho2 = Read-Host -Prompt 'TestArea.ID Default=1 ?> '
		$Cho2 = $Cho2 -as [int]

		if ( (! $Cho2)  -or $Cho2 -lt 1 ) { $Cho2 = 1 }

		. ./GetAndShowTestPosition.ps1
		$nix = GetAndShowTestPosition $Cho2 "TA"
	}
	8 { "Display Testseries" 
		$Cho2 = Read-Host -Prompt 'TestSeries.ID Default=1 ?> '
		$Cho2 = $Cho2 -as [int]

		if ( (! $Cho2)  -or $Cho2 -lt 1 ) { $Cho2 = 1 }

		. ./GetAndShowTestPosition.ps1
		$nix = GetAndShowTestPosition $Cho2 "TS"
	}
}
welcome
}
welcome
exit

