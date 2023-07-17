#!/bin/bash
set -e
cd $(dirname "$0")
BASEDIR=$(pwd)

chmod +x config.cfg
. ./config.cfg

export MAIL_ADDRESS
export USER_PASSWORD
export IMPORT
export SERVER_PORT
export SUBNET
export MAILARCHIVE_HOST
export CONTAINER_NAME

export DB_USER=mailarchive
export DB_ROOT_PASSWORD=$(cat /proc/sys/kernel/random/uuid)
export USERNAME=$(echo $MAIL_ADDRESS | cut -d '@' -f1)
export DOMAIN=$(echo $MAIL_ADDRESS | cut -d '@' -f2)

mkdir -p $IMPORT

rm_container() {
  CONTAINER=$1
  if [[ $(docker ps -q --filter "name=$CONTAINER"  | wc -l) -gt 0 ]]
  then
     echo "Remove $CONTAINER"
     docker rm -f $CONTAINER
  fi
}

# remove old container
rm_container "$CONTAINER_NAME"-db
rm_container "$CONTAINER_NAME"-server

# build image
cd $BASEDIR/container
docker build -t mailarchive:0.1.0 .

# start
cd $BASEDIR
docker-compose up --detach
