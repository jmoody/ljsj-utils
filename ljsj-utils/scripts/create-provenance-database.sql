CREATE DATABASE provenance;
CREATE TABLE provenance.db_duplication_log (
  date DATETIME NOT NULL COMMENT 'the time when this row was added (i.e. when this duplication event happened)',
  source_ip VARCHAR(32) NOT NULL COMMENT 'the ip of the source server',
  target_ip VARCHAR(32) NOT NULL COMMENT 'the ip of the target server',
  mysql_dump_options VARCHAR(256) NOT NULL COMMENT 'the directives passed to mysqldump',
  duplicated_databases VARCHAR(256) NOT NULL COMMENT 'the tables that were duplicated',
  target_user VARCHAR(32) NOT NULL COMMENT 'the user on the target machine was granted privileges'
)
CHARACTER SET utf8
COMMENT = 'entries are created by wayang/server/<version>/scripts/duplicate-db.sh';
