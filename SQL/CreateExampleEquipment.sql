--
-- CreateExampleTestEquipment.sql
-- sql routine inserts example data into the table USPE.TestEquipment, describing Ultrasonic Test Equipment 

-- Requirements:
-- 

-- Usage:


-- DeviceInfo is seperated into 3 jsons
-- BinData: 	describes the binary data
-- GeomInfo: 	geometrical info about the sensor
-- Setings: 	instrument settings during test


use USPE;

delete from TestEquipment where ID >= 0;
-- ACS A1220 ==================================================================
-- bindata describes the binary data of A1220 raw files
set @BD ='"BinData":{									
		"DataType": "int",
		"Width": 16,
		"Order": "BEF"
	}'	;
-- DevInfo describes gemetrical info about the M2502 Sensor
-- instrument Zero Point "00" is the center of the sensor housing
-- instrument X axis from transmitter to receiver
-- receiver position R0 is center of 3x4 matrix of receiver matrix  
-- transmitter position T0 is center of 3x4 matrix of transmitter matrix
-- ==============================
-- ||Tx Tx Tx Tx   Rx Rx Rx Rx ||
-- ||                          ||
-- ||Tx Tx Tx Tx   Rx Rx Rx Rx ||-- cable connector
-- ||    T0 ->  00     R0      ||
-- ||Tx Tx Tx Tx   Rx Rx Rx Rx ||-- cable connector
-- ||                          ||
-- ||Tx Tx Tx Tx   Rx Rx Rx Rx ||
-- ==============================
set @DC = '"GeomInfo":{
		"ZeroOffset": -30,
		"Pitch": 60,
		"NofSensors": 2
	}';
	
-- Settings holds devive settings during this test series, values are just examples
set @SE = '"Setting":{
		"SensorType":"M2502",
		"SampRate": 10000000,
		"Frequency":50000,
		"DevDelay":"5.0E-6",
		"Periods":1,
		"PulseRate":45,
		"PulseVolt":200,
		"DevGain":80,
		"Averages":1,
		"DevVelocity":2600
	}';


set @Notes = "ACS A1220 Example; Manual Location: Shelf A; Last calibation: 2021";

set @DF = replace(replace(concat("{",@BD,",",@DC,",",@SE,"}"),"\n",""),"\t","");
insert into TestEquipment values (NULL,"A1220","ACS A1220 Serial#XXXXX Inv#XXXX Purchased: 2022 Owner:Smith",@DF,@Notes);

 -- MIRA A1040 ==================================================================
set @BD ='"BinData":{									
		"DataType": "int",
		"Width": 16,
		"Order": "BEF",
		"ByteOffsetFile": 128
		}'	;
-- instrument Zero Point "00" is the center of the sensor housing between sensor row 2 and 3 and sensor column 6 and 7
-- instrument X axis from transmitter 1 to receiver 12
-- for any Ascan, the position of the receiver and transmitter is calculated from the sequence within a test sweep   
--
-- ==12==11==10==09==08==07==06==05==04==03==02==01===
-- ||RR  TR  TR  TR  TR  TR  TR  TR  TR  TR  TR  TT ||
-- ||                                               ||  
-- ||RR  TR  TR  TR  TR  TR  TR  TR  TR  TR  TR  TT ||
-- || <--------------      00  <---------------     ||
-- ||RR  TR  TR  TR  TR  TR  TR  TR  TR  TR  TR  TT ||
-- ||                                               ||  
-- ||RR  TR  TR  TR  TR  TR  TR  TR  TR  TR  TR  TT ||
-- ===================================================

set @DC = '"GeomInfo":{
		"Pitch": -30,
		"ZeroOffset": 165,
		"NofSensors": 12,
		"ArrayMode": "half-right"
		}';

-- Mira settings are updated upon Testseries Upload
set @SE =  '"Setting":{
		"SampRate": 1000000,
		"Frequency":50000,
		"DevDelay":20,
		"Periods":1,
		"DevGain":12,
		"DevVelocity":2600
	}';

			
