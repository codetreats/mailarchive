#!/bin/bash
set -e
cd $(dirname "$0")
BASEDIR=$(pwd)

CONFIG=$1
if [[ $CONFIG == "" ]] ; then
  CONFIG=config.cfg
fi

echo "Use config: $CONFIG"

chmod +x $CONFIG
. $CONFIG

export MAIL_ADDRESS
export USER_PASSWORD
export IMPORT_SENT
export IMPORT_RECEIVED
export SERVER_PORT
export SUBNET
export MAILARCHIVE_HOST
export CONTAINER_NAME

export DB_ROOT_PASSWORD=$(cat /proc/sys/kernel/random/uuid)
export USERNAME=$(echo $MAIL_ADDRESS | cut -d '@' -f1)
export DOMAIN=$(echo $MAIL_ADDRESS | cut -d '@' -f2)

mkdir -p $IMPORT_SENT
mkdir -p $IMPORT_RECEIVED

# remove old container
if [[ $(docker ps -q --filter "name=$CONTAINER_NAME"  | wc -l) -gt 0 ]]
then
     echo "Remove $CONTAINER_NAME"
     docker rm -f $CONTAINER_NAME
fi

docker image prune -f

# build image
cd $BASEDIR/container
docker build -t mailarchive:master .

# start
cd $BASEDIR
mkdir -p tmp/$CONTAINER_NAME
cp docker-compose.yml tmp/$CONTAINER_NAME/
cd tmp/$CONTAINER_NAME

docker-compose up --detach
