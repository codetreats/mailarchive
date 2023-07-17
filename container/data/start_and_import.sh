#!/bin/bash

service mariadb start

./prepare.sh &
sleep 10
./start.sh &
./import.sh &
sleep infinity