set @Notes = "ACS A1040 Example; Manual Location: Shelf B; Last calibation: 2020";

set @DF = replace(replace(concat("{",@BD,",",@DC,",",@SE,"}"),"\n",""),"\t","");

insert into TestEquipment values (NULL,"MIRA","ACS Model A1040 Serial#XXXXX Inv#XXXX Purchased: 2022 Owner:John Doe",@DF,@Notes);


-- "MIRA3D_LINEAR"   ================================================================== 
set @BD ='	"BinData": {
		"Order": "BEF",
		"Width": 16,
		"DataType": "int"
	}';
-- ==01==02==03==04==05==06==07==08===
-- ||TT  TR  TR  TR  TR  TR  TR  RR ||
-- ===================================
-- || ------>      00  ------->     ||
set @DC = '	"GeomInfo": {
		"ZeroOffset": 105,
		"Pitch": 30,
		"ArrayMode": "half-left",
		"NofSensors": 8,
		"MIRA3D_NofUnits": 1,
		"MIRA3D_Mode": "linear"
	}';
set @SE = '	"Setting": {
		"DevGain": 12,
		"Periods": 1,
		"WaveMode": "shear",
		"Frequency": 50000,
		"PulseRate": 45,
		"SensorType": "DPC",
		"DevVelocity": 2720
	}';

set @Notes = "ACS MIRA3D Linear Example; Manual Location: Shelf B; Last calibation: 2020";

set @DF = replace(replace(concat("{",@BD,",",@DC,",",@SE,"}"),"\n",""),"\t","");

insert into TestEquipment values (NULL,"MIRA3D Linear","ACS Model MIRA3D Linear Serial#XXXXX Inv#XXXX Purchased: 2022 Owner:John Doe",@DF,@Notes);


-- "MIRA3D_MATRIX" ============================
set @BD ='	"BinData": {
		"Order": "BEF",
		"Width": 16,
		"DataType": "int"
	}';
-- ==01==02==03==04==05==06==07==08===
-- ||TT  TR  TR  TR  TR  TR  TR  TR ||
-- ||                               ||  
-- ||TR  TR  TR  TR  TR  TR  TR  TR ||
-- || -------->    00  ---------->  ||
-- ||TR  TR  TR  TR  TR  TR  TR  TR ||
-- ||                               ||  
-- ||TR  TR  TR  TR  TR  TR  TR  RR ||
-- ===================================

set @DC = '	"GeomInfo": {
		"ZeroOffset": 105,
		"ColumnPitch": 30,
		"RowPitch": 25,
		"ArrayMode": "half-left",
		"NofSensors": 32,
		"MIRA3D_NofUnits": 1,
		"MIRA3D_Mode": "matrix",
		"MIRA3D_NSensorRows": 4,
		"MIRA3D_NSensorCols": 8
	}';
	
	
set @SE ='	"Setting": {
		"DevGain": 12,
		"Periods": 1,
		"WaveMode": "shear",
		"Frequency": 50000,
		"PulseRate": 45,
		"SensorType": "DPC",
		"DevVelocity": 2720
	}';
set @Notes = "ACS MIRA3D Matrix Example; Manual Location: Shelf B; Last calibation: 2020";

set @DF = replace(replace(concat("{",@BD,",",@DC,",",@SE,"}"),"\n",""),"\t","");

insert into TestEquipment values (NULL,"MIRA3D Matrix","ACS Model MIRA3D Matrix Serial#XXXXX Inv#XXXX Purchased: 2022 Owner:John Doe",@DF,@Notes);

-- "MIRA3DPRO_LINEAR" ============================
set @BD ='	"BinData": {
		"Order": "BEF",
		"Width": 16,
		"DataType": "int"
	}';

