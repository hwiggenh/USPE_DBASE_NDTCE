<# =======================================================================
 FILE:		 	ReadBinary.ps1 
 TYPE:			M$ powershell script
 PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
 PREREQUISITS:	power shell, mysql installation with database USPE installed, DBDATA directory
 FUNCTIONS:		ReadAScan [int]$USPEDataID [switch]$SVGPLOT
 				MIRAVecRead [string[]]$FP [int]$DO [int]$DR [int]$DL
				A1220Read [string]$FP
 DESCRIPTION:	shell script reads file as binary and converts content into 16bit 
				signed integer array - very slow
 				for simplicity and demonstration 
				for production should be done with more appropriate tools (e.g. phyton)
 
 TODO:			add more TestEquipment read routines
 
 AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
 COPYRIGHT: 	none -- do whatever you want to do with this script 
 WARRANTY:		none -- absolutely no warranty - use at your own risk  
 REVISION:  	2022-08-23 initial draft 
======================================================================== #>

# reads A1040_MIRA binary file 
# extraxts vector at position given by DR and converts to signed 16bit integer array
# FP: filepath to raw data file
# DO: byte offset for file header
# DR: vector offset
# DL: vector length
# OUTPUT: signed integer arry (AScan vector)
function MIRAVecRead([string[]]$FP,[int]$DO,[int]$DR,[int]$DL)
{

$b = Get-Content -Path $FP -AsByteStream -Raw		# reads file into binary array
# Write-Host $b.length ($DO+2*$DR+2*$DL)

										
[int16[]]$arr=@(0) * $DL  							# creates new-object int16[] length DL

for ($i=0;$i -lt (2*$DL); $i=$i+2) {				# loop through bin array, converts to int
	$arr[ [int][Math]::Floor( $i / 2) ] += [bitconverter]::ToInt16($b,($i+$DO+2*$DR))
}

return $arr											# returns int array of length DL

}

# reads A1220 binary file and converts to signed 16bit integer array
# downscales factor of 40 (40 MS/s -> 1 MS/s) 
# btw: reads any file as binary and converts content to 16 bit signed integers
# averages 10 values to reduce sampling rate by factor of 10
# FP: filepath to raw data file
# OUTPUT:		signed integer arry (AScan vector)

function A1220Read([string]$FP)
{

$b = Get-Content -Path $FP -AsByteStream -Raw		# reads file into binary array

[int16[]]$arr=@(0) * ($b.length/20) 				# creates new-object int16[] $b.length/2

for ($i=0;$i -lt $b.length; $i=$i+2) {				# loop through bin array, converts to int, downsamples
	$arr[ [int][Math]::Floor( $i / 20) ] += [bitconverter]::ToInt16($b,$i)
}

return $arr											# returns int array of length 4000

}

# reads AScan pomited to by entry in USPEDataa with ID 
# creates SVGPlot of AScan if SVGPLOT is not false
# USPEDataID: ID of entry in USPEData
# sVGPLOT: bool value, if false, no Plot is created
# OUTPUT: svgfile if SVGPLOT = "false"	
function ReadAScan([int]$USPEDataID,[switch]$SVGPLOT)
{

	if ($SVGPLOT.IsPresent) {		# if SVGPLOT is not false, call SVGPLOT
		 Write-Host "Parameter 2 value is $SVGPLOT"
	} else { 
		$SVGPLOT = $true 
	}

	$SQLQ="select
		JSON_UNQUOTE( json_extract(U.FileInfo,'$.FileName')) FN
		,JSON_UNQUOTE( json_extract(U.FileInfo,'$.FilePath')) FP
		,JSON_UNQUOTE( json_extract(U.FileInfo,'$.FileType')) FT
		,JSON_UNQUOTE( ifnull(json_extract(U.FileInfo,'$.DataRange'),0)) DR
		,JSON_UNQUOTE( ifnull(json_extract(TS.Setting,'$.BinData.ByteOffsetFile'),0)) DO
		,JSON_UNQUOTE( ifnull(json_extract(TS.Setting,'$.BinData.VecLength'),2048)) DL
		from USPEData U 
		join TestSeries TS on TS.ID=U.TestSeriesID 
		where U.ID=$USPEDataID;"
														# load SQLCALL
	. ./SQLQUERY.ps1
	$ERG = SQLCALL $SQLQ

	if ( $ERG.FT -eq "A1040_MIRA" ) {
		$VEC = MIRAVecRead ($ERG.FP,$ERG.FN -join "/") $ERG.DO $ERG.DR $ERG.DL	
	} elseif ( $ERG.FT -eq "A1220" ) {
		$VEC = A1220Read ($ERG.FP,$ERG.FN -join "/") 
	} else { 	
		Write-Host "File type not defined"
		return
	}
	if ( $SVGPLOT ) { 
		. ./svgvec.ps1
		SVGVEC $VEC   
	}	
}

