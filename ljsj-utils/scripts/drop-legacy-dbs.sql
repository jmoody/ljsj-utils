-- drops the various k12 databases

-- animal watch and wayang dbs
-- the only ones here that we actually use are adm, dat, sys
drop database if exists adm;
drop database if exists admin;
drop database if exists animaldb;
drop database if exists corrdb;
drop database if exists dat;
drop database if exists data0;
drop database if exists data1;
drop database if exists data2;
drop database if exists data38;
drop database if exists data39;
drop database if exists data40;
drop database if exists data41;
drop database if exists data42;
drop database if exists data43;
drop database if exists data44;
drop database if exists data45;
drop database if exists data46;
drop database if exists sys;

-- awvi databases
drop database if exists awvi_adm;
drop database if exists awvi_dat;
drop database if exists awvi_sys;
