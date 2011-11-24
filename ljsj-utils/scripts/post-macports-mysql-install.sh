#!/bin/sh
mkdir -p /var/log/mysql
touch /var/log/mysql/mysql.log
touch /var/log/mysql/mysql-slow.log
ln -s /opt/local/var/db/`hostname`.err /var/log/mysql/`hostname`.err
ln -s /opt/local/var/db/`hostname`.err /opt/local/var/log/mysql5/`hostname`.err
ln -s /var/log/mysql/*.log /opt/local/var/log/mysql5/
