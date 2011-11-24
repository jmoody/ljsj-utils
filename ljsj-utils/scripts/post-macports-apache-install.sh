#!/bin/sh
mv /etc/apache2 /etc/apache2.apple
ln -s /opt/local/apache2 /etc/apache2
mv /Library/WebServer/Documents /Library/WebServer/Documents.apple
mv /Library/WebServer/CGI-Executables /Library/WebServer/CGI-Executables.apple
mv /Library/WebServer/share/httpd/manual /Library/WebServer/share/httpd/manual.apple
ln -s /opt/local/apache2/htdocs /Library/WebServer/Documents
ln -s /opt/local/apache2/cgi-bin /Library/WebServer/CGI-Executables
ln -s /opt/local/apache2/manual /Library/WebServer/share/httpd/manual
mv /var/log/apache2 /var/log/apache2.apple
ln -s /opt/local/apache2/logs /var/log/apache2
ln -s /opt/local/apache2/htdocs /var/www
