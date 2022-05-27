#!/bin/bash

############################################################################
########################### LAMP SERVER KURULUMU ###########################
############################################################################

apache_install() {

	echo -e "\e[32m Apache yukleniyor..."
	printf "\n"
	sudo pacman -Sy apache --noconfirm
	sudo sed -i 's/LoadModule unique_id_module modules\/mod_unique_id.so/#LoadModule unique_id_module modules\/mod_unique_id.so/' /etc/httpd/conf/httpd.conf
	printf "\n"
	echo -e "\e[34m Apache hizmeti etkinlestiriliyor..."
	printf "\n"
	sudo systemctl enable httpd
	sudo systemctl start httpd
	printf "\n"
	echo -e "\e[92m Apache yuklemesi tamamlandi..!"
	printf "\n"
    sleep 3
}

mariadb_install() {
	echo -e "\e[32m Mariadb yukleniyor..."
	printf "\n"
	sudo pacman -S mariadb --noconfirm
	printf "\n"
	echo -e "\e[34m Mariadb veri dizini baslatiliyor..."
	printf "\n"
	sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
	printf "\n"
	echo -e "\e[34m Mariadb hizmeti etkinlestiriliyor..."
	printf "\n"
	sudo systemctl enable mariadb.service
	sudo systemctl start mariadb.service
	printf "\n"
	echo -e "\e[33m Mariadb veritabani guvenligi secenekleri... Lutfen dikkatlice yapilandirin..."
	printf "\n"
	sudo /usr/bin/mysql_secure_installation
	printf "\n"
	echo -e "\e[92m Mariadb yuklemesi tamamlandi..!"
	printf "\n"
    sleep 3
}

php_install() {
	echo -e "\e[32m Php yukleniyor..."
	printf "\n"
	sudo pacman -S php php-apache --noconfirm
	printf "\n"
	echo -e "\e[34m Php modulleri yapilandiriliyor..."
	printf "\n"
	sudo sed -i 's/;extension=bz2.so/extension=bz2.so/' /etc/php/php.ini
	sudo sed -i 's/;extension=mcrypt.so/extension=mcrypt.so/' /etc/php/php.ini
	sudo sed -i 's/;extension=mysqli.so/extension=mysqli.so/' /etc/php/php.ini
	sudo sed -i 's/;extension=pdo_mysql.so/extension=pdo_mysql.so/' /etc/php/php.ini
	sudo sed -i 's/;extension=pdo_sqlite.so/extension=pdo_sqlite.so/' /etc/php/php.ini
	sudo sed -i 's/;extension=zip.so/extension=zip.so/' /etc/php/php.ini
	sudo sed -i 's/LoadModule mpm_event_module modules\/mod_mpm_event.so/#LoadModule mpm_event_module modules\/mod_mpm_event.so/'  /etc/httpd/conf/httpd.conf
	sudo sed -i 's/^#LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/' /etc/httpd/conf/httpd.conf
	sudo sed -i '68 i\LoadModule php_module modules/libphp.so' /etc/httpd/conf/httpd.conf
	sudo sed -i '69 i\AddHandler php-script php' /etc/httpd/conf/httpd.conf
	sudo sed -i '70 i\Include conf/extra/php_module.conf' /etc/httpd/conf/httpd.conf
	printf "\n"
	sudo systemctl restart httpd
	printf "\n"
	echo -e "\e[92m Php yuklemesi tamamlandi..!"
	printf "\n"
    sleep 3
}

phpmyadmin_install() {
	echo -e "\e[32m phpMyAdmin yukleniyor..."
	printf "\n"
	sudo pacman -S php-mcrypt phpmyadmin --noconfirm
	printf "\n"
	echo -e "\e[34m phpMyAdmin modulleri yapilandiriliyor..."
	printf "\n"
	sudo touch /etc/httpd/conf/extra/phpmyadmin.conf
	sudo echo 'Alias /phpmyadmin "/usr/share/webapps/phpMyAdmin"' > /etc/httpd/conf/extra/phpmyadmin.conf
	sudo echo '<Directory "/usr/share/webapps/phpMyAdmin">' >> /etc/httpd/conf/extra/phpmyadmin.conf
	sudo echo 'DirectoryIndex index.php' >> /etc/httpd/conf/extra/phpmyadmin.conf
	sudo echo 'AllowOverride All' >> /etc/httpd/conf/extra/phpmyadmin.conf
	sudo echo 'Options FollowSymlinks' >> /etc/httpd/conf/extra/phpmyadmin.conf
	sudo echo 'Require all granted' >> /etc/httpd/conf/extra/phpmyadmin.conf
	sudo echo '</Directory>' >> /etc/httpd/conf/extra/phpmyadmin.conf
	sudo sed -i '$a\\nInclude conf\/extra\/phpmyadmin.conf' /etc/httpd/conf/httpd.conf
	sudo sed -i '29s/cookie/config/' /etc/webapps/phpmyadmin/config.inc.php
	sudo sed -i '30 i\$cfg['Servers'][$i]['user'] = 'root';' /etc/webapps/phpmyadmin/config.inc.php
	sudo sed -i '31 i\$cfg['Servers'][$i]['password'] = '';' /etc/webapps/phpmyadmin/config.inc.php
	sudo sed -i '35s/false/true/' /etc/webapps/phpmyadmin/config.inc.php
	printf "\n"
	sudo systemctl restart httpd
	printf "\n"
	echo -e "\e[92m phpMyAdmin yuklemesi tamamlandi..!"
	printf "\n"
    sleep 3
	echo -e "\e[92m phpMyAdmin hizmeti durumu..!"
	sudo systemctl status phpMyAdmin
	printf "\n"
    sleep 3
}

finalize() {
	echo -e "\e[36m Konfigurasyonlar tanimlaniyor..."
	printf "\n"
	sudo cp -f httpd.conf /etc/httpd/conf/httpd.conf
	sudo cp -f php.ini /etc/php/php.ini
	sudo cp -f phpmyadmin.conf /etc/httpd/conf/extra/phpmyadmin.conf
	sudo cp -f config.inc.php /etc/webapps/phpmyadmin/config.inc.php
	printf "\n"
	echo -e "\e[92m Konfigurasyonlar basarili bir sekilde tanimlandi..!"
    sleep 3
}

 certbot-apache () {
  echo -e "certbot-apache kurulumu"
	printf "\n"
	sudo trize -Sy -certbot-apache --noconfirm
	sudo certbot --apache
	echo -e "\e[34m certbot-apache hizmeti etkinlestiriliyor..."
	printf "\n"
	sudo systemctl enable certbot-apache
	sudo systemctl start certbot-apache
	sudo sed -i 'Include conf/extra/httpd-acme.conf' /etc/httpd/conf/httpd.conf
	printf "\n"
	echo -e "\e[92m certbot-Apache yuklemesi tamamlandi..!"
	printf "\n"
    sleep 3
 }


clear
echo -e "\e[36m Lamp yigini yukleniyor..."
printf "\n"
printf "\n"
apache_install
printf "\n"
mariadb_install
printf "\n"
php_install
printf "\n"
phpmyadmin_install
printf "\n"
finalize
printf "\n"
sleep 3
exit
