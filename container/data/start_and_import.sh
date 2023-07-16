#!/bin/bash
./prepare.sh &
./start.sh &
/usr/bin/php /import.php &
sleep infinity
