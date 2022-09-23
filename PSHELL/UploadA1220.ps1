<# =======================================================================
 FILE:		 	UploadA1220.ps1 
 TYPE:			M$ powershell script
 PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
 PREREQUISITS:	power shell, mysql installation with database USPE installed, DBDATA directory
 USAGE:			UploadA1220  [int]$taid [int]$tsid 
 				taid: ID of TestArea
 				tsid: ID of TestSeries
 				Directory $DBDATA/TA0<taid>/TS0<tsid> must exist and raw data file(s) 
 				must be in this directory. 
 				Naming of files should match the <col>-<row>.raw MAP pattern 
 				corresponding entries in the tables TestArea and TestSeries must exist

 DESCRIPTION:	script gets entries in TestSeries and TestEquipment to calculate 
 				the transformation of sensor position in the TestArea.
 				The transformation needs the A1220 geometry info and the map info from the file names 
				
 OUTPUT:		creates entries in USPEData for each individual A1220 raw datafile
 
 TODO:			include rotation of test device in transformation
 
 AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
 COPYRIGHT: 	none -- do whatever you want to do with this script 
 WARRANTY:		none -- absolutely no warranty - use at your own risk  
 REVISION:  	2022-08-23 initial draft 
======================================================================== #>

function UploadA1220([int]$taid, [int]$tsid)
{
	. ./SQLQUERY.ps1 									# load SQL function 
	$LTAID = 'TA{0:d3}' -f $taid 						# create dir name TA<Taid> with leading zeros
	$LTSID = 'TS{0:d3}' -f $tsid						# create dir name TS<Taid> with leading zeros

	$FP = ($DBDATA,$LTAID,$LTSID -join "/")  			# FilePath for raw data files 

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


	$SEQ = $ERG.SEQ 									# each file upload own SEQ
														# loop through raw data files
	foreach ( $fn in Get-ChildItem -Path ($DBDATA,$LTAID,$LTSID,"*.raw" -join "/") )
	{

		$TS = (Get-Item $fn).LastWriteTime.ToString('yyyy-MM-dd HH:mm:00')		# file modificationtime stamp
		$N = (Get-Childitem $fn).Name					# extract COL and ROW from file name
		$FN = $N.Substring(0,$N.IndexOf('.'))
		$FN = $N.Substring(0,$N.IndexOf('.'))
		$COLIND = $FN.Substring(0,$FN.IndexOf('_'))	 
		$ROWIND = $FN.Substring($FN.IndexOf('_')+1)

														# calc transducer positions 
		$TX = [int]$ERG.ZOFF + [int]$ERG.XMAP0 + ([int]$COLIND - 1) * [int]$ERG.XMAPINC;
		$RX = [int]$ERG.ZOFF + [int]$ERG.PIT + [int]$ERG.XMAP0 + ([int]$COLIND - 1) * [int]$ERG.XMAPINC;
		$TY = [int]$ERG.YMAP0 + ([int]$ROWIND - 1) * [int]$ERG.YMAPINC;		
		$RY = [int]$ERG.YMAP0 + ([int]$ROWIND - 1) * [int]$ERG.YMAPINC;
				
																				# create json file info
		$FI = "{`"DataRange`": 0,`"FileName`":`"$N`", `"FilePath`": `"$FP`",`"FileType`":`"A1220`"}"
		
																				# SQL for insert  into table USData
		$SQLQ = "insert into USPEData values (NULL,$tsid,`"$TS`",$TX,$TY,$RX,$RY,$SEQ,'$FI');"
		$NIX = SQLCALL $SQLQ
				
		$SEQ = $SEQ + 1;								# update seq count
	}
}

<# uncomment if used as standalone script
#

	$DBDATA = "/home/herotto/code/USPE_DBASE_NDTCE/DATA"
	$SQLConnectString = "server=Brix-Herb;port=3306;uid=USPEuser;pwd=NDT-CEDB;database=USPE"
	$taid = 1
	$tsid = 1
	UploadA1220 $taid $tsid
#>

	
