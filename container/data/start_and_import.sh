#!/bin/bash

service mariadb start
sleep 10
./prepare.sh &
sleep 10
./start.sh &
./import.sh &
sleep infinity
