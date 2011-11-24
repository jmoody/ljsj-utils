-- replication server
create user 'repl'@'pupuk.cs.arizona.edu' identified by 'replonstillwater';
grant replication slave on *.* to 'repl'@'pupuk.cs.arizona.edu';