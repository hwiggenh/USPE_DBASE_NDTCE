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
# set env variables for USPE_DB

# DATADIR is root for raw files directory tree
export DATADIR="$HOME/code/USPE_DBASE_NDTCE/DATA"

# sql connect string
SQLUSER="USPEuser"			# user for USPE
SQLPW="NDT-CEDB"			# password
SQLPORT=3306				# port 				default 3306
SQLHOST="Brix-Herb"			# mysql host		default localhost
SQLDB="USPE"				# database name		default none
SQLPROMPT="USPE\>\ "			# db prompt			

alias my_sql="mysql -u ${SQLUSER} -p$SQLPW -h ${SQLHOST} --port $SQLPORT --prompt $SQLPROMPT $SQLDB"

