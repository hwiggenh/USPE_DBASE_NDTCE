--
-- Simple minimalist database definition for UltraSonic Pulse Echo (USPE) data
--
-- database: MySQL
-- users and their rights must be defined in database setup
--
-- August 2022 - H. Wiggenhauser
--
-- 
use USPE;

# A1220 TestSeries
set @Name = "Example A1220 Point Test";
set @TestAreaID = 1;
set @TestEquipmentID = 1;
set @Setting = (select DeviceInfo from TestEquipment where ID = 1);
-- add test series specfic information about test map
set @XMAP0 = 100;
set @YMAP0 = 140;
set @XMAPINC = 200;
set @YMAPINC = 120;
set @JMAP = (select JSON_OBJECT('XMAP0',@XMAP0,'YMAP0',@YMAP0,'XMAPINC',@XMAPINC,'YMAPINC',@YMAPINC));

set @Setting = (select JSON_SET(@Setting, '$.MAP',JSON_OBJECT('XMAP0',@XMAP0,'YMAP0',@YMAP0,'XMAPINC',@XMAPINC,'YMAPINC',@YMAPINC)));
set @Notes = (select concat( "created: ", CURRENT_TIMESTAMP()," by: ", current_user));

insert into TestSeries values (NULL,@Name,@TestAreaID,@TestEquipmentID,@Setting,@Notes);

# MIRA A1040 TestSeries
# Assuming MIRA Settings do not change during scan
# MIRA Device Settings will be added to Setting column on Data Upload
set @TEID = 2;
set @Name = "Example MIRA Test";
set @TestAreaID = 2;
set @TestEquipmentID = @TEID;
set @XMAP0 = 200;
set @YMAP0 = 80;
set @Setting = (select DeviceInfo from TestEquipment where ID = @TEID);
set @Setting = (select JSON_SET(@Setting, '$.MAP',JSON_OBJECT('XMAP0',@XMAP0,'YMAP0',@YMAP0)));
set @Notes = (select concat( "created: ", CURRENT_TIMESTAMP()," by: ", current_user));

insert into TestSeries values (NULL,@Name,@TestAreaID,@TestEquipmentID,@Setting,@Notes);

