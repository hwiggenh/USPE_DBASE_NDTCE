/* =======================================================================
 FILE:		 	CreateExampleUSPEData.sql
 TYPE:			SQL script
 PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
 PREREQUISITS:	mysql installation with database USPE installed, DBDATA directory
 USAGE:			mysql < CreateExampleUSPEData.sql
 				
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
set @COLIND = (select ifnull(SUBSTRING_INDEX(@FN, "_", 1),1));
set @ROWIND = (select ifnull(MID(@FN,locate("_",@FN)+1,locate(".",@FN)-locate("_",@FN)-1  ),1));

-- get transmitter position relative to test point from TestEquipment, default to -30 and 60 for A1220
set @ZOFF =    (select ifnull(json_extract(DeviceInfo,"$.GeomInfo.ZeroOffset"),-30) from TestEquipment where ID=@TEID);
set @PIT  =    (select ifnull(json_extract(DeviceInfo,"$.GeomInfo.Pitch"),60) from TestEquipment where ID=@TEID);

-- get map info from TestSeries
-- map raster orientation relative to TestArea: Xindex || X Yindex || Y, defaults to 100,100
set @XMAP0 =   (select ifnull(json_extract(Setting,"$.MAP.XMAP0"),100) from TestSeries where ID=@TSID);
set @YMAP0 =   (select ifnull(json_extract(Setting,"$.MAP.YMAP0"),100) from TestSeries where ID=@TSID);-- 

-- map increment X,Y TestSeries.Setting.$.MAP.XMAPINC, ...YMAPINC, defaults to in 50,80 
set @XMAPINC = (select ifnull(json_extract(Setting,"$.MAP.XMAPINC"),50) from TestSeries where ID=@TSID);
set @YMAPINC = (select ifnull(json_extract(Setting,"$.MAP.YMAPINC"),80) from TestSeries where ID=@TSID);

-- calculate Transmitter and receiver psoition in TestArea
-- Orientation of Sensor 
-- 		|| X axis T -> R use as shown
-- 		|| X axis R -> T : switch sign of @ZOFF,@PIT
--      || Y axis T -> R : move "+ @ZOFF" from TX to TY and "+ @ZOFF + @PIT" from RX to RY
--		|| Y axis R -> T : ....  and switch sign of @ZOFF,@PIT  
set @TX =       @XMAP0 + (@COLIND - 1) * @XMAPINC + @ZOFF;
set @TY =       @YMAP0 + (@ROWIND - 1) * @YMAPINC;
set @RX =       @XMAP0 + (@COLIND - 1) * @XMAPINC + @ZOFF + @PIT;
set @RY =       @YMAP0 + (@ROWIND - 1) * @YMAPINC;

-- include FileName and FilePath
set @FileInfo = '{"FileType":"A1220"}';    -- no spaces in FileType Variable-query return splits on spaces
set @FileInfo = (select JSON_SET(@FileInfo,'$.FileName',@FN, '$.FilePath',@FP));

-- in A1220 map scan, rowindex is used as sequence
insert into USPEData values (NULL,@TSID,@TS,@TX,@TY,@RX,@RY,@ROWIND,@FileInfo);

