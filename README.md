# USPE_DBASE_NDTCE
Minimalist Database for UltraSound Pulse Echo Data collected with ACS equipment

<b><i>Non Destructive Testing in Civil Engineering UltraSound Pulse Echo DataBase</i></b>

<h3>Introduction</h3> 
NDT-CE USPE DB is a basic database scheme for organizing ultrasonic (US) data in a MySQL database. This Data Management tool enables the user to establish reliable relations between a test, its location in a test area, the test device, and its setting while having the power of a SQL DB to retrieve, search, select, and organize data collected in projects. 
Only the bare minimum of tables are used. This scheme can easily be expanded to include metadata such as structural plans, inspection reports, images, operator information, and structure information about the test object in the data management system.

A total of four tables connect TestEquipment, TestArea, TestSeries, and TestData. Each table is briefly described below:
<ul>
	<li><b>TestData</b> describes a single AScan with positions (X/Y) for US-Transmitter and -Receiver on the TestArea and a reference to where to find the corresponding raw data file. TestData is stored in table USPEData.

<li><b>TestSeries</b> is a collection of TestData entries with the same TestEquipment, the same settings in the device, and the same TestArea. For example, a single test with the MIRA-A1040 produces 66 Ascans, and therefore 66 entries in TestData. The user can freely decide which individual test should be included in a selected TestSeries.  

<li><b>TestArea</b> is a rectangular area where the tests are collected. The coordinate system for each TestArea is cartesian with Z pointing into the test object (on a vertical TestArea: X horizontal and Y vertical). 

<li><b>TestEquipment</b> holds a description of the test device. The DeviceInfo column in this table holds the geometric information of the device as well as data format and device settings. The user can freely decide to have individual entries in this table with selected settings or provide individual settings for each TestSeries.
</ul>

Raw data files - as created by the device - may be organized in a directory structure which supports reference to the organization in the DB. However, any other structure is possible with minor code changes.
<pre>
<DATA> e.g. USPEDATA 					root dir for raw data files
 |
 |_________________________    ...    ______________
 |                |                                 |
TA001            TA002 				 TAnnn 			TestArea
 |_____            |___________                     |_______ ... _
 |     |           |     |     |                    |      |      |
TS<n> TS<n>       TS<n> TS<n> TS<n>                TS<n>  TS<n>  TS<n>	TestSeries

</pre>
<h3>Installation of MySQL</h3>
installation of MySQL and user
Table definition and information in CreateExampleDB.sql

<h4>Scripts</h4>
Tools are included to upload the data collected with 
<a href="acs-international.com/product/a1220-monolith-classic"ACS A1020</a> 
and 
<a href="acs-international.com/product/a1040-mira/">ACS A10040MIRA</a>
Ultrasonic Equipment.
Upon uploading the data, the position of each transducer and receiver in the TestArea is calculated from the Map data (user supplied and/or as defined in datafiles).

Basic scripts are provided to 
<ul>
<li>Retrieve and visualize an individual AScan from the DB
<li>Visualize TestArea and position of a selected AScan, TestSeries, or all tests on a TestArea  
</ul>
SQL and Shell scripts are provided for demonstration and simplicity (just bash/Powershell). For production, please develop more appropriate tools to retrieve data (the shell scripts to read and convert binary data are exceedingly slow). 

Raw data files created by the test device are only referenced in the database. Renaming/moving data files will destroy the reference in the DB.

<h4>Test Requirements</h4>
It is necessary to define a coordinate system for the test device to enable a correct transformation of each AScan into the TestArea.

TestEquipment orientation for MIRA is parallel to X. The equipment axis goes from left to right when holding the device. TestPoint is the center of the housing.

For A1020, the sensor (e.g., M2502) has 12 transmitting DPC transducers next to the connector cables. The instrument axis goes from the connectors along the long side of the sensor housing. TestPoint is the center of the sensor housing.  

Data should be collected in the Map mode, and raw data files named using the format below:
<pre>
&lt;col&gt;[_-]&lt;row&gt;.&lt;ext&gt;

eg 	A1220: 			12_3.raw
	A1040_MIRA:		3-4.lbv
</pre>
Filenames which do not satisfy this template will be assigned 1/1 for col/row as default.

The test Map - a rectangular evenly spaced grid - must be oriented parallel to the TestArea axes (<col> || X and <row> || Y) 

The TestArea should be large enough to contain all tests (test positions outside the TestArea will be correctly be entered in the DB but not be included in the TestArea plot).

The First Map position (1/1) has coordinates (X0/Y0) in the TestArea and must be provided upon upload of data into DB.
<pre>

  	 <--- X0 -->
	 _______________________________________________________
   ^ 0 TestArea  --> X                                       |
  Y0 |                                                       |
   v |		(1/1)		(2/1)		(3/1)                   |
	|		(1/2)		(2/2)		(3/2)                   |
	||                                                      |
	|v                                                      |
	|Y                                                      |
	|_______________________________________________________|

</pre>

<h4>System Requirements</h4>
<ul>
<li>DataBase:	MySQL and user to create DataBase scheme with insert/query permission
<li>SVG Viewer: 	installed default viewer for svg
<li>Disk Space: 	for DB see MySQL instructions
		<br>scripts need only minimal space (< 1MB)
		<br>enough space for data you put into the database
		<br>temporary directory to store svg plots
<li>Linux:		bash
<li>Windows:	PowerShell
</ul>
<h4>Sequence of steps preparing a test and storing it in database</h4>
<ol>
<li>Before the test 
<ol>
<li>Check the entry for your test device in the table TestEquipment. Create or update the entry if necessary.
<li>Define your TestArea in the Table TestArea.
</ol>
<li>On the test site 
<ol><li>Mark your TestArea and define the origin and directions for (X/Y). 
<li>Define Map position (1/1) and take its coordinates in the TestArea as (X0/Y0).
<li>Define Map grid steps: in the case of A1040_MIRA, define Map steps in the device. 
<li>For A1220, note the grid steps (dX/dY).
</ol>
<li>Taking tests 
<ol><li>Take the test(s) in Map mode. 
</ol>
<li>Upload tests to DB 
<ol><li>Define TestSeries in DB using script CreateTestSeries.sql 
using X0/Y0 as XMAP0/YMAP0 and - for A1220 - dX/dY as XMAPINC/YMAPINC
<li>Create directories TA<nnn> and TS<nnn> below <DATA> 
<li>Copy raw data files in map format to <DATA>/TA<nnn>/TS<nnn>
run UploadMIRA.sh/UploadA1220.sh with parametersMAPINC TAID TSID to create entries in USPEData table.
</ol>
</ol>
<b>DONE.</b>

<h3>Queries:</h3>
File SQL/Queries.sql contains 10 example queries for the database.

