/* =======================================================================
 FILE:		 	CreateExampleMIRAData.sql
 TYPE:			SQL script
 PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
 PREREQUISITS:	mysql installation with database USPE installed, DBDATA directory, MiraSensor() stored procedure
 USAGE:			mysql < CreateExampleMIRAData.sql
 				
 DESCRIPTION:	creates and fills variables for geometric transformation
 				from device coordinates to TestArea 
				creates SQL query

 OUTPUT:		creates enntry in USPEData
 
 TODO:			
 
 AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
 COPYRIGHT: 	none -- do whatever you want to do with this script 
 WARRANTY:		none -- absolutely no warranty - use at your own risk  
 REVISION:  	2022-08-23 initial draft 
======================================================================== */
use USPE;
-- Filename must have format <Rowindex>_<ColumnIndex>.raw
-- map is defined in TestSeries
-- TestSeriesID, TestAreaID, Filename, Filepath,TimeStamp (modtime of file) are passed from calling program

-- get map file indices, defaults to 1,1
set @COLIND = (select ifnull(SUBSTRING_INDEX(@FN, "-", 1),1));
set @ROWIND = (select ifnull(MID(@FN,locate("-",@FN)+1,locate(".",@FN)-locate("-",@FN)-1  ),1));

-- get transmitter position relative to test point from TestEquipment, default to -30 and 60 for A1220
set @ZOFF =    (select ifnull(json_extract(DeviceInfo,"$.GeomInfo.ZeroOffset"),-30) from TestEquipment where ID=@TEID);
set @PIT  =    (select ifnull(json_extract(DeviceInfo,"$.GeomInfo.Pitch"),60) from TestEquipment where ID=@TEID);

-- get map info from TestSeries
-- map raster orientation relative to TestArea: Xindex || X Yindex || Y, defaults to 100,100
set @XMAP0 =   (select ifnull(json_extract(Setting,"$.MAP.XMAP0"),100) from TestSeries where ID=@TSID);
set @YMAP0 =   (select ifnull(json_extract(Setting,"$.MAP.YMAP0"),100) from TestSeries where ID=@TSID);
-- set @XMAP0 =   (ifnull(@XMAP0,100));	-- values could still be null when record does not exist
-- set @YMAP0 =   (ifnull(@YMAP0,120));

-- map increment X,Y TestSeries.Setting.$.MAP.XMAPINC, ...YMAPINC, defaults to in 50,80 
set @XMAPINC = (select ifnull(json_extract(Setting,"$.MAP.XMAPINC"),50) from TestSeries where ID=@TSID);
set @YMAPINC = (select ifnull(json_extract(Setting,"$.MAP.YMAPINC"),80) from TestSeries where ID=@TSID);
-- set @XMAPINC =   (ifnull(@XMAPINC,50));
-- set @YMAPINC =   (ifnull(@YMAPINC,80));

-- include FileName and FilePath
set @FileInfo = '{"FileType":"A1040_MIRA"}';    -- no spaces in FileType Variable-query return splits on spaces
set @FileInfo = (select JSON_SET(@FileInfo,"$.FileName",@FN, "$.FilePath",@FP));

call MiraSensor();

 
