-- drops the various k12 databases

-- animal watch and wayang dbs
-- the only ones here that we actually use are adm, dat, sys
drop database if exists adm;
create database adm;
drop database if exists dat;
create database dat;
drop database if exists sys;
create database sys;
create user 'woj-server'@'localhost' identified by 'MeSWAjE4U5aq4jec';
create user 'woj-server'@'adama.cs.arizona.edu' identified by 'MeSWAjE4U5aq4jec';
grant all on dat.* to 'woj-server'@'localhost';
grant all on dat.* to 'woj-server'@'adama.cs.arizona.edu';
grant all on sys.* to 'woj-server'@'localhost';
grant all on sys.* to 'woj-server'@'adama.cs.arizona.edu';
grant all on adm.* to 'woj-server'@'localhost';
grant all on adm.* to 'woj-server'@'adama.cs.arizona.edu';

-- provenance database
CREATE DATABASE if not exists provenance;
CREATE TABLE if not exists provenance.db_duplication_log (
  date DATETIME NOT NULL COMMENT 'the time when this row was added (i.e. when this duplication event happened)',
  source_ip VARCHAR(32) NOT NULL COMMENT 'the ip of the source server',
  target_ip VARCHAR(32) NOT NULL COMMENT 'the ip of the target server',
  mysql_dump_options VARCHAR(256) NOT NULL COMMENT 'the directives passed to mysqldump',
  duplicated_databases VARCHAR(256) NOT NULL COMMENT 'the tables that were duplicated',
  target_user VARCHAR(32) NOT NULL COMMENT 'the user on the target machine was granted privileges'
)
CHARACTER SET utf8
COMMENT = 'entries are created by wayang/server/<version>/scripts/duplicate-db.sh';

flush privileges;