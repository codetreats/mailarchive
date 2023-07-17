#!/bin/bash
./prepare.sh &
./start.sh &
/usr/bin/php /import.php 300 &
sleep infinity
