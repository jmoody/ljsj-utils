-- creates the modx db and user
-- if it exists already, delete it
drop database if exists modx;
create database modx;
create user 'modx'@'localhost' identified by 'somepassword';
create user 'modx'@'your.server.name' identified by 'somepassword';
grant all on modx.* to 'modx'@'localhost';
grant all on modx.* to 'modx'@'your.server.name';
flush privileges;