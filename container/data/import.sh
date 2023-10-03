#!/bin/bash
add_envelope_from() {
  FILE=$1
  # Use also "to" here, because piler filters mails that have an envelope-from with the own address
  sed -i /^[xX]-[eE][nN][vV][eE][lL][oO][pP][eE]-[tT][oO]:.*/d "$FILE"
  sed -i '1 i\x-envelope-to: <x-envelope-from_'"$MAIL_ADDRESS"'>' "$FILE"
}

add_envelope_to() {
  FILE=$1
  sed -i /^[xX]-[eE][nN][vV][eE][lL][oO][pP][eE]-[tT][oO]:.*/d "$FILE"
  sed -i '1 i\x-envelope-to: <x-envelope-to_'"$MAIL_ADDRESS"'>' "$FILE"
}


while true
do

  cd /tmp
  rm -rf /tmp/import
  mkdir -p /tmp/import
  mkdir -p /var/piler/import

  # Before import: unzip all compressed mails
  find /import -name "*.eml.gz" -print0 | while read -d $'\0' MAIL; 
  do
    FILENAME=$(cat /proc/sys/kernel/random/uuid)
    echo "Unzip COMPRESSED mail: $MAIL"
    gzip -d "$MAIL"
  done

  find /import/received -name "*.eml" -print0 | while read -d $'\0' MAIL; 
  do
    FILENAME=$(cat /proc/sys/kernel/random/uuid)
    echo "Process RECEIVED mail: $MAIL"
    cp "$MAIL" "/tmp/import/$FILENAME"".eml"
    add_envelope_to "/tmp/import/$FILENAME"".eml"
    mv "/tmp/import/$FILENAME"".eml" /var/piler/import/
    rm "$MAIL"
  done

  find /import/sent -name "*.eml" -print0 | while read -d $'\0' MAIL; 
  do
    FILENAME=$(cat /proc/sys/kernel/random/uuid)
    echo "Process SENT mail: $MAIL"
    cp "$MAIL" "/tmp/import/$FILENAME"".eml"
    add_envelope_from "/tmp/import/$FILENAME"".eml"
    mv "/tmp/import/$FILENAME"".eml" /var/piler/import/
    rm "$MAIL"
  done

  pilerimport -d /var/piler/import

  rm -rf /var/piler/import/*

  date
  echo "Sleep $SLEEPTIME seconds"
  sleep $SLEEPTIME
done
