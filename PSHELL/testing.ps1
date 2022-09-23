# write-host "hi " 
Function Test-CommandExists
{
 Param ($command)
 $oldPreference = $ErrorActionPreference
 $ErrorActionPreference = ‘stop’
 try {if(Get-Command $command){$true}}
 Catch {$false}
 Finally {$ErrorActionPreference=$oldPreference}
} 
write-host (Test-CommandExists SQLCALL)
if (! (Test-CommandExists SQLCALL)) { . ./SQLQUERY.ps1}
write-host (Test-CommandExists SQLCALL)


exit

#end function test-CommandExists
$pfad = "../SQL/CreateExampleMIRAData.sql"

function ReadSqlScript([string]$pfad) 
{
	$res = [string]@()
	$s = Get-Content -Path $pfad
	# remove all after  "--"
	foreach ($line in $s)
	{
		if ( $line.IndexOf('--') -eq 0 ) { continue }
		if ( $line.IndexOf('--') -lt 0 ) { 
			$res += $line
		} else {
			$res += $line.Substring(0, $line.IndexOf('--'))
		}
	}
}
ReadSqlScript $pfad
# (Get-Content -Path "../SQL/CreateExampleMIRAData.sql" -Raw).Replace("`n"," ")




exit
$j0 = "GemInfo"
$Item = "Pitch"
$Val = 12
$TSID = 2

	$SQL = "update TestSeries set Setting=JSON_SET(Setting,`"$.$j0.$Item`",$Val) where ID=$TSID;"


write-host $SQL
exit
. ./SQLQUERY.ps1

$DBDATA = "/home/herotto/code/USPE_DBASE_NDTCE/DATA"
$SQLConnectString = "server=Brix-Herb;port=3306;uid=USPEuser;pwd=NDT-CEDB;database=USPE"

# write-host "read SQLQUERY " 


#$SQLQ = "insert into TestSeries values (NULL,`"safds  adg gad`",1,1,(select DeviceInfo from TestEquipment where ID = 1),`"eqb r gw`");"
$SQLQ = "insert into TestSeries values (NULL,`"safds  adg gad`",1,1
, JSON_SET(
	(select DeviceInfo from TestEquipment where ID = 1)
	,'$.MAP'
	,JSON_OBJECT('XMAP0',12,'YMAP0',25,'XMAPINC',20,'YMAPINC',120)
	)
,(select concat( `"created: `", CURRENT_TIMESTAMP(),`" by: `", current_user)));"

write-host $SQLQ


$ERG = SQLCALL $SQLQ

write-host "SQLCALL returns: " + $ERG.LI
$TSID = $ERG.LI
write-host "TSID: $TSID"

exit

$XMAPINC = 20
$YMAPINC = 120
$XMAP0 = 12
$YMAP0 = 25

$SQLQ = "select JSON_SET(@Setting, '$.MAP',JSON_OBJECT('XMAP0',$XMAP0,'YMAP0',$YMAP0,'XMAPINC',$XMAPINC,'YMAPINC',$YMAPINC)) "
$SQLQ += " from  TestSeries where ID = $TSID;"


$ERG = SQLCALL $SQLQ

write-host "SQLCALL returns: "  $ERG
