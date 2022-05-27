#! /bin/bash

if [[ `id -u` != 0 ]]; then
    echo "Komut dosyasini calistirmak için ROOT olmalisiniz"
    exit
fi

echo "apache/httpd kurulumu"

# apache/httpd kurulumu
pacman -Syu
pacman -Syu apache 

# apache/httpd konfigurasyonu
systemctl enable --now httpd
systemctl start httpd
sed -i 's/#LoadModule unique_id_module/LoadModule unique_id_module/g' /etc/httpd/conf/httpd.conf
systemctl restart httpd

cat << EOF > /srv/http/index.html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta http-equiv="X-UA-Compatible" content="ie=edge" />
  <title>Welcome</title>
 </head>
<body>
  <h2>Welcome to my Web Server test page</h2>
</body>
</html>
EOF

clear

echo "Php Kurulumu"

# Php Kurulumu
phpvrs() {
        while :
        do
                read -p 'Yuklemek istediginiz php surumunu secin -->  ( php7 / php8 ?): ' answer
                case "${answer}" in
                    [7]|[php7][7.0]]) exit 0 ;;
                    [8]|[php87][8.0]]) exit 1 ;;
                esac
        done
}


if $( phpvrs ); then
pacman -S php7 php7-cgi php7-gd php7-pgsql php7-apache

cat << EOF >> /etc/httpd/conf/httpd.conf
    LoadModule php7_module modules/libphp7.so
    AddHandler php7-script php
    Include conf/extra/php7_module.conf
EOF
sed -i 's/;gd/gd/g' /etc/php7/php.ini
sed -i 's/;mysqli/mysqli/g' /etc/php7/php.ini

else
pacman -S php php-cgi php-gd php-pgsql php-apache

cat << EOF >> /etc/httpd/conf/httpd.conf
    LoadModule php_module modules/libphp7.so
    AddHandler php-script php
    Include conf/extra/php_module.conf
EOF
sed -i 's/;gd/gd/g' /etc/php/php.ini
sed -i 's/;mysqli/mysqli/g' /etc/php/php.ini
fi

sed -i 's/LoadModule mpm_event_module/#LoadModule mpm_event_module/g' /etc/httpd/conf/httpd.conf
sed -i 's/#LoadModule mpm_prefork_module/LoadModule mpm_prefork_module/g' /etc/httpd/conf/httpd.conf

cat << EOF > /srv/http/info.php
<?php phpinfo();
EOF

systemctl restart httpd

clear

echo "MySQL/MariaDb Kurulumu"

# MySQL/MariaDb Kurulumu
pacman -S mariadb
mysql_install_db — user=mysql — basedir=/usr — datadir=/var/lib/mysql
systemctl enable mariadb
systemctl start mariadb
mysql_secure_installation

echo "MySQL, root sifresini sordugunda 'Enter' dugmesine basin.  Kullanicidan 'Kok sifresi ayarla mi?' diye soracaktir.  sifreyi ayarlamak icin 'Y' tusunu yazin ve enter'a basin.  Her ikisi de farkli seyler oldugundan, root sifresinin sunucu sifresi ile karistirilmamasi gerektigini unutmayin.

Bittiginde, MySQL kurulumunu tamamlamak icin tum seceneklere 'Y' girin.  MySQL, degisiklikleri otomatik olarak yeniden yukleyecek ve yukleyecektir."
sleep 5s
echo "5 Saniye icerisinde isleme yonlendirileceksiniz"
echo "4 Saniye icerisinde isleme yonlendirileceksiniz"
echo "3 Saniye icerisinde isleme yonlendirileceksiniz"
echo "2 Saniye icerisinde isleme yonlendirileceksiniz"
echo "1 Saniye icerisinde isleme yonlendirileceksiniz"

clear

echo "Otomatik yukleme baslatiliyor"

echo "Kurulum Tamamlandi."
