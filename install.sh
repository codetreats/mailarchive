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

export DB_USER=mailarchive
export DB_ROOT_PASSWORD=$(cat /proc/sys/kernel/random/uuid)
export USERNAME=$(echo $MAIL_ADDRESS | cut -d '@' -f1)
export DOMAIN=$(echo $MAIL_ADDRESS | cut -d '@' -f2)

mkdir -p $IMPORT_SENT
mkdir -p $IMPORT_RECEIVED

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
mkdir -p tmp/$CONTAINER_NAME
cp docker-compose.yml tmp/$CONTAINER_NAME/
cd tmp/$CONTAINER_NAME

docker-compose up --detach
