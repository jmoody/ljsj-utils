#!/bin/sh
MYSQL_PASS=sewrAXu3EWrEprAg
MYSQL_USER=root
LOG_FILE=/tmp/sysbench-mysql.log
BACKUP_FILE=/tmp/sysbench-mysql-`date +%Y%m%d%H%M%S`.log


if [ -e $LOG_FILE ]; then
    rm -f $LOG_FILE
fi

TABLE_SIZE=100000
DISTO_TYPE=special
VERBOSE=3
SB=/nfs/isd3/moody/opt/bin/sysbench

for MYSQL_HOST in pupuk.isi.edu kulit.isi.edu car.isi.edu; 
do
    mysql -h$MYSQL_HOST -p$MYSQL_PASS -u$MYSQL_USER --execute "drop database if exists sbtest" 
    mysql -h$MYSQL_HOST -p$MYSQL_PASS -u$MYSQL_USER --execute "create database sbtest" 

    for engine in myisam innodb;
      do
      for threads in 10 20 30 40 50 60 70 80 90 100;
        do
	for oltp_test in simple complex nontrx; 
	  do
	  
	  
	  $SB --verbosity=$VERBOSE --test=oltp --oltp-test-mode=$oltp_test --oltp-table-size=$TABLE_SIZE \
	      --mysql-host=$MYSQL_HOST --mysql-user=$MYSQL_USER --mysql-password=$MYSQL_PASS --mysql-table-engine=$engine prepare

	  echo \($MYSQL_HOST $engine $threads $oltp_test | tee -a $LOG_FILE

	  $SB --verbosity=$VERBOSE --num-threads=$threads  --test=oltp --oltp-test-mode=$oltp_test --oltp-table-size=$TABLE_SIZE \
	      --mysql-host=$MYSQL_HOST --mysql-user=$MYSQL_USER --mysql-password=$MYSQL_PASS --mysql-table-engine=$engine run | tee -a $LOG_FILE
	  
	  echo \) | tee -a $LOG_FILE

	  $SB --verbosity=$VERBOSE --test=oltp --oltp-test-mode=$oltp_test --mysql-host=$MYSQL_HOST --mysql-user=$MYSQL_USER \
	      --mysql-password=$MYSQL_PASS cleanup
	  
	done
      done
    done
done

cp $LOG_FILE $BACKUP_FILE
