#!/bin/sh


mysqldump -uroot -psewrAXu3EWrEprAg --add-drop-database \
    --add-drop-table --add-locks --compress --comments \
    --create-options --disable-keys --extended-insert \
    --flush-privileges --lock-all-tables \
    --databases adm dat sys