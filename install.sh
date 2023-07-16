#!/bin/bash
set -e
cd $(dirname "$0")
BASEDIR=$(pwd)

chmod +x config.cfg
. ./config.cfg

export MAIL_ADDRESS
export USER_PASSWORD
export IMPORT_SENT
export IMPORT_RECEIVED
export SERVER_PORT
export SUBNET
export MAILARCHIVE_HOST

export DB_USER=mailarchive
export DB_ROOT_PASSWORD=$(cat /proc/sys/kernel/random/uuid)
export USERNAME=$(echo $MAIL_ADDRESS | cut -d '@' -f1)
export DOMAIN=$(echo $MAIL_ADDRESS | cut -d '@' -f2)

mkdir -p $IMPORT_SENT
mkdir -p $IMPORT_RECEIVED
rm -rf $IMPORT_SENT/*
rm -rf $IMPORT_RECEIVED/*


rm_container() {
  CONTAINER_NAME=$1
  if [[ $(docker ps -q --filter "name=$CONTAINER_NAME"  | wc -l) -gt 0 ]]
  then
     echo "Remove $CONTAINER_NAME"
     docker rm -f $CONTAINER_NAME
  fi
}

# remove old container
rm_container mailarchive-db
rm_container mailarchive-server

# build image
cd $BASEDIR/container
docker build -t mailarchive:0.1.0 .

# start
cd $BASEDIR
docker-compose up --detach
