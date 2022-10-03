# =======================================================================
# FILE:		 	USPE_ENV.sh 
# TYPE:			bash script non-executable
# PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
# PREREQUISITS:	bash
# USAGE:		source USPE_ENV.sh 
#
# DESCRIPTION:	shell script defining DATDIR path and mysql connect parameters
#				
# OUTPUT:		none
# 
# TODO:			
# 
# AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
# COPYRIGHT: 	none -- do whatever you want to do with this script 
# WARRANTY:		none -- absolutely no warranty - use at your own risk  
# REVISION:  	2022-08-23 initial draft 
# ========================================================================

# DATADIR is root for raw files directory tree
export DATADIR=$(dirname $(pwd))/DATA

# MySQL connect 
# substitute your definitions for the 6 variables
SQLUSER="uspeuser"			# user for USPE		use your username
SQLPW="NDT-CEDB"			# password			use your password for DB 
SQLDB="uspedb"				# DB name			use your DBname
SQLPORT=3306				# port 				typ. 3306 
SQLHOST="db4free.net"		# mysql host		for local installation use "localhost"
SQLPROMPT="uspe\>\ "		# db prompt			sets the prompt when access DB interactively	


shopt -s expand_aliases		# allows to set alias from bash script
							# create an alias for mysql access
							# alternatively, you may use ~/.my.cnf  
alias my_sql="mysql -u ${SQLUSER} -p$SQLPW -h ${SQLHOST} --port $SQLPORT --prompt $SQLPROMPT $SQLDB"
 
# 
# [client8]
# use --defaults-group-suffix=8 
# user=uspeuser
# password="NDT-CEDB"
# prompt=uspe-mysql>
# host="db4free.net"
# database=uspedb
# 

