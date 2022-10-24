--
-- Simple minimalist database definition for UltraSonic Pulse Echo (USPE) data
--
-- database: MySQL
-- users and their rights must be defined in database setup
--
-- August 2022 - H. Wiggenhauser
--

create database if not exists uspedb;
use uspedb;
drop table if exists uspedb.USPEData;
drop table if exists uspedb.TestSeries;
drop table if exists uspedb.TestEquipment;
drop table if exists uspedb.TestArea;

-- SET FOREIGN_KEY_CHECKS = 0; 		-- needed when database already exists

-- table TestEquipment gives every Unit an unique number
create table if not exists uspedb.TestEquipment (
	ID				int UNSIGNED	NOT NULL PRIMARY KEY AUTO_INCREMENT, 	-- unique number used as reference
	Name			varchar(50)		NOT NULL DEFAULT 'NoName',				-- free text
	Model			varchar(500)	not null default 'NoModel',				-- free text
	DeviceInfo		json			not null,								-- json 
	Notes			varchar(1000)	not null default ''						-- free text
);

-- table testarea describes a rectangular area on which the measurmenets are taken
create table if not exists uspedb.TestArea (
	ID				int UNSIGNED		NOT NULL PRIMARY KEY AUTO_INCREMENT,	-- unique number, used as reference
	Name			varchar(50)			NOT NULL default 'NoName',				-- free text
	Description		Varchar(256)		not null default 'NoDescription',		-- free text
	SizeX			int					not null default 1000,					-- horizontal size in mm
	SizeY			int					not null default 1500,					-- vertical size in mm
--	Transformation	json				not null,								-- json data describing transformation of the TestArea on a structure
	Notes			varchar(1000)		not null default ''						-- free text
);

-- TestSeries hold collections of AScans on the SAME testArea and SAME TestEquipment Settings
create table if not exists uspedb.TestSeries (
	ID				INT UNSIGNED	NOT NULL PRIMARY KEY AUTO_INCREMENT,		-- unique number, used as reference
	Name			VARCHAR(100)    NOT NULL Default " ",						-- free text
	TestAreaID		INT UNSIGNED	NOT NULL, FOREIGN KEY (TestAreaID) REFERENCES uspedb.TestArea(ID) on delete cascade,	-- reference to TestArea
	TestEquipmentID	INT UNSIGNED	NOT NULL, FOREIGN KEY (TestEquipmentID) REFERENCES uspedb.TestEquipment(ID) on delete cascade, -- reference to TestEquipment
	Setting			json			not null,					-- json data describing the instrument and map settings
	Notes			varchar(1000) 	NOT NULL Default ''			-- free text
);
-- create index on  main columns
alter table TestSeries add index(TestAreaID);			
alter table TestSeries add index(TestEquipmentID);

-- uspedb_Data holds description of individual AScans
create table if not exists uspedb.USPEData (
	ID				INT UNSIGNED		NOT NULL PRIMARY KEY AUTO_INCREMENT,		-- unique number
	TestSeriesID	INT UNSIGNED		NOT NULL, FOREIGN KEY (TestSeriesID) REFERENCES uspedb.TestSeries(ID) on delete cascade, -- reference to TestSeries
	TimeStamp		TIMESTAMP			not null default CURRENT_TIMESTAMP,			-- timestamp for time of test
	TX				int 				not NULL default 0,							-- x-position of transmitter
	TY				int 				not NULL default 0,							-- y-position of transmitter
	RX				int 				not NULL default 0,							-- x-position of receiver
	RY				int 				not NULL default 0,							-- x-position of receiver
	Sequence		INT					NOT NULL DEFAULT 0,							-- number unique to test taken together (eg Mira)
	FileInfo 		json				NOT NULL
);
-- create index on  main columns
alter table USPEData add index(TimeStamp);
alter table USPEData add index(TX);
alter table USPEData add index(TY);
alter table USPEData add index(RX);
alter table USPEData add index(RY);

-- end of file
