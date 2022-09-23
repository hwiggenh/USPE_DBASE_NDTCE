/* =======================================================================
 FILE:		 	Queries.sql
 TYPE:			SQL script
 PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
 PREREQUISITS:	mysql installation with database USPE installed
 USAGE:			select query, change it to your eeds and execute query in mysql
 				
 DESCRIPTION:	collection of SQL queries to manipulate USPE_DB

 OUTPUT:		
 
 TODO:			
 
 AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
 COPYRIGHT: 	none -- do whatever you want to do with this script 
 WARRANTY:		none -- absolutely no warranty - use at your own risk  
 REVISION:  	2022-08-23 initial draft 
======================================================================== */
-- Queries to handle USPEDB
use USPE;

-- ========================================================
-- 0 show status of DB
select "TE" T,ID, Name from TestEquipment 
union
select "TA" T,ID, Name from TestArea 
union
select "TS" T,ID, Name from TestSeries 
union
select "US" T,count(ID) ID, "#number of Entries" Name from USPEData
order by T,ID;

-- ========================================================
-- 1 retrieve all USPEData (A-Scans) IDs and Transducer/Receiver Coordinates for TestSeries with ID=3
select ID,TX,TY,RX,RY from USPEData where TestSeriesID=2;

-- ========================================================
-- 2 query filepath for Raw data file for USPEData with ID=4;
select 	concat(JSON_UNQUOTE( json_extract(U.FileInfo,"$.FilePath")),"/"
	,JSON_UNQUOTE( json_extract(U.FileInfo,"$.FileName"))) D from USPEData U where U.ID=4;

-- ========================================================
-- 3 query Transmitter-Receiver distance for USPEData with ID=4;
select sqrt((TX-RX)*(TX-RX)+(TY-RY)*(TY-RY)) from USPEData where ID=12;

-- ========================================================
-- 4 query Transit Time (in ms), transducer positions, distance 
-- for direct USWave - if null: use 2740 m/s -
-- between Transmitter-Receiver 
-- for USPEData with TestSeriesID @TSID or;
set @TSID = 2;
select U.ID UID
,U.TX TX
,U.TY TY
,U.RX RX
,U.RY RY
, sqrt((U.TX-U.RX)*(U.TX-U.RX)+(U.TY-U.RY)*(U.TY-U.RY)) DIST
, ifnull( (select JSON_EXTRACT(Setting,"$.DevVelocity") from TestSeries TS where ID=@TSID),2740)/sqrt((U.TX-U.RX)*(U.TX-U.RX)+(U.TY-U.RY)*(U.TY-U.RY)) TT
from USPEData U
join TestSeries TS on TS.ID = U.TestSeriesID
where TS.ID=@TSID;

-- ========================================================
-- 5 query USPEData entries of one MIRA scan within TestSeries #2 and Seq #1 
set @TSID = 2;
set @SEQ=1;
select U.ID UID
,U.TX TX
,U.TY TY
,U.RX RX
,U.RY RY
,sqrt((U.TX-U.RX)*(U.TX-U.RX)+(U.TY-U.RY)*(U.TY-U.RY)) DIST
from USPEData U
join TestSeries TS on TS.ID = U.TestSeriesID
where TS.ID=@TSID and Sequence=@SEQ
order by TX,TY,RX,RY;

-- ========================================================
-- 6 query midpoint of each MIRA scan in USPEData group by TSID and Sequence
select U.TestSeriesID TSID
,U.Sequence SEQ
,(max(U.TX) + min(RX))/2 MX
,(max(U.TY) + min(RY))/2 MY
from USPEData U
where JSON_EXTRACT(FileInfo,"$.FileType") = "A1040_MIRA"
group by TSID,SEQ;

-- ========================================================
-- 7 query TestSeries on TestAreas, order bei testArea
select ID TSID, TestAreaID TAID from TestSeries order by TAID;

-- ========================================================
-- 8 reset ID auto_increment counter after deleting entries in table
set @MID = (select max(ID)+1 from TestSeries);
ALTER TABLE table_name AUTO_INCREMENT = @MID;

-- ========================================================
-- 9 get max and min values of transducer positions in all TestArea
select UC.TAID TAID
,min( UC.XX) MIX
,min( UC.YY) MIY
,max( UC.XX) MAX
,max( UC.YY) MAY
from
(select TS.TestAreaID TAID, TX XX, TY YY from USPEData U join TestSeries TS on TS.ID = U.TestSeriesID
union
select TS.TestAreaID TAID, RX XX, RY YY from USPEData U join TestSeries TS on TS.ID = U.TestSeriesID) UC
group by TAID

-- ========================================================
-- 10 change specific value in TestSeries.Setting json
set @TSID = 1;
set @OBJECT0 = 'Setting';
set @OBJECT1 = 'DevGain';
set @NEWVALUE = "123";				-- change to reflect your value
update TestEquipment set DeviceInfo=json_set(DeviceInfo,concat("$.",@OBJECT0,".",@OBJECT1),@NEWVALUE) where ID=@TSID;



