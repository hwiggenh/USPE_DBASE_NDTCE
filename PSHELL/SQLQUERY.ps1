<# =======================================================================
 FILE:		 	SQLQUERY.ps1 
 TYPE:			M$ powershell script
 PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
 PREREQUISITS:	power shell, mysql installation with database USPE installed with user USPEuser, DBDATA directory
 USAGE:			SQLCALL SQLQIN
 				SQLQIN: one or several chained SQL actions
 DESCRIPTION:	performs SET, UPDATE, INSERT, SELECT actions on database USPE
 				
 
 OUTPUT:		On Select, returns object of queried database content
 
 TODO:			include more complex database actions	
 
 AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
 COPYRIGHT: 	none -- do whatever you want to do with this script 
 WARRANTY:		none -- absolutely no warranty - use at your own risk  
 REVISION:  	2022-08-23 initial draft 
======================================================================== #>

function SQLCALL([string[]]$SQLQIN)
{
# $SQLQIN = $SQLQIN.Replace("`n"," ")					# remove line feeds in string
# $SQLQIN = [regex]::Replace($SQLQIN, "\s+"," ") 		# collapse whitespace chars to one space 

Add-Type -Assembly /usr/local/mysql-connector-net-8.0.19/v4.8/MySql.Data.dll
													# Connect to remote MySQL server using $SQLConnectString 
$db_con = New-Object MySql.Data.MySqlClient.MySqlConnection
$db_con.ConnectionString = $SQLConnectString 
$db_con.Open()

$sql = New-Object MySql.Data.MySqlClient.MySqlCommand
$sql.Connection = $db_con


$RES = @()											# init array for results

$prep = $false										# set flag if prepare has been set

													# split SQLQ on ";" and execute commands 
foreach ( $SQLQ in  $SQLQIN)		# .Split(";"))
{
	IF( [regex]::Match($SQL ,'^\s*;?\s*$').Success) { break }		# skip empty lines or containing only ";"
	
	write-host "SQLQ: " $SQLQ.TrimStart().Split(" ")[0].ToUpper() --> $SQLQ
	$sql.CommandText = $SQLQ
	switch ( $SQLQ.TrimStart().Split(" ")[0].ToUpper() )
	{
	"SET" {
		if ( ! $prep ) 								# prepare called only on first SET
		{
			$sql.Prepare()
			$prep = $true
		}
				# split set command at "@"
		$ssplit = $SQLQ.Split("@")[1]
				# split at "="
		$ssplit = $ssplit.Split("=")
		write-host $ssplit
		$sql.Parameters.AddWithValue($ssplit[0], $ssplit[1])
		$sql.Parameters[$ssplit[0]].Value = $ssplit[1]
	}
	"UPDATE" {
		$RES += $sql.ExecuteNonQuery()
	}	
	"INSERT" {
		$RES += $sql.ExecuteNonQuery()
	}	
	"SELECT" {
		$data = $sql.ExecuteReader()
		# Present data to RES
		While ($data.Read())
		{
			$object = New-Object -TypeName PSObject
			$i = 0
			while ($i -lt $data.FieldCount) {
				$object | Add-Member -Name $data.GetName($i) -MemberType Noteproperty -Value $data.GetValue($i)
				$i++
			}
			$RES += $object
		}
	}
	"CREATE" {
		$RES += $sql.ExecuteNonQuery()
	}
	}
}
$db_con.close() 										# close db connection

return $RES 											# return RES object
}

