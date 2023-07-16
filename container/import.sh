#!/bin/bash
add_envelope_from() {
  FILE=$1
  sed -i /^[xX]-[eE][nN][vV][eE][lL][oO][pP][eE]-[fF][rR][oO][mM]:.*/d "$FILE"
  sed -i '1 i\x-envelope-from: <'"$MAIL_ADDRESS"'>' "$FILE"
}

add_envelope_to() {
  FILE=$1
  sed -i /^[xX]-[eE][nN][vV][eE][lL][oO][pP][eE]-[tT][oO]:.*/d "$FILE"
  sed -i '1 i\x-envelope-to: <'"$MAIL_ADDRESS"'>' "$FILE"
}


while true
do
  echo "Sleep"
  sleep 300
  cd /tmp
  rm -rf /tmp/import
  mkdir -p /tmp/import
  mkdir -p /var/piler/import



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
done
