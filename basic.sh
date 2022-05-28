#! /bin/bash

cfdisk

mkfs.fat -F 32 /dev/sda1
mkswap/dev/dev/sda2
swapon /dev/sda2
mkfs.ext4 /dev/sda3
mkfs.ext4 /dev/sda4

clear
mount /dev/sda3 /mnt
mkdir -p /mnt/boot/efi
mount /dev/sda1
mkdir -p /mnt/home
mount /dev/sda4

pacstrap -i /mnt base base-devel linux linux-headers linux-firmware networkmanager nano git sddm grub mtools dosfstools efibootmgr intel-ucode

genfstab -U /mnt >> /mnt/etc/fstab

clear
arch-chroot /mnt /bin/bash -c "ln -sf /usr/share/zoneinfo/Europe/Istanbul"
arch-chroot /mnt /bin/bash -c "hwclock --systohc -utc"
echo "tr_TR.UTF-8 UTF-8" >> /mnt/etc/locale.gen
echo "LANG=tr_TR.UTF-8" >> /mnt/etc/locale.conf
echo "KEYMAP=trq" >> /mnt/etc/vconsole.conf
locale-gen
echo "ikikarinca" >> /mnt/etc/localtime
echo "
127.0.0.1   localhost
::1         localhost
127.0.1.1   localhost.localdomain   ikikarinca
" >> /mnt/etc/hosts
arch-chroot /mnt /bin/bash -c "useradd -mG wheel ahmet"
arch-chroot /mnt /bin/bash -c "passwd ahmet"
arch-chroot /mnt /bin/bash -c "passwd"
arch-chroot /mnt /bin/bash -c "grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=BASIC"
arch-chroot /mnt /bin/bash -c "grub-mkmconfig -o /boot/grub/grub.cfg"

arch-chroot /mnt /bin/bash -c "systemctl enable networkmanager"
arch-chroot /mnt /bin/bash -c "systemctl enable sddm"

arch-chroot /mnt /bin/bash -c "pacman -Sy --noconfirm alacritty dmenu rofi polybar dunst picom-ibhagwan-git neofetch thunar thunar-volman gvfs thunar-share-plugin firefox-i18n-tr mousepad pulseaudio pavucontrol bspwm sxhkd"

mkdir -p /mnt/home/ahmet/.config/bspwm
mkdir -p /mnt/home/ahmet/.config/sxhkd

arch-chroot /mnt /bin/bash -c "sed -i 's/MODULES=()/MODULES=(i915)/g' /etc/mkinitcpio.conf"
arch-chroot /mnt /bin/bash -c "cp /usr/share/doc/bspwm/examples/bspwmrc /home/ahmet/.config/bspwm/"
arch-chroot /mnt /bin/bash -c "cp /usr/share/doc/bspwm/examples/sxhkdrc /home/ahmet/.config/sxhkd/"
arch-chroot /mnt /bin/bash -c "chown -R ahmet:ahmet /home/ahmet/"
arch-chroot /mnt /bin/bash -c "sed -i 's/urxvt/alacritty/g' /home/ahmet/.config/sxhkd/sxhkdrc"
echo "
setxkbmap tr &
alacritty &
" >> /mnt/home/ahmet/.config/baspwm/bspwmrc
clear
echo "Kurulum Tamamlandi..."
sleep 3
umount -R /mnt
swapoff -a
lsblk
sleep 2
reboot
