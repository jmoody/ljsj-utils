#!/bin/sh
mysqldump -umoody -p2dulaher --no-create-info --disable-keys --extended-insert --databases booking > booking-data.sql