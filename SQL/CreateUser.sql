drop database uspedb;
create database if not exists uspedb;
use uspedb;
CREATE USER 'USPEuser'@'%' IDENTIFIED BY 'NDT-CEDB';
GRANT ALL PRIVILEGES ON uspedb .* TO 'USPEuser'@'%';
GRANT SYSTEM_USER ON *.* TO 'USPEuser'@'%';
FLUSH PRIVILEGES;
SHOW GRANTS FOR 'USPEuser'@'%';
