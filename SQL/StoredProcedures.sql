/* =======================================================================
 FILE:		 	StoredProcedure.sql
 TYPE:			SQL script
 PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
 PREREQUISITS:	power shell, mysql installation with database USPE installed, DBDATA directory
 USAGE:			execute in MySQL
 				
 DESCRIPTION:	helper script to create procedure to calculate transducer positions on MIRA upload
				
 OUTPUT:		
 
 TODO:			
 
 AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
 COPYRIGHT: 	none -- do whatever you want to do with this script 
 WARRANTY:		none -- absolutely no warranty - use at your own risk  
 REVISION:  	2022-08-23 initial draft 
======================================================================== */

use uspedb;

drop procedure if exists MiraSensor;
DELIMITER //  
CREATE PROCEDURE MiraSensor()   
BEGIN
DECLARE T INT DEFAULT 0; 
DECLARE R INT DEFAULT 0; 
DECLARE TX INT DEFAULT 0; 
DECLARE RX INT DEFAULT 0; 
DECLARE TY INT DEFAULT 0; 
DECLARE RY INT DEFAULT 0; 
DECLARE C INT DEFAULT 0; 
# DECLARE TSID INT DEFAULT 0; 
# DECLARE TS varchar(50) DEFAULT ""; 
SET T = 0;
SET C = 0;
WHILE (T < 11) DO
	set R = T + 1;
	WHILE (R <= 11) DO
		set TX = @ZOFF + @PIT * T + @XMAP0 + (@COLIND - 1) * @XMAPINC;
		set RX = @ZOFF + @PIT * R + @XMAP0 + (@COLIND - 1) * @XMAPINC;
		set TY = @YMAP0 + (@ROWIND - 1) * @YMAPINC;		-- MIRA || X
		set RY = @YMAP0 + (@ROWIND - 1) * @YMAPINC;

		
		set @FileInfo = (select JSON_SET(@FileInfo,'$.DataRange', C));
		
		-- select @TestSeriesID,@TS,TX,TY,RX,RY,@SEQ,@FileInfo;
		
		insert into USPEData values (NULL,@TSID,@TS,TX,TY,RX,RY,@SEQ,@FileInfo);
		
		set R = R + 1;
		set C = C + 2048;
	END WHILE;
    SET T = T + 1;
END WHILE;
END;
//  

 
