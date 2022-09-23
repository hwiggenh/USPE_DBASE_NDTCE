<# =======================================================================
 FILE:		 	UploadMIRA.ps1 
 TYPE:			M$ powershell script
 PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
 PREREQUISITS:	power shell, mysql installation with database USPE installed, DBDATA directory
 USAGE:			UploadMIRA  [int]$taid [int]$tsid 
 				taid: ID of TestArea
 				tsid: ID of TestSeries
 				Directory $DBDATA/TA0<taid>/TS0<tsid> must exist and raw data file(s) 
 				must be in this directory. 
 				Naming of files should match the <col>_<row>.lbv MAP pattern 
 				corresponding entries in the tables TestArea and TestSeries must exist

 DESCRIPTION:	script gets entries in TestSeries and TestEquipment to calculate 
 				the transformation of sensor position in the TestArea.
 				The transformation needs the MIRA geometry info and the map info from the file names 
				
 OUTPUT:		creates entries in USPEData for each individual AScan
 
 TODO:			include rotation of test device in transformation
 
 AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
 COPYRIGHT: 	none -- do whatever you want to do with this script 
 WARRANTY:		none -- absolutely no warranty - use at your own risk  
 REVISION:  	2022-08-23 initial draft 
======================================================================== #>

# helper function to update entries in TestSeries Setting

