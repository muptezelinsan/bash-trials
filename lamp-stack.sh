#!/bin/bash

############################################################################
########################### TPUT RENK AYARLARI #############################
############################################################################

Bold=$(tput bold)
Sgr0=$(tput sgr0)
Black=$(tput setaf 0)
Red=$(tput setaf 1)
Green=$(tput setaf 2)
Yellow=$(tput setaf 3)
Blue=$(tput setaf 4)
Magenta=$(tput setaf 5)
Cyan=$(tput setaf 6)
White=$(tput setaf 7)

############################################################################
########################### ROOT KULLANICI KONTROLÜ ########################
############################################################################

if [[ `id -u` != 0 ]]; then
    echo "${Bold}${Red}Kurulumu calistirmak için ROOT olmalisiniz${Sgr0}"
    exit
fi

############################################################################
########################### LAMP SERVER KURULUMU ###########################
############################################################################

########################### APACHE KURULUMU ################################
apache_install() {

	echo -e "${Bold}${Blue} Apache yukleniyor...${Sgr0}"
	printf "\n"
	pacman -Sy apache --noconfirm
	sed -i 's/LoadModule unique_id_module modules\/mod_unique_id.so/#LoadModule unique_id_module modules\/mod_unique_id.so/' /etc/httpd/conf/httpd.conf
	printf "\n"
	echo -e "${Bold}${White} Apache hizmeti etkinlestiriliyor..."
	printf "\n"
	systemctl enable httpd
	systemctl start httpd
	printf "\n"
	echo -e "${Bold}${Green} Apache yuklemesi tamamlandi..!"
	printf "\n"
    sleep 3
}

########################### MARIADB KURULUMU ###############################
mariadb_install() {
	echo -e "${Bold}${Blue} Mariadb yukleniyor...${Sgr0}"
	printf "\n"
	pacman -S mariadb --noconfirm
	printf "\n"
	echo -e "${Bold}${White} Mariadb veri dizini baslatiliyor...${Sgr0}"
	printf "\n"
	mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
	printf "\n"
	echo -e "${Bold}${White} Mariadb hizmeti etkinlestiriliyor...${Sgr0}"
	printf "\n"
	systemctl enable mariadb.service
	systemctl start mariadb.service
	printf "\n"
	echo -e "${Bold}${Yellow} Mariadb veritabani guvenligi secenekleri... Lutfen dikkatlice yapilandirin...${Sgr0}"
	printf "\n"
	/usr/bin/mysql_secure_installation
	printf "\n"
	echo -e "${Bold}${Green} Mariadb yuklemesi tamamlandi..!${Sgr0}"
	printf "\n"
    sleep 3
}

########################### PHP KURULUMU ###################################
php_install() {
	echo -e "${Bold}${Blue} Php yukleniyor...${Sgr0}"
	printf "\n"
	pacman -S php php-cgi php-gd php-pgsql php-apache --noconfirm
	printf "\n"
	echo -e "${Bold}${White} Php modulleri yapilandiriliyor...${Sgr0}"
	printf "\n"
	sed -i 's/;extension=bz2.so/extension=bz2.so/' /etc/php/php.ini
	sed -i 's/;extension=mcrypt.so/extension=mcrypt.so/' /etc/php/php.ini
	sed -i 's/;extension=mysqli.so/extension=mysqli.so/' /etc/php/php.ini
	sed -i 's/;extension=pdo_mysql.so/extension=pdo_mysql.so/' /etc/php/php.ini
	sed -i 's/;extension=pdo_sqlite.so/extension=pdo_sqlite.so/' /etc/php/php.ini
	sed -i 's/;extension=zip.so/extension=zip.so/' /etc/php/php.ini
	sed -i 's/LoadModule mpm_event_module modules\/mod_mpm_event.so/#LoadModule mpm_event_module modules\/mod_mpm_event.so/'  /etc/httpd/conf/httpd.conf
	sed -i 's/^#LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/' /etc/httpd/conf/httpd.conf
	sed -i '68 i\LoadModule php_module modules/libphp.so' /etc/httpd/conf/httpd.conf
	sed -i '69 i\AddHandler php-script php' /etc/httpd/conf/httpd.conf
	sed -i '70 i\Include conf/extra/php_module.conf' /etc/httpd/conf/httpd.conf
	printf "\n"
	systemctl restart httpd
	printf "\n"
	echo -e "${Bold}${Green} Php yuklemesi tamamlandi..!${Sgr0}"
	printf "\n"
    sleep 3
}