-- Zero Point "00" of test is midpoint between center of Master and Slave unit
-- each unit may be tilted against symmetry axis (Master --> Slave)
-- 			Master Unit										Slave Unit
-- ==01==02==03==04==05==06==07==08===            ==01==02==03==04==05==06==07==08===
-- ||TT  TR  TR  TR  TR  TR  TR  TR ||     00     ||TR  TR  TR  TR  TR  TR  TR  RR ||
-- ===================================            ===================================
-- || ------>      M0  ------->     ||            || ------>      S0  ------->     ||
--                  | ---> axis and distance between units ------->|
--    									  
--                                    
set @DC = '	"GeomInfo": {
		"UnitOffset": 225,
		"MasterUnitAngle":0,
		"SlaveUnitAngle":0,
		"Pitch": 30,
		"ArrayMode": "half-right",
		"NofSensors": 16,
		"MIRA3D_NofUnits": 2,
		"MIRA3D_Mode": "linear"
	}';
set @SE = '	"Setting": {
		"DevGain": 12,
		"Periods": 1,
		"WaveMode": "shear",
		"Frequency": 50000,
		"PulseRate": 45,
		"SensorType": "DPC",
		"DevVelocity": 2720
	}';

set @Notes = "ACS MIRA3DPro Linear Example; Manual Location: Shelf B; Last calibation: 2020";

set @DF = replace(replace(concat("{",@BD,",",@DC,",",@SE,"}"),"\n",""),"\t","");

insert into TestEquipment values (NULL,"MIRA3DPro Linear","ACS Model MIRA3DPro Linear Serial#XXXXX Inv#XXXX Purchased: 2022 Owner:John Doe",@DF,@Notes);


-- "MIRA3DPRO_MATRIX" ============================
set @BD ='	"BinData": {
		"Order": "BEF",
		"Width": 16,
		"DataType": "int"
	}';

-- Zero Point "00" of test is midpoint between center of Master and Slave unit
-- each unit may be tilted against symmetry axis (Master --> Slave)
-- 			Master Unit										Slave Unit
-- ==01==02==03==04==05==06==07==08===            ==01==02==03==04==05==06==07==08===
-- ||TT  TR  TR  TR  TR  TR  TR  TR ||            ||TR  TR  TR  TR  TR  TR  TR  TR ||
-- ||TR  TR  TR  TR  TR  TR  TR  TR ||            ||TR  TR  TR  TR  TR  TR  TR  TR ||
-- || ------>      M0  ------->     ||     00     || ------>      S0  ------->     ||
-- ||TR  TR  TR  TR  TR  TR  TR  TR ||            ||TR  TR  TR  TR  TR  TR  TR  TR ||
-- ||TR  TR  TR  TR  TR  TR  TR  TR ||            ||TR  TR  TR  TR  TR  TR  TR  RR ||
-- ===================================            ===================================
--                  | ---> axis and distance between units ------->|
--    									   
--                                    
set @DC = '	"GeomInfo": {
		"UnitOffset": 225,
		"MasterUnitAngle":0,
		"SlaveUnitAngle":0,
		"ColumnPitch": 30,
		"RowPitch": 25,
		"ArrayMode": "half-right",
		"MIRA3D_NofUnits": 2,
		"MIRA3D_Mode": "matrix",
		"MIRA3D_NSensorRows": 4,
		"MIRA3D_NSensorCols": 16
	}';
	
	
set @SE ='	"Setting": {
		"DevGain": 12,
		"Periods": 1,
		"WaveMode": "shear",
		"Frequency": 50000,
		"PulseRate": 45,
		"SensorType": "DPC",
		"DevVelocity": 2720
	}';
set @Notes = "ACS MIRA3DPro Matrix Example; Manual Location: Shelf B; Last calibation: 2020";

set @DF = replace(replace(concat("{",@BD,",",@DC,",",@SE,"}"),"\n",""),"\t","");

insert into TestEquipment values (NULL,"MIRA3DPro Matrix","ACS Model MIRA3DPro Matrix Serial#XXXXX Inv#XXXX Purchased: 2022 Owner:John Doe",@DF,@Notes);

quit
