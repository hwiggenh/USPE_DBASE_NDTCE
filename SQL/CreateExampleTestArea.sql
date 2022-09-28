--
-- Simple minimalist database definition for UltraSonic Pulse Echo (USPE) data
--
-- database: MySQL
-- users and their rights must be defined in database setup
--
-- August 2022 - H. Wiggenhauser
--
-- 
# use uspedb;

set @Name = "TestArea #1 Example";
set @Description = "TestArea Definiton Example #1";
set @SizeX = 1000;
set @SizeY = 800;
-- set @Transformation = '{"X":200,"Y": 120,"Angle":0}';
set @Notes = (select concat( "created: ", CURRENT_TIMESTAMP()," by: ", current_user));

insert into TestArea values (NULL,@Name,@Description,@SizeX,@SizeY,@Notes);

set @Name = "TestArea #2 Example";
set @Description = "TestArea Definiton Example #2";
set @SizeX = 1000;
set @SizeY = 5000;
-- set @Transformation = '{"X":0,"Y": 0,"Angle":0}';
set @Notes = (select concat( "created: ", CURRENT_TIMESTAMP()," by: ", current_user));

insert into TestArea values (NULL,@Name,@Description,@SizeX,@SizeY,@Notes);


