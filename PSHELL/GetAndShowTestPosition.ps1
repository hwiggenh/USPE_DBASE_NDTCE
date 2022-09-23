<# =======================================================================
 FILE:		 	GetAndShowTestPosition.ps1 
 TYPE:			M$ powershell script
 PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
 PREREQUISITS:	power shell, mysql installation with database USPE installed, DBDATA directory
 USAGE:			CreateNewTestArea [int]$ID [string]$TAB
 				ID: ID of TAB
 				TAB: TestArea, TestSeries or USPEData
 				for TestSeries, the MAP grid is included in the script

 DESCRIPTION:	helper script to create SVGPlot of Tests on TestArea
				
 OUTPUT:		creates SVGplot file in temporary file and displays the plot
 
 TODO:			include more info in plot (type, ID, size)
 
 AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
 COPYRIGHT: 	none -- do whatever you want to do with this script 
 WARRANTY:		none -- absolutely no warranty - use at your own risk  
 REVISION:  	2022-08-23 initial draft 
======================================================================== #>


function GetAndShowTestPosition([int]$ID,[string]$TAB)
{						
																# sql entry to retrieve position information for selected tests 
	$SQLQ = 'select US.ID,TX,TY,RX,RY, TA.SizeX,TA.SizeY 		
		
		,json_extract(TS.Setting,"$.MAP.XMAP0") X0
		,json_extract(TS.Setting,"$.MAP.YMAP0") Y0
		,json_extract(TS.Setting,"$.MAP.XMAPINC") XD
		,json_extract(TS.Setting,"$.MAP.YMAPINC") YD
		from USPEData US 
		join TestSeries TS on TS.ID=US.TestSeriesID 
		join TestArea TA on TA.ID = TS.TestAreaID 
		where '+$TAB+'.ID='+$ID+';'

	. ./SQLQUERY.ps1 			# load SQLCALL
	$RET = SQLCALL $SQLQ

	if ( $RET.Length -gt 0 ) { 									# if there are tests in the db create the plot						
		. ./svgvec.ps1 											# load svg function 
		$nix = SVGTestArea $RET $TAB 
	} else { 
		Write-Host ("no entries in database found for TAB:", $TAB,"ID:", $ID -join " ") 
	}

return 

}

