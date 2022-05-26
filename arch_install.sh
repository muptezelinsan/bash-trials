#!/usr/bin/env bash

echo "-------------------------------------------------"
echo "efi bolumunun kurulacagi partisyon : (orn: sda1 / vda1)"
echo "-------------------------------------------------"
read efipart
sleep 1s
mkfs.vfat /dev/$efipart

echo "-------------------------------------------------"
echo "Takas bolumunun kurulacagi partisyon : (orn: sda1 / vda1)"
echo "-------------------------------------------------"
read swappart
sleep 1s
mkswap /dev/$swappart

echo "-------------------------------------------------"
echo "Root bolumunun kurulacagi partisyon : (orn: sda1 / vda1)"
echo "-------------------------------------------------"
read rootpart
sleep 1s
mkfs.ext4 /dev/$rootpart

echo "-------------------------------------------------"
echo "Home bolumunun kurulacagi partisyon : (orn: sda1 / vda1)"
echo "-------------------------------------------------"
read homepart
sleep 1s
mkfs.ext4 /dev/$homepart

mount /dev/$rootpart /mnt

echo "-------------------------------------------------"
echo "Dosyalar olusturuluyor"
echo "-------------------------------------------------"
sleep 1s
mkdir -p /mnt/boot/efi
mkdir -p /mnt/home

echo "-------------------------------------------------"
echo "Montaj islemleri yapiliyor"
echo "-------------------------------------------------"
sleep 1s
mount /dev/$efipart /mnt/boot/efi
swapon /dev/$swappart
mount /dev/$homepart /mnt/home

echo "-------------------------------------------------"
echo "Temel paket yuklemeleri yapiliyor"
echo "-------------------------------------------------"
sleep 1s
pacstrap -i /mnt base base-devel linux linux-headers linux-firmware nano networkmanager git grub mtools dosfstools efibootmgr os-prober --noconfirm

echo "-------------------------------------------------"
echo "fstab dosyasi yaziliyor"
echo "-------------------------------------------------"
sleep 1s
genfstab -U /mnt >> /mnt/etc/fstab

echo "-------------------------------------------------"
echo "-------------------------------------------------"
sleep 1s
echo "-------------------------------------------------"
echo "CHROOT islemlerine geciliyor"
echo "-------------------------------------------------"
sleep 1s
echo "-------------------------------------------------"
echo "-------------------------------------------------"
sleep 1s
arch-chroot /mnt /bin/bash << EOF

echo "-------------------------------------------------"
echo "Yerel saat icin bolge bilgisi girin: (orn: Europe/Istanbul)"
echo "-------------------------------------------------"
read zoneinfo
sleep 3s
ln -sf /usr/share/zoneinfo/$zoneinfo /etc/localtime
hwclock --systohc --utc

echo "-------------------------------------------------"
echo "Dil ayarlari icin deger girin :(orn: tr_TR)"
echo "-------------------------------------------------"
read lang
sleep 1s
sed -i 's/^#$lang.UTF-8 UTF-8/$lang.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG="$lang.UTF-8" >> /etc/locale.conf
echo "-------------------------------------------------"
echo "Klavye ayarlari icin deger girin :(orn: trq)"
echo "-------------------------------------------------"
read locale
sleep 1s
echo "KEYMAP=$locale" >> /etc/vconsole.conf
echo "-------------------------------------------------"
echo "Ana makine adi icin deger girin"
echo "-------------------------------------------------"
read hostname
sleep 1s
echo "$hostname" >> /etc/hostname.conf
echo "
127.0.0.1   localhost
::1         localhost
127.0.1.1   localhost.localdomain   $hostname" >> /etc/hosts
echo "-------------------------------------------------"
echo "Kullanici adi girin:"
echo "-------------------------------------------------"
read usersadd
sleep 1s
useradd -mG wheel $usersadd
echo "-------------------------------------------------"
echo "Kullanici icin parola girin:"
echo "-------------------------------------------------"
read pswd
sleep 1s
echo "$usersadd:$pswd" | chpasswd --encrypted
echo "root:$pswd" | chpasswd --encrypted
echo "$usersadd ALL=(ALL:ALL) ALL >> /etc/sudoers.d/10-$usersadd"
echo "-------------------------------------------------"
echo "Kullanici parolasi root parolasi olarak atandi:"
echo "-------------------------------------------------"
sleep 1s
echo "-------------------------------------------------"
echo "grub islemleri yapiliyor:"
echo "-------------------------------------------------"
sleep 1s
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=$hostname
grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -p linux
systemctl enable NetworkManager
echo "-------------------------------------------------"
echo "-------------------------------------------------"
sleep 1s
echo "-------------------------------------------------"
echo "CHROOT islemleri tamamlandi. Cikiliyor"
echo "-------------------------------------------------"
sleep 1s
echo "-------------------------------------------------"
echo "-------------------------------------------------"
sleep 3s
exit
EOF
#umount -R /mnt
#swapoff -a
#reboot
