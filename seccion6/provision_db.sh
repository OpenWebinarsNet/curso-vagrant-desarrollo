#! /usr/bin/env bash

###
# Adaptado de:
# https://gist.github.com/rrosiek/8190550
# provision.sh
#
###

# Variables
HOSTWEB=192.168.33.10
DBHOST=192.168.33.20
DBNAME=blog
DBUSER=bloguser
DBPASSWD=test123

echo -e "\n--- Realizando provisión de software... ---\n"

echo -e "\n--- Actualizando la lista de paquetes ---\n"
apt-get update

echo -e "\n--- Instalando paquetes base ---\n"
apt-get -y install vim curl build-essential python-software-properties git >> /var/log/vm_build.log 2>&1

# Instalación de MySQL (sólo para desarrollo)
echo -e "\n--- Instalando paquetes de MySQL ---\n"
debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"
apt-get -y install mysql-server >> /var/log/vm_build.log 2>&1

echo -e "\n--- Configurando  MySQL: usuario y base de datos  ---\n"
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME" >> /var/log/vm_build.log 2>&1
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'" > /var/log/vm_build.log 2>&1
mysql -uroot -p$DBPASSWD -e "grant all privileges on *.* to 'root'@'$HOSTWEB' identified by '$DBPASSWD'" > /var/log/vm_build.log 2>&1

sed -i "s/127.0.0.1/$DBHOST/" /etc/mysql/mysql.conf.d/mysqld.cnf

systemctl restart mysql.service