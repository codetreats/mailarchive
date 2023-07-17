#!/bin/bash
set -e
if [ -f /prepared.flag ] ; then
  exit
fi

echo "[PREPARE] Prepare DB"
mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE $MYSQL_DATABASE;"
mysql -uroot -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e "CREATE USER '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';"
mysql -uroot -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'localhost';"
mysql -uroot -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e "FLUSH PRIVILEGES;"

sleep 30

echo "[PREPARE] Adapt config"
sed -i 's/thread_stack.*=.*/thread_stack            = 512M/g' /etc/piler/manticore.conf
sed -i 's/#mailpreviewframe{/#mailpreviewframe{height:400px;/g' /var/piler/www/view/theme/default/assets/css/metro-bootstrap.css
mysql -u$MYSQL_USER -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e 'INSERT INTO `option` (`key`, `value`) VALUES ("enable_purge", "0");'


PASS=$(php hash_password.php $USER_PASSWORD)
echo "[PREPARE] Adapt piler settings"
mysql -u$MYSQL_USER -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e 'update user set password = "'"$PASS"'" where uid=0;'
mysql -u$MYSQL_USER -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e 'insert into user (uid, username, realname, password, domain) VALUES ('"$USER_UID"', "'"$USERNAME"'","'"$USERNAME"'","'"$PASS"'","'"$DOMAIN"'");'
mysql -u$MYSQL_USER -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e 'insert into domain (domain, mapped) VALUES ("'"$DOMAIN"'","'"$DOMAIN"'");'
mysql -u$MYSQL_USER -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e 'insert into domain_user (domain, uid) VALUES ("'"$DOMAIN"'",'"$USER_UID"');'
mysql -u$MYSQL_USER -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e 'insert into email (uid,email) VALUES ('"$USER_UID"', "'"$USERNAME@$DOMAIN"'");'
mysql -u$MYSQL_USER -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e 'insert into email (uid,email) VALUES ('"$USER_UID"', "x-envelope-to_'"$USERNAME@$DOMAIN"'");'
mysql -u$MYSQL_USER -p$MYSQL_PASSWORD --database=$MYSQL_DATABASE -e 'insert into email (uid,email) VALUES ('"$USER_UID"', "x-envelope-from_'"$USERNAME@$DOMAIN"'");'
touch /prepared.flag
