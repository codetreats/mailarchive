#!/bin/bash
if [ -f /user_added.flag ] ; then
  exit
fi
echo "Add user"

USER_UID=2
PASS=$(php hash_password.php $USER_PASSWORD)
sleep 30
mysql -h$MYSQL_HOSTNAME -u$MYSQL_USER -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e 'update user set password = "'"$PASS"'" where uid=0;'
mysql -h$MYSQL_HOSTNAME -u$MYSQL_USER -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e 'insert into user (uid, username, realname, password, domain) VALUES ('"$USER_UID"', "'"$USERNAME"'","'"$USERNAME"'","'"$PASS"'","'"$DOMAIN"'");'
mysql -h$MYSQL_HOSTNAME -u$MYSQL_USER -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e 'insert into domain (domain, mapped) VALUES ("'"$DOMAIN"'","'"$DOMAIN"'");'
mysql -h$MYSQL_HOSTNAME -u$MYSQL_USER -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e 'insert into domain_user (domain, uid) VALUES ("'"$DOMAIN"'",'"$USER_UID"');'
mysql -h$MYSQL_HOSTNAME -u$MYSQL_USER -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e 'insert into email (uid,email) VALUES ('"$USER_UID"', "'"$USERNAME@$DOMAIN"'");'
touch /user_added.flag
