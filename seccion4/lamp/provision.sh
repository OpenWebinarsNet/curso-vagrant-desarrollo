#! /usr/bin/env bash

###
# Adaptado de:
# https://gist.github.com/rrosiek/8190550
# provision.sh
#
###

# Variables
DBHOST=localhost
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
debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none"
apt-get -y install mysql-server phpmyadmin >> /var/log/vm_build.log 2>&1

echo -e "\n--- Configurando  MySQL: usuario y base de datos  ---\n"
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME" >> /var/log/vm_build.log 2>&1
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'" > /var/log/vm_build.log 2>&1

echo -e "\n--- Instalando paquetes de PHP ---\n"
apt-get -y install php apache2 libapache2-mod-php php-curl php-gd php-mysql php-gettext >> /var/log/vm_build.log 2>&1

echo -e "\n--- Habilitando mod-rewrite ---\n"
a2enmod rewrite >> /var/log/vm_build.log 2>&1

echo -e "\n--- Permitiendo a  Apache override all ---\n"
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

echo -e "\n--- Definiendo el document root a /var/www/blog/web (como lo requiere symfony) ---\n"
sed -i "s/www\/html/www\/blog\/web/" /etc/apache2/sites-enabled/000-default.conf

echo -e "\n--- Activamos PHP errors ---\n"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/apache2/php.ini

echo -e "\n--- Reiniciando Apache ---\n"
service apache2 restart >> /var/log/vm_build.log 2>&1

echo -e "\n--- Instalando Composer para gestión de paquetes PHP ---\n"
apt-get -y install composer

echo -e "\n--- Actualizando componentes del proyecto ---\n"

cd /var/www/blog

composer install >> /var/log/vm_build.log 2>&1

echo -e "\n--- Configurando aplicación blog ---\n"

sed -i "s/database_name: symfony/database_name: blog/" /var/www/blog/app/config/parameters.yml
sed -i "s/database_user: root/database_user: root/" /var/www/blog/app/config/parameters.yml
sed -i "s/database_password: root/database_password: test123/" /var/www/blog/app/config/parameters.yml

echo -e "\n--- Creando enlace simbólico para uso futuro de phpunit ---\n"

if [[ -x /var/www/blog/vendor/bin/phpunit ]] ;then
  ln -fs /var/www/blog/vendor/bin/phpunit /usr/local/bin/phpunit
fi

echo -e "\n--- Creando la base de datos y rellenándola ---\n"

php /var/www/blog/bin/console doctrine:database:create >> /var/log/vm_build.log 2>&1
php /var/www/blog/bin/console doctrine:schema:create >> /var/log/vm_build.log 2>&1
php /var/www/blog/bin/console doctrine:fixtures:load >> /var/log/vm_build.log 2>&1