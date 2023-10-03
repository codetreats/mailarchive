#!/bin/bash

service mariadb start
sleep 10
./prepare.sh &
sleep 10
./start.sh &
sleep 10
./import.sh
