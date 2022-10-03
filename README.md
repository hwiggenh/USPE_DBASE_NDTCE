# USPE_DBASE_NDTCE
<H2>Demonstration Database for UltraSound Pulse Echo Data</H2>

<b><i>UltraSound Pulse Echo DataBase -Non-Destructive Testing in Civil Engineering </i></b>

<h3>Introduction</h3> 
This repository demonstrates how to utilize a database to organize ultrasound test data collected on a structure. It is not intended for production and follows simple rules:
<ul>
<li>Keep it simple 
<li>Keep original data
<li>Requires minimal user interaction
</ul>
while creating unambiquous relations among the following:
<ul>
<li>Test data collections
<ul><li>Single test point
<li>Line scan
<li>Area scan
<li>Any combination of the above
</ul>
<li>Test location
Cheers,
Herbert

<ul>
<li>Position of each transducer within a rectangular area on a structure
</ul>
<li>Test equipment
<ul>
<li>Position of individual transducers within the device coordinates (transducers which work in sync are treated as one)
<li>Default device settings
<li>Raw data file format
<li>Raw file naming convention in map scan mode
</ul>
</ul>

This repository implements the handling of data collected with ACS equipment <a href="https://acs-international.com/product/a1220-monolith-classic/" target="_blank">A1220 Monolith</a> and <a href="https://acs-international.com/product/a1040-mira/" target="_blank">A1040 MIRA</a>

The database scheme is created using MySQL as a database system, providing the power of a SQL DB to retrieve, search, select, and organize huge amounts of data. 
Only the bare minimum of tables are used. This scheme can easily be expanded  into a data management system to include metadata such as structural plans, inspection reports, images, operator's information, and structure information about the test object.

<h4>DataBase Tables</h4>
A total of four tables connect <i>TestEquipment</i>, <i>TestArea</i>, <i>TestSeries</i>, and TestData (<i>USPEData</i>). Each table is briefly described below:
<ul>
<li><b><i>USPEData</i></b> holds the TestData and describes each single combination of transmitter and receiver (AScan) with positions (X/Y) for US-Transmitter and -Receiver on the <i>TestArea</i>. It describes where to find the corresponding raw data file and the offset to locate the corresponding AScan data within the raw data file.

<li><b><i>TestSeries</i></b> is a collection of <i>USPEData</i> entries with the same <I>TestEquipment</i>, the same settings in the device, and the same <i>TestArea</i>. For example, a single test with the A1040-MIRA produces 66 AScans, and, therefore, 66 entries in <i>USPEData</i>. The user can freely decide which individual test should be included in a specific <i>TestSeries</i>.  

<li><b><i>TestArea</i></b> is a rectangular area where the tests are collected. The coordinate system for each <i>TestArea</i> is cartesian with Z pointing into the test object (on a vertical <i>TestArea</i>: X horizontal and Y vertical). 

<li><b><i>TestEquipment</i></b> holds a description of the test device. The DeviceInfo column in this table holds the geometric information of the device as well as data format and device settings. The user can freely decide to have individual entries of the same device in this table with selected settings or provide individual settings for each <i>TestSeries</i>.
</ul>

<h4>Raw data files</h4> 
Raw data files as created by the device - may be organized in a directory structure which supports unumbiquous reference to the organization in the DataBase. However, any other structure is possible with minor code changes.
<P>CAUTION: In this DB scheme, raw data files are only referenced in the database. Renaming/moving data files will destroy the reference in the DB.
<pre>
<DATA> e.g. ~/USPEDATA 					root dir for raw data files
 |
 |_________________________    ...    ______________
 |                |                                 |
TA001            TA002 				 TAnnn 			TestArea
 |_____            |___________                     |_______ ... _
 |     |           |     |     |                    |      |      |
TS&lt;n&gt;  TS&lt;n&gt;       TS&lt;n&gt; TS&lt;n&gt; TS&lt;n&gt;                TS&lt;n&gt;  TS&lt;n&gt;  TS&lt&gt;	     TestSeries

</pre>
<h3>Installation</h3>
<h4>System Requirements</h4>
<ul>
<li>Linux:		bash
<li>Windows:	PowerShell
<li>DataBase:	MySQL and user to create DataBase scheme with insert/query permission
<li>Disk Space: 	for DB see MySQL instructions
		<br>Scripts need only minimal space (< 1MB)
		<br>Enough space for data you put into the database
		<br>Temporary directory space to store svg plots
<li>SVG Viewer: 	default viewer for svg should be installed
</ul>

<h4>MySQL installation</h4>
Linux bash: 
	mysql-client installation
Linux Powershell:
	wget https://dev.mysql.com/get/Downloads/Connector-Net/mysql-connector-net-8.0.19-noinstall.zip
Windows: Install-Module wget https://dev.mysql.com/get/Downloads/Connector-Net/mysql-connector-net-8.0.19-noinstall.zip