########################### PHPMYADMIN KURULUMU ############################
phpmyadmin_install() {
	echo -e "${Bold}${Blue} phpMyAdmin yukleniyor...${Sgr0}"
	printf "\n"
	pacman -S phpmyadmin --noconfirm
	printf "\n"
	echo -e "${Bold}${White} phpMyAdmin modulleri yapilandiriliyor...${Sgr0}"
	printf "\n"
	echo 'Alias /phpmyadmin "/usr/share/webapps/phpMyAdmin"' > /etc/httpd/conf/extra/phpmyadmin.conf
	echo '<Directory "/usr/share/webapps/phpMyAdmin">' >> /etc/httpd/conf/extra/phpmyadmin.conf
	echo 'DirectoryIndex index.php' >> /etc/httpd/conf/extra/phpmyadmin.conf
	echo 'AllowOverride All' >> /etc/httpd/conf/extra/phpmyadmin.conf
	echo 'Options FollowSymlinks' >> /etc/httpd/conf/extra/phpmyadmin.conf
	echo 'Require all granted' >> /etc/httpd/conf/extra/phpmyadmin.conf
	echo '</Directory>' >> /etc/httpd/conf/extra/phpmyadmin.conf
    echo "Include conf/extra/phpmyadmin.conf" >> /etc/httpd/conf/httpd.conf
	sed -i '29s/cookie/config/' /etc/webapps/phpmyadmin/config.inc.php
	echo -e "${Bold}${red} PhpMyAdmin root kullanicisi icin parola girin{Sgr0}"
	sed -i '30 i\$cfg['Servers'][$i]['user'] = 'root';' /etc/webapps/phpmyadmin/config.inc.php
	sed -i '31 i\$cfg['Servers'][$i]['password'] = '';' /etc/webapps/phpmyadmin/config.inc.php
	sed -i '35s/false/true/' /etc/webapps/phpmyadmin/config.inc.php
	printf "\n"
	systemctl restart httpd
	printf "\n"
	echo -e "${Bold}${Green} phpMyAdmin yuklemesi tamamlandi..!${Sgr0}"
	printf "\n"
    sleep 3
	echo -e "${Bold}${Green} phpMyAdmin hizmeti durumu..!${Sgr0}"
	systemctl status phpMyAdmin
	printf "\n"
    sleep 3
}

########################### KONFİGÜRASYONLAR ###############################
#finalize() {
#    echo -e "${Bold}${Yellow} Konfigurasyonlar tanimlaniyor...${Sgr0}"
#	printf "\n"
#	cp -f httpd.conf /etc/httpd/conf/httpd.conf
#	cp -f php.ini /etc/php/php.ini
#	cp -f phpmyadmin.conf /etc/httpd/conf/extra/phpmyadmin.conf
#	cp -f config.inc.php /etc/webapps/phpmyadmin/config.inc.php
#	printf "\n"
#	echo -e "${Bold}${Green} Konfigurasyonlar basarili bir sekilde tanimlandi..!${Sgr0}"
#   sleep 3
#}

############################################################################
########################### YUKLEME KOMUTLARI ###############################
    clear
    echo -e "${Bold}${Yellow} Lamp yigini yukleniyor...${Sgr0}"
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
    sleep 3
    exit

############################################################################
############################################################################
############################################################################
