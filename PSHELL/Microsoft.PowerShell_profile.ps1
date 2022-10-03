# Function ge {Set-Location -Path $home/Documents; gedit $args[0]}
Function ge {gedit $args[0]}

$DBDATA = "/tmp/USPE_DBASE_NDTCE-main/DATA/"								# set <installdir>/DATA

$SQLUSER="uspeuser"			# user for USPE		use your username
$SQLPW="NDT-CEDB"			# password			use your password for DB 
$SQLDB="uspedb"				# DB name			use your DBname
$SQLPORT=3306				# port 				typ. 3306 
$SQLHOST="db4free.net"		# mysql host		for local installation use "localhost"
$SQLPROMPT="uspe\>\ "		# db prompt			sets the prompt when access DB interactively	

$SQLUSER="USPEuser"			# user for USPE		use your username
$SQLPW="NDT-CEDB"			# password			use your password for DB 
$SQLDB="uspedb"				# DB name			use your DBname
$SQLPORT=3306				# port 				typ. 3306 
$SQLHOST="Brix-Herb"		# mysql host		for local installation use "localhost"
$SQLPROMPT="uspe\>\ "		# db prompt			sets the prompt when access DB interactively	

# create user USPEuser with create insert delete 
# CREATE USER 'USPEuser'@'%' IDENTIFIED BY 'NDT-CEDB';
# GRANT ALL PRIVILEGES ON uspedb .* TO 'USPEuser'@'%';
# GRANT SYSTEM_USER ON *.* TO 'USPEuser'@'%';
# FLUSH PRIVILEGES;
# SHOW GRANTS FOR 'USPEuser'@'%';
# create database if not exists uspedb;

$SQLConnectString = "server=$SQLHOST;port=$SQLPORT;uid=$SQLUSER;pwd=$SQLPW;database=$SQLDB" 	# see mysql manual

function ReadSqlScript([string]$pfad) 
{
	$res = [string[]]@()
	$s = Get-Content -Path $pfad
	
	# remove all after  "--"
	
	$fine = "";
	foreach ($line in $s)
	{
		# write-host	$line
		if ($line -match "^quit") { break }
		$line = [regex]::Replace($line, "--.*$","")
		$line = [regex]::Replace($line, "#.*$","")
		$fine = $($fine)+$($line)+" "
		$fine = [regex]::Replace($fine,"\s+"," ")
		if (! ($fine -match ".*; $")) { continue }

		
		# write-host $fine
		$res += $fine
		$fine = ""
		
	}
	return $res
}

