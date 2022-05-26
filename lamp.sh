#! /bin/bash

echo "apache/httpd kurulumu"

# apache/httpd kurulumu
sudo pacman -Syu
sudo pacman -Syu apache 

# apache/httpd konfigürasyonu
sudo systemctl enable --now httpd
sudo systemctl start httpd
sed -i 's/#unique_id_module/unique_id_module/g' /etc/httpd/conf/httpd.conf 
sudo systemctl restart httpd

clear

echo "Php Kurulumu"

# Php Kurulumu
sudo pacman -S php php-cgi php-gd php-pgsql php-apache
sed -i 's/mpm_event_module/#mpm_event_module/g' /etc/httpd/conf/httpd.conf
sed -i 's/#mpm_prefork_module/mpm_prefork_module/g' /etc/httpd/conf/httpd.conf

phpchose() {
        while :
        do
                read -p 'Lütfen php sürümünüzü seçin -->  (php7/php8?): ' answer
                case "${answer}" in
                    [7]|[php7][7.0]]) exit 0 ;;
                    [8]|[php87][8.0]]) exit 1 ;;
                esac
        done
}


if $( phpchose ); then
cat << EOF >> /etc/httpd/conf/httpd.conf
    LoadModule php7_module modules/libphp7.so
    AddHandler php7-script php
    Include conf/extra/php7_module.conf
EOF
sed -i 's/;gd/gd/g' /etc/php7/php.ini
sed -i 's/;mysqli/mysqli/g' /etc/php7/php.ini
else
cat << EOF >> /etc/httpd/conf/httpd.conf
    LoadModule php_module modules/libphp7.so
    AddHandler php-script php
    Include conf/extra/php_module.conf
EOF
sed -i 's/;gd/gd/g' /etc/php/php.ini
sed -i 's/;mysqli/mysqli/g' /etc/php/php.ini
fi

cat << EOF > /srv/http/info.php
<?php phpinfo();
EOF

sudo systemctl restart httpd


clear

echo "MySQL/MariaDb Kurulumu"

# MySQL/MariaDb Kurulumu
sudo pacman -S mariadb
sudo mysql_install_db — user=mysql — basedir=/usr — datadir=/var/lib/mysql
sudo systemctl enable mariadb
sudo systemctl start mariadb
sudo mysql_secure_installation

echo "MySQL, root şifresini sorduğunda “Enter” düğmesine basın.  Kullanıcıdan “Kök şifresi ayarla mı?” diye soracaktır.  Şifreyi ayarlamak için 'Y' tuşunu yazın ve enter'a basın.  Her ikisi de farklı şeyler olduğundan, root şifresinin sunucu şifresi ile karıştırılmaması gerektiğini unutmayın.

Bittiğinde, MySQL kurulumunu tamamlamak için tüm seçeneklere 'Y' girin.  MySQL, değişiklikleri otomatik olarak yeniden yükleyecek ve yükleyecektir."
sleep 3s
echo "5 Saniye içerisinde işleme yönlendirileceksiniz"
echo "4 Saniye içerisinde işleme yönlendirileceksiniz"
echo "3 Saniye içerisinde işleme yönlendirileceksiniz"
echo "2 Saniye içerisinde işleme yönlendirileceksiniz"
echo "1 Saniye içerisinde işleme yönlendirileceksiniz"

clear

echo "Otomatik yükleme başlatılıyor"

echo "Kurulum Tamamlandı."

localTest() {
        while :
        do
                read -p 'localhost sayfsını test et..! -->  (evet/hayır?): ' answer
                case "${answer}" in
                    [eE][evet][Evet][yY]|[yes][Yes]]) exit 0 ;;
                    [hH][hayır][Hayır][nN]|[no][No]]) exit 1 ;;
                esac
        done
}


if $( localTest ); then
    firefox-developer-edition https://localhost/
else
    exit
fi



