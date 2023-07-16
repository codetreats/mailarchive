#!/bin/bash
find_mail_addresses_in_file() {
  local FILE="$1"
  EMAIL_PATTERN="[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"
  ADDRESSES=""
  while IFS= read -r line; do
    if [[ $line =~ $EMAIL_PATTERN ]]; then
      ADDRESSES+=" ${BASH_REMATCH[0]}"
    fi
  done < "$FILE"
  echo $ADDRESSES
}

add_mail_address_to_db() {  
  local ADDRESS=$1
  echo "Add $ADDRESS"
  local USERNAME=$(echo $ADDRESS | cut -d '@' -f1)
  local DOMAIN=$(echo $ADDRESS | cut -d '@' -f2)
  
  DOMAIN_EXISTS=$(mysql -h$MYSQL_HOSTNAME -u$MYSQL_USER -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -s -N -e 'select count(domain) from domain where domain="'"$DOMAIN"'";')
  MAIL_EXISTS=$(mysql -h$MYSQL_HOSTNAME -u$MYSQL_USER -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -s -N -e 'select count(email) from email where email="'"$ADDRESS"'";')

  echo "Domain exists? $DOMAIN_EXISTS"
  if [[ $DOMAIN_EXISTS -eq 0 ]] ; then
    mysql -h$MYSQL_HOSTNAME -u$MYSQL_USER -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e 'insert into domain (domain, mapped) VALUES ("'"$DOMAIN"'","'"$DOMAIN"'");'
    mysql -h$MYSQL_HOSTNAME -u$MYSQL_USER -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e 'insert into domain_user (domain, uid) VALUES ("'"$DOMAIN"'",'"$USER_UID"');'
  fi

  echo "Mail exists? $MAIL_EXISTS"
  if [[ $MAIL_EXISTS -eq 0 ]] ; then
    mysql -h$MYSQL_HOSTNAME -u$MYSQL_USER -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e 'insert into email (uid,email) VALUES ('"$USER_UID"', "'"$ADDRESS"'");'
  fi
}

add_mail_addresses_to_db() {
   local FILE="$1"   
   for ADDRESS in $(find_mail_addresses_in_file "$FILE")
   do
     add_mail_address_to_db $ADDRESS
   done
}

while true
do
  echo "Sleep"
  sleep 300
  cd /tmp
  rm -rf /tmp/import
  mkdir -p /tmp/import
  mkdir -p /var/piler/import

  find /import -name "*.eml" -print0 | while read -d $'\0' MAIL; 
  do
    FILENAME=$(cat /proc/sys/kernel/random/uuid)
    echo "Process RECEIVED mail: $MAIL"
    cp "$MAIL" "/tmp/import/$FILENAME"".eml"
    add_mail_addresses_to_db "/tmp/import/$FILENAME"".eml"
    mv "/tmp/import/$FILENAME"".eml" /var/piler/import/
    rm "$MAIL"    
  done

  pilerimport -d /var/piler/import
  
  rm -rf /var/piler/import/*
done