Three options for utilizing MySQL:
<ul>
<li>Local MySQL Installation: <br>MySQL (owned by Oracle) can be downloaded for free from <a href="https://www.mysql.com/downloads/" target="_blank">MySQL Download</a>.<br>Please follow the instructions on how to install the system on your computer

<li>Utilize existing MySQL Installation
<br>Any exisiting MySQL installation can be utilized for this project. You need to be able to create or utilize a user with appropriate rights 
<br>MySQL client should be installed on your loacal computer
<li>Utilize Cloud MySQL service<BR> <a href="https://db4free.nett/index.php?language=en"  target="_blank">db4free</a> provides a free testing service for MySQL which can be used for this project without the necessity to install MySQL. <br><b>This service is not for production</b><br>To use this service you must sign up and create a DB, and just follow the instructions. The DB will be setup within a few minutes.
<br>A DB named &lt;uspedb&gt; and a user &lt;dbname&gt; are being defined while creating the DB within db4free
<br>MySQL client should be installed on your loacal computer
</ul>
<P><b>Configure MySQL</b>
<br>Access configuration is documented in the file <i>USPE_ENV.sh</i>. Please follow the SQLConnect instructions in this file.

<P><b>Create user and DB</b> 
<P>When using db4free, user and db are created upon signup
<P><b>Create user (requires privileges; see MySQL user guide for more detailed information)</b>
<br>-- CREATE USER '&lt;username&gt;'@'%' IDENTIFIED BY '&lt;password&gt;';
<br>-- GRANT ALL PRIVILEGES ON &lt;dbname&gt; .* TO '&lt;username&gt;'@'%';
<br>-- GRANT SYSTEM_USER ON *.* TO '&lt;username&gt;'@'%';
<br>-- FLUSH PRIVILEGES;
<br>-- SHOW GRANTS FOR '&lt;username&gt;'@'%';
<br><b>create DB</b>
<br>-- Create database if not exists &lt;dbname&gt; ;

<h4>Script Installation</h4>
<h5>Script Installation Linux</h5>

wget -O -  https://github.com/hwiggenh/USPE_DBASE_NDTCE/archive/main.tar.gz | tar xz
<h5>Script Installation M$ Windows</h5>
Install-Module -Name SimplySql

<h3>Coordinate System</h3>
It is necessary to define a coordinate system for the test device to enable a correct transformation of each transducer positions of an AScan into the <i>TestArea</i>. The transformation from the device onto the <i>TestArea</i> is executed upon upload.

<p><b>A1040 MIRA</b> device axis is along the long side, from left to right when holding the device (see drawing). In this DB, the orientation of MIRA during tests is parallel to <i>TestArea</i> X. TestPoint is the center of the housing. Each row of four transducers acts as one single transducer; the entry in the <i>TestEquipment</i> definition is, therefore, <i>NofSensors</i>: 12.
<p>
<img src="https://docs.google.com/drawings/d/e/2PACX-1vQaTY7xehk8bXiGgETagsLGZRfhcbXeeSat0FzIHGas2rRZKgFSwlOxHJcFEvy7W5IjG_iM3iZ_4OTO/pub?w=700&amp;h=210">

<p>

For <b>A1020 Monolith</b>, the sensor (e.g., M2502) has 12 transmitting DPC transducers next to the connector cables. These 12 sensors act in sync and are treated as one single transducer with a virtual position at their center. The instrument axis goes from the connectors along the long side of the sensor housing. TestPoint is the center of the sensor housing.  

<p>
<img src="https://docs.google.com/drawings/d/e/2PACX-1vTgi8eDAO-RlyVYm_mYJgnPr14NCclHGmM5KgQBPemFyp_K47N_jiXfiVgmyLlZiFL4gdoTLn1dzYbZ/pub?w=529&amp;h=292">
<p>

Data should be collected in the Map mode, and raw data files named using the format below.
The test Map - a rectangular evenly spaced grid - must be oriented parallel to the <i>TestArea</i> axes (&lt;col&gt; || X and &lt;row&gt; || Y) 
<pre>
&lt;col&gt;[_-]&lt;row&gt;.&lt;ext&gt;

eg 	A1220: 			12_3.raw
	A1040_MIRA:		3-4.lbv
</pre>
Filenames which do not satisfy this template will be assigned 1/1 for col/row as default.


<p>Upon uploading the data, the position of each transducer and receiver in the <i>TestArea</i> is calculated from the Map data (X0,Y= must be supplied by the user, xinc/yinc is defined in the A1040-MIRA Header but must be user supplied for A1220-Monolith).
<p>
<img src="https://docs.google.com/drawings/d/e/2PACX-1vSvtgk2s8zqrlbdI1Eq1ShiIrzWiO8C68xmmtMxmh4VwoHV0qpficQOWygma535_fSiBbqExPbHLgQL/pub?w=455&amp;h=291" alt="TestArea with grid positions">