function TSSettUpdate([string]$j0,[string]$Item,[int]$Val) {

	$SQLQ = "update TestSeries set Setting=JSON_SET(Setting,`"$.$j0.$Item`",$Val) where ID=$TSID;"
	# Write-Host $SQLQ
	$NIX = SQLCALL $SQLQ
}

# updates json object in TestSeries with values from MIRA header

function MIRAHEAD([string]$fn) 
{

														# read lbv
	$b = Get-Content -Path $fn -AsByteStream -Raw
	
														# extract speciic info from header	
	$Val = [bitconverter]::ToInt16($b,4)
	TSSettUpdate "GeomInfo" "Pitch"  ([int]$Val) 	

	$Val = [bitconverter]::ToInt16($b,8)
	TSSettUpdate "Setting" "SampRate"  ([int]$Val * 1000.) 	

	$Val = [bitconverter]::ToInt16($b,44)
	TSSettUpdate "BinData" "VecLength"  ([int] $Val )	

	$Val = [bitconverter]::ToInt16($b,12)
	TSSettUpdate "Setting" "Periods"   ([int]$Val) 	
	
	$Val = [bitconverter]::ToInt16($b,20)
	TSSettUpdate "Setting" "Delay"   ([int]$Val) 	
	
	$Val = [bitconverter]::ToInt16($b,24)
	TSSettUpdate "Setting" "DevVelocity"   ([int]$Val) 	
	
	$Val = [bitconverter]::ToInt16($b,28)
	TSSettUpdate "Setting" "DevGain"   ([int]$Val) 	
	
	$Val = [bitconverter]::ToInt16($b,32)
	TSSettUpdate "MAP" "XMAPINC"   ([int]$Val) 	
	
	$Val = [bitconverter]::ToInt16($b,36)
	TSSettUpdate "MAP" "YMAPINC"   ([int]$Val) 	
	
  return
}

# creates entries in USData for each AScan extracted from the files in directory $DBDATA/TA0<taid>/TS0<tsid>
# calculates transformation from device to TestArea using MAP info from file name

function UploadMIRA([int]$taid, [int]$tsid)
{
	. ./SQLQUERY.ps1 									# load SQL function 

	$LTAID = 'TA{0:d3}' -f $taid 						# create dir name TA<Taid> with leading zeros
	$LTSID = 'TS{0:d3}' -f $tsid 						# create dir name TS<Taid> with leading zeros

	$FP = ($DBDATA,$LTAID,$LTSID -join "/") 			# FilePath for raw data files 

	$SEQ = 0;											# each MIRA test (=66 AScans) gets a unique SEQ number within TestSeries 
	$HEAD = $false;										# header is only read once

														# sql query for TestEquipment and seq info

	$SQLQ = "select ifnull(json_extract(DeviceInfo,'$.GeomInfo.ZeroOffset'),-30) ZOFF
			,ifnull(json_extract(DeviceInfo,'$.GeomInfo.Pitch'),60) PIT
			,ifnull(json_extract(Setting,'$.MAP.XMAP0'),100) XMAP0
			,ifnull(json_extract(Setting,'$.MAP.YMAP0'),100) YMAP0
			,ifnull(json_extract(Setting,'$.MAP.XMAPINC'),50) XMAPINC
			,ifnull(json_extract(Setting,'$.MAP.YMAPINC'),80) YMAPINC
			,ifnull(max(Sequence),-1) + 1 SEQ
			from TestSeries TS
			join USPEData U on U.TestSeriesID = TS.ID
			join TestEquipment TE on TE.ID = TS.TestEquipmentID
			where TS.ID = $TSID
			and U.TestSeriesID=TS.ID"
	$ERG = SQLCALL $SQLQ
	$SEQ = $ERG.SEQ 									# update SEQ SEQ

														# loop through raw data files
	foreach ( $fn in Get-ChildItem -Path ($DBDATA,$LTAID,$LTSID,"*.lbv" -join "/") )
	{
		if ( ! $HEAD ) { 								# read MIRA file header only for first file
			MIRAHEAD $fn
			$HEAD = $true;
		}

		$TS = (Get-Item $fn).LastWriteTime.ToString('yyyy-MM-dd HH:mm:00')		# file modificationtime stamp
		$N = (Get-Childitem $fn).Name											# extract COL and ROW from file name
		$FN = $N.Substring(0,$N.IndexOf('.'))
		$COLIND = $FN.Substring(0,$FN.IndexOf('-'))	 
		$ROWIND = $FN.Substring($FN.IndexOf('-')+1)

		
		$T = 0;											# transmitter counter 
		$C = 0;											# offset counter for AScan
		WHILE ($T -lt 11) {								# loop over transmitters
			$R = $T + 1;								# receiver counter
			WHILE ($R -le 11) {							# loop over receivers < transmitter
														# calc transducer positions 
				$TX = [int]$ERG.ZOFF + [int]$ERG.PIT * [int]$T + [int]$ERG.XMAP0 + ([int]$COLIND - 1) * [int]$ERG.XMAPINC;
				$RX = [int]$ERG.ZOFF + [int]$ERG.PIT * [int]$R + [int]$ERG.XMAP0 + ([int]$COLIND - 1) * [int]$ERG.XMAPINC;
				$TY = [int]$ERG.YMAP0 + ([int]$ROWIND - 1) * [int]$ERG.YMAPINC;		
				$RY = [int]$ERG.YMAP0 + ([int]$ROWIND - 1) * [int]$ERG.YMAPINC;
																				# create json file info
				$FI = "{`"DataRange`": $C,`"FileName`":`"$N`", `"FilePath`": `"$FP`",`"FileType`":`"A1040_MIRA`"}"
																				# SQL for insert  into table USData
				$SQLQ = "insert into USPEData values (NULL,$tsid,`"$TS`",$TX,$TY,$RX,$RY,$SEQ,'$FI');"
				$NIX = SQLCALL $SQLQ
				
				$R = $R + 1;							# update receiver count
				$C = $C + 2048;							# update offest count
			}
			$T = $T + 1;								# update transmitter count
		};

		$SEQ = $SEQ + 1;								# update seq count
	}
}



<# uncomment if used as standalone script
#

	$DBDATA = "/home/herotto/code/USPE_DBASE_NDTCE/DATA"
	$SQLConnectString = "server=Brix-Herb;port=3306;uid=USPEuser;pwd=NDT-CEDB;database=USPE"
	$taid = 3
	$tsid = 2
	UploadMIRA $taid $tsid
#>

	
