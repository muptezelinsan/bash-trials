#!/bin/bash

### Archlinux boot/efi bspwm kurulumu

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

echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Aynalar guncelleniyor ${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
pacman -Sy archlinux-keyring --noconfirm 
pacman -Sy reflector python rsync --noconfirm 
reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
cat /etc/pacman.d/mirrorlist
echo ""
sleep 1

YesOrNo() {
        while :
        do
                read -p 'Disk bolumleme yapilacak mi? (y/n?): ' answer
                case "${answer}" in
                    [yY]|[yY][eE]) exit 0 ;;
                    [nN]|[nN][hH]) exit 1 ;;
                esac
        done
}
if $( YesOrNo ); then
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Disk bolumlemesi icin cfdisk komutu calistiriliyor ${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
cfdisk
else
echo "${Bold}${Red}Disk bicimlendirme adimina geciliyor${Sgr0}"
fi
echo ""
sleep 1
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}EFI yuklemesi yapilacak partisyonu secin (Ornek: sda , vda) ${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
read efipart
mkfs.fat -F32 /dev/$efipart
echo ""
sleep 1
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}ROOT yuklemesi yapilacak partisyonu secin (Ornek: sda , vda) ${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
read rootpart
mkfs.ext4 /dev/$rootpart
echo ""
sleep 1

YesOrNo() {
        while :
        do
                read -p 'Takas bolumu kullanilacak mi? (y/n?): ' answer
                case "${answer}" in
                    [yY]|[yY][eE]) exit 0 ;;
                    [nN]|[nN][hH]) exit 1 ;;
                esac
        done
}
if $( YesOrNo ); then
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Swap icin partisyon secin (Ornek: sda , vda) ${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
read swappart
mkfs.ext4 /dev/$swappart
swapon /dev/$swappart
else
echo "${Bold}${Red}Swap partisyonu atlaniyor${Sgr0}"
fi
echo ""
sleep 1

YesOrNo() {
        while :
        do
                read -p 'HOME bolumu kullanilacak mi? (y/n?): ' answer
                case "${answer}" in
                    [yY]|[yY][eE]) exit 0 ;;
                    [nN]|[nN][hH]) exit 1 ;;
                esac
        done
}
if $( YesOrNo ); then
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Home yuklemesi yapilacak partisyonu secin (Ornek: sda , vda) ${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
read homepart
mkfs.ext4 /dev/$homepart
else
echo "${Bold}${Red}Home partisyonu atlaniyor${Sgr0}"
fi
echo ""
sleep 1
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Root montaji yapiliyor${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
mount /dev/$rootpart /mnt
echo ""
sleep 1
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Dosyalar olusturuluyor${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
mkdir -p /mnt/boot/efi
mkdir -p /mnt/home
echo ""
sleep 1
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Montaj islemleri yapiliyor${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
mount /dev/$efipart /mnt/boot/efi
file="/mnt/home"
if [ -e $file ]; then
mount /dev/$homepart /mnt/home
fi
echo ""
sleep 1
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Temel paket yuklemeleri yapiliyor${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
pacstrap -i /mnt base base-devel linux linux-headers linux-firmware nano networkmanager git grub mtools dosfstools efibootmgr os-prober reflector python rsync zsh --noconfirm
echo ""
sleep 1
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}fstab dosyasi yaziliyor${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
genfstab -U /mnt >> /mnt/etc/fstab  
cat /mnt/etc/fstab
echo ""
sleep 1
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Donanim saati ayarlaniyor...${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
timedatectl set-ntp true
echo ""
sleep 1
echo "${Bold}${Yellow}-------------------------------------------------${Sgr0}"
echo "${Bold}${Yellow}-------------------------------------------------${Sgr0}"
echo "${Bold}${Yellow}-------------------------------------------------${Sgr0}"
echo "${Yellow}CHROOT islemlerine geciliyor--------------------${Sgr0}"
echo "${Bold}${Yellow}-------------------------------------------------${Sgr0}"
echo "${Bold}${Yellow}-------------------------------------------------${Sgr0}"
echo "${Bold}${Yellow}-------------------------------------------------${Sgr0}"
echo ""
sleep 3
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Yerel zaman bolgesi ayarlaniyor${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
arch-chroot /mnt /bin/bash -c "pacman -Sy curl --noconfirm"
arch-chroot /mnt /bin/bash -c "ln -sf /usr/share/zoneinfo/$(curl https://ipapi.co/timezone) /etc/localtime"
arch-chroot /mnt /bin/bash -c "timedatectl set-timezone $(curl https://ipapi.co/timezone)"
arch-chroot /mnt /bin/bash -c "hwclock --systohc"
echo ""
sleep 1
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Sistem dilini girin (Ornek : en_US , tr_TR)${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
read lang
echo "$lang.UTF-8 UTF-8" > /mnt/etc/locale.gen
arch-chroot /mnt /bin/bash -c "locale-gen" 
echo "LANG=$lang.UTF-8" > /mnt/etc/locale.conf
arch-chroot /mnt /bin/bash -c "export $(cat /mnt/etc/locale.conf)" 
export $(cat /mnt/etc/locale.conf)
echo ""
sleep 1
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow} Klavye dilini girin (Ornek : us , trq)${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
read keymap
echo "KEYMAP=$keymap" > /mnt/etc/vconsole.conf
arch-chroot /mnt /bin/bash -c "export $(cat /mnt/etc/vconsole.conf)" 
export $(cat /mnt/etc/vconsole.conf)
echo ""
sleep 1
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Ana makine adini girin${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
read hostname
echo "$hostname" > /mnt/etc/hostname
echo "# <ip-address> <hostname.domain.org> <hostname>" >> /mnt/etc/hosts
echo "127.0.0.1 localhost" >> /mnt/etc/hosts
echo "::1 localhost" >> /mnt/etc/hosts
echo "127.0.1.1 $hostname.localdomain $hostname" >> /mnt/etc/hosts
echo "Hostname: $(cat /mnt/etc/hostname)"
echo "Hosts: $(cat /mnt/etc/hosts)"
echo ""
sleep 1
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Yeni kullanici olusturun${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
read user
arch-chroot /mnt /bin/bash -c "useradd -mG wheel $user"
echo ""
sleep 1
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}$user kullanicisi icin parola belirleyin${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
read userpasswd
arch-chroot /mnt /bin/bash -c "(echo $userpasswd ; echo $userpasswd) | passwd $user"
echo ""
sleep 1
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}ROOT kullanicisi icin parola belirleyin${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
read rootpasswd
echo ""
sleep 1
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
arch-chroot /mnt /bin/bash -c "(echo $rootpasswd ; echo $rootpasswd) | passwd root"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
arch-chroot /mnt /bin/bash -c "pacman -Sy bspwm sxhkd dmenu alacritty thunar rofi rxvt-unicode sddm --noconfirm"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
arch-chroot /mnt /bin/bash -c "grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=$hostname"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
arch-chroot /mnt /bin/bash -c "systemctl enable NetworkManager"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
arch-chroot /mnt /bin/bash -c "systemctl enable sddm"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
mkdir -p /mnt/home/$user/.config/bspwm
mkdir -p /mnt/home/$user/.config/sxhkd
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
arch-chroot /mnt /bin/bash -c "cp /usr/share/doc/bspwm/examples/bspwmrc /home/$user/.config/bspwm/"
arch-chroot /mnt /bin/bash -c "cp /usr/share/doc/bspwm/examples/sxhkdrc /home/$user/.config/sxhkd/"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"

cat << EOF >> /mnt/home/$user/.config/bspwm/bspwmrc
###
# Autostart
###
bash $HOME/.config/bspwm/autostart.sh &
EOF
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
cat << EOF >> /mnt/home/$user/.config/bspwm/autostart.sh
###
# Autostart
###
# X11 set keymap
setxkbmap $keymap &
EOF
chmod a+x $HOME/.config/bspwm/autostart.sh

arch-chroot /mnt /bin/bash -c "chown -R $user:$user /home/$user/"
echo "${Bold}${Yellow}-------------------------------------------------${Sgr0}"
echo "${Bold}${Yellow}-------------------------------------------------${Sgr0}"
echo "${Bold}${Yellow}-------------------------------------------------${Sgr0}"
echo "${Yellow}Kurulum tamamlandı--------------------${Sgr0}"
echo "${Bold}${Yellow}-------------------------------------------------${Sgr0}"
echo "${Bold}${Yellow}-------------------------------------------------${Sgr0}"
echo "${Bold}${Yellow}-------------------------------------------------${Sgr0}"
echo ""
sleep 3

YesOrNo() {
        while :
        do
                read -p 'Montajlari ayir ve sistemi yeniden baslat? (y/n?): ' answer
                case "${answer}" in
                    [yY]|[yY][eE]) exit 0 ;;
                    [nN]|[nN][hH]) exit 1 ;;
                esac
        done
}
if $( YesOrNo ); then
umount -R /mnt
swapoff -a
reboot
else
echo "${Bold}${Red}Cikis yapacaginiz zaman montajlari ayirmayi unutmayin${Sgr0}"
fi
sleep 3
clear