<h3>Working with the DataBase</h3>

<h4>Scripts</h4>
Scripts are provided for demonstration of basic DB operations, using shell and SQL scripts only. For production, please develop appropriate functions using your favorite tools (Matlab, LabView, Python, ...)
<P>All script should be run from the &lt;InstallPath&gt;/SHELL (Linux) or &lt;InstallPath&gt;/PSHELL

<br><B>InitialSetupDBandExamples.sh:</b>	Table definition and information in CreateExampleDB.sql;  Running this script, the tables are created, example data loaded, and SVG plots created.
<br><b>welcome.sh:</b> menue for actions 
<ul>
<li>Create <i>TestSeries</i>  calls <b>CreateNewTestSeries.sh</b>
<li>Create <i>TestArea</i> calls <b>CreateNewTestArea.sh</b> 
<li>Create <i>TestEquipment</i> calls <b>CreateNewTestEquipment.sh</b> 
<li>Upload <a href="acs-international.com/product/a1220-monolith-classic">ACS A1020 Monolith</a> tests: calls <b>UploadA1220.sh</b>  
	<br>requires test map info and raw data files  
	<br>Upon uploading the data, the position of each transducer and receiver in the <i>TestArea</i> is calculated from the Map data (user supplied and/or as defined in datafiles).
<li>Upload <a href="acs-international.com/product/a1040-mira/">ACS A1040 MIRA</a> tests:  call <b>UploadMIRA.sh</b>
	<br>requires test map info and raw data files
	<br>Upon uploading the data, the position of each transducer and receiver in the <i>TestArea</i> is calculated from the Map data (user supplied and/or as defined in datafiles).

<li>Display AScan:  call <b>ReadAScan.sh</b>
	<br>Retrieves and visualizes an individual AScan from the DB
	<br>Creates SVG plot of AScan, identified by ID in <i>USPEData</i>
<li>Display <i>TestArea</i>:  call <b>GetAndShowTestPosition.sh</b>
	<br>Creates SVG plot with all test positions in <i>TestArea</i> identified by <i>TestArea.ID</i>
<li>Display <i>TestSeries</i>:  call <b>GetAndShowTestPosition.sh</b>
	<br>Creates SVG plot of <i>TestArea</i> with test positions identified by <i>USPEData.TestSeriesID</i> 
<li>Display USData on <i>TestArea</i>: calls <b>GetAndShowTestPosition.sh</b>
	<br>Creates SVG plot of <i>TestArea</i> with call test positions of AScan identified by <i>USPEData.ID</i>
</ul>
<b>svgvec.sh:</b> creates SVG plots, stores file in Temp directory with temp name and displays SVG plot (SVG files in temp directory are not automatically deleted)

<p>Raw data files created by the test device should be moved to the directory >(see above) and are only referenced in the database. <b>Renaming/moving data files will destroy the reference in the DB</b>.

<h4>Test Requirements</h4>

The <i>TestArea</i> should be large enough to contain all tests (test positions outside the <i>TestArea</i> will be correctly entered in the DB but not be included in the <i>TestArea</i> plot).

<p>The first Map position (1/1) has coordinates (X0/Y0) in the <i>TestArea</i> and must be provided upon upload of data into DB.

<h4>Sequence of steps preparing a test and storing it in database</h4>
<ol>
<li>Before the test 
<ul>
<li>Check the entry for your test device in the table <i>TestEquipment</i>. Create or update the entry if necessary.
<li>Define your <i>TestArea</i> in the Table <i>TestArea</i>.
</ul>
<li>On the test site 
<ul><li>Mark your <i>TestArea</i> and define the origin and directions for (X/Y). 
<li>Define Map position (1/1) and take its coordinates in the <i>TestArea</i> as (X0/Y0).
<li>Define Map grid steps: in the case of A1040_MIRA, define Map steps in the device (settings will be read upon upload) 
<li>For A1220, note the grid steps (xinc/yinc) and all device settings (settings must be manually entered in <i>TestSeries</i>)
</ul>
<li>Taking tests 
<ul><li>Take the test(s) in Map mode. 
</ul>
<li>Upload tests to DB 
<ul><li>Define <i>TestSeries</i> in DB using script CreateTestSeries.sql 
using X0/Y0 as XMAP0/YMAP0 and - for A1220 - xinc/yinc as XMAPINC/YMAPINC
<li>Create directories TA&lt;nnn&gt; and TS&lt;nnn&gt; below &lt;USPEDATA&gt; 
<li>Copy raw data files in map format to &lt;USPEDATA&gt;/TA&lt;nnn&gt;/TS&lt;nnn&gt;
run UploadMIRA.sh/UploadA1220.sh with parameters TAID TSID to create entries in <i>USPEData</i> table.
</ul>
</ol>
<b>DONE</b>

<h3>Queries:</h3>
File SQL/Queries.sql contains 10 example queries for the database.

