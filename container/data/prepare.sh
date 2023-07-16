#!/bin/bash
if [ -f /prepared.flag ] ; then
  exit
fi

echo "[PREPARE] Adapt config"
sed -i 's/thread_stack.*=.*/thread_stack            = 512M/g' /etc/piler/manticore.conf
mysql -h$MYSQL_HOSTNAME -u$MYSQL_USER -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e 'insert into option (key, value) VALUES ("enable_purge", 0);'


echo "[PREPARE] Add user"
PASS=$(php hash_password.php $USER_PASSWORD)
sleep 30
mysql -h$MYSQL_HOSTNAME -u$MYSQL_USER -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e 'update user set password = "'"$PASS"'" where uid=0;'
mysql -h$MYSQL_HOSTNAME -u$MYSQL_USER -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e 'insert into user (uid, username, realname, password, domain) VALUES ('"$USER_UID"', "'"$USERNAME"'","'"$USERNAME"'","'"$PASS"'","'"$DOMAIN"'");'
mysql -h$MYSQL_HOSTNAME -u$MYSQL_USER -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e 'insert into domain (domain, mapped) VALUES ("'"$DOMAIN"'","'"$DOMAIN"'");'
mysql -h$MYSQL_HOSTNAME -u$MYSQL_USER -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e 'insert into domain_user (domain, uid) VALUES ("'"$DOMAIN"'",'"$USER_UID"');'
mysql -h$MYSQL_HOSTNAME -u$MYSQL_USER -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e 'insert into email (uid,email) VALUES ('"$USER_UID"', "'"$USERNAME@$DOMAIN"'");'
touch /prepared.flag
