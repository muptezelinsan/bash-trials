#!/bin/bash

# Reset
CO='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

echo "{$BWhite}-------------------------------------------------{$CO}"
echo "{$Yellow}Aynalar guncelleniyor {$CO}"
echo "{$BWhite}-------------------------------------------------{$CO}"
pacman -Sy archlinux-keyring --noconfirm 
pacman -Sy reflector python rsync --noconfirm 
reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
cat /etc/pacman.d/mirrorlist
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
    echo "{$BWhite}-------------------------------------------------{$CO}"
    echo "{$Yellow}Disk bolumlemesi icin cfdisk komutu calistiriliyor {$CO}"
    echo "{$BWhite}-------------------------------------------------{$CO}"
    cfdisk
else
    echo "{$BWhite}Disk bicimlendirme adimina geciliyor{$CO}"
    sleep 1
fi

echo "{$BWhite}-------------------------------------------------{$CO}"
echo "{$Yellow}EFI yuklemesi yapilacak partisyonu secin (Ornek : /dev/sda , /dev/vda) {$CO}"
echo "{$BWhite}-------------------------------------------------{$CO}"
read efipart
mkfs.fat -F32 /dev/$efipart

echo "{$BWhite}-------------------------------------------------{$CO}"
echo "{$Yellow}ROOT yuklemesi yapilacak partisyonu secin (Ornek : /dev/sda , /dev/vda) {$CO}"
echo "{$BWhite}-------------------------------------------------{$CO}"
read rootpart
mkfs.ext4 /dev/$rootpart

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
echo "{$BWhite}-------------------------------------------------{$CO}"
echo "{$Yellow}Swap yuklemesi yapilacak partisyonu secin (Ornek : /dev/sda , /dev/vda) {$CO}"
echo "{$BWhite}-------------------------------------------------{$CO}"
read swappart
mkswap /dev/$swappart
else
    echo "{$BWhite}Swap partisyonu atlaniyor{$CO}"
    sleep 1
fi

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
echo "{$BWhite}-------------------------------------------------{$CO}"
echo "{$Yellow}Home yuklemesi yapilacak partisyonu secin (Ornek : /dev/sda , /dev/vda) {$CO}"
echo "{$BWhite}-------------------------------------------------{$CO}"
read homepart
mkfs.ext4 /dev/$homepart
else
    echo "{$BWhite}Swap partisyonu atlaniyor{$CO}"
    sleep 1
fi

echo "{$BWhite}-------------------------------------------------{$CO}"
echo "{$Yellow}Root montaji yapiliyor{$CO}"
echo "{$BWhite}-------------------------------------------------{$CO}"
mount /dev/$rootpart /mnt

echo "{$BWhite}-------------------------------------------------{$CO}"
echo "{$Yellow}Dosyalar olusturuluyor{$CO}"
echo "{$BWhite}-------------------------------------------------{$CO}"
sleep 1s
mkdir -p /mnt/boot/efi
mkdir -p /mnt/home

echo "{$BWhite}-------------------------------------------------{$CO}"
echo "{$Yellow}Montaj islemleri yapiliyor{$CO}"
echo "{$BWhite}-------------------------------------------------{$CO}"
sleep 1s
mount /dev/$efipart /mnt/boot/efi
swapon /dev/$swappart
file="/mnt/home"
if [ -e $file ]; then
mount /dev/$homepart /mnt/home
fi 

echo "{$BWhite}-------------------------------------------------{$CO}"
echo "{$Yellow}Temel paket yuklemeleri yapiliyor{$CO}"
echo "{$BWhite}-------------------------------------------------{$CO}"
sleep 1s
pacstrap -i /mnt base base-devel linux linux-headers linux-firmware nano networkmanager git grub mtools dosfstools efibootmgr os-prober reflector python rsync zsh --noconfirm

# pacstrap /mnt base base-devel linux linux-firmware amd-ucode btrfs-progs git go kanshi zstd iwd networkmanager mesa vulkan-radeon libva-mesa-driver openssh mesa-vdpau xf86-video-amdgpu docker libvirt qemu refind rustup wl-clipboard zsh sshguard npm bc ripgrep bat tokei hyperfine rust-analyzer xdg-user-dirs systemd-swap pigz pbzip2 snapper chrony noto-fonts a52dec faac iptables-nft tlp faad2 flac jasper grim libdca libdv libmad libmpeg2 libtheora libvorbis waybar wavpack xvidcore libde265 gstreamer gst-libav gst-plugins-bad breeze gst-plugins-base gst-plugins-good gst-plugins-ugly gstreamer-vaapi seahorse sway lollypop alacritty wofi polkit-gnome mako slurp xdg-desktop-portal-wlr gvfs libxv libsecret gnome-keyring nautilus nautilus-image-converter gdm fd xarchiver arj cpio lha udiskie nautilus-share nautilus-sendto imv mpv lrzip unrar zip chezmoi powertop brightnessctl lastpass-cli sbsigntools x264 lzip xorg-xwayland apparmor ttf-roboto ttf-roboto-mono ttf-dejavu ttf-liberation ttf-fira-code ttf-hanazono ttf-fira-mono seahorse-nautilus exa ttf-opensans pulseaudio lzop p7zip ttf-hack noto-fonts noto-fonts-emoji ttf-font-awesome ttf-droid adobe-source-code-pro-fonts firefox-decentraleyes libva-utils man firefox-dark-reader lame network-manager-applet unarj blueman yarn npm code firefox-ublock-origin irqbalance swayidle haveged profile-sync-daemon shfmt compsize pipewire-pulse pipewire-jack pipewire-alsa gnome-boxes wf-recorder dbus-broker wireplumber skim youtube-dl nftables python-nautilus celluloid entr reflector postgresql

echo "{$BWhite}-------------------------------------------------{$CO}"
echo "{$Yellow}fstab dosyasi yaziliyor{$CO}"
echo "{$BWhite}-------------------------------------------------{$CO}"
sleep 1s
genfstab -U /mnt >> /mnt/etc/fstab  
cat /mnt/etc/fstab

echo "{$BWhite}-------------------------------------------------{$CO}"
echo "{$Yellow}Donanim saati ayarlaniyor...{$CO}"
echo "{$BWhite}-------------------------------------------------{$CO}"

timedatectl set-ntp true

echo "{$BWhite}-------------------------------------------------{$CO}"
echo "{$BWhite}-------------------------------------------------{$CO}"
echo "{$BWhite}-------------------------------------------------{$CO}"
echo "{$BYellow}CHROOT islemlerine geciliyor--------------------{$CO}"
echo "{$BWhite}-------------------------------------------------{$CO}"
echo "{$BWhite}-------------------------------------------------{$CO}"
echo "{$BWhite}-------------------------------------------------{$CO}"

echo "{$BWhite}-------------------------------------------------{$CO}"
echo "{$Yellow}Yerel zaman bolgesi ayarlaniyor{$CO}"
echo "{$BWhite}-------------------------------------------------{$CO}"
arch-chroot /mnt /bin/bash -c "pacman -Sy curl --noconfirm"
arch-chroot /mnt /bin/bash -c "ln -sf /usr/share/zoneinfo/$(curl https://ipapi.co/timezone) /etc/localtime"
arch-chroot /mnt /bin/bash -c "timedatectl set-timezone $(curl https://ipapi.co/timezone)"
arch-chroot /mnt /bin/bash -c "hwclock --systohc"

echo "{$BWhite}-------------------------------------------------{$CO}"
echo "{$Yellow}Sistem dilini girin (Ornek : en_US , tr_TR){$CO}"
echo "{$BWhite}-------------------------------------------------{$CO}"
read lang
echo "$lang.UTF-8 UTF-8" > /mnt/etc/locale.gen
arch-chroot /mnt /bin/bash -c "locale-gen" 
echo "LANG=$lang.UTF-8" > /mnt/etc/locale.conf
arch-chroot /mnt /bin/bash -c "export $(cat /mnt/etc/locale.conf)" 
export $(cat /mnt/etc/locale.conf)

echo "{$BWhite}-------------------------------------------------{$CO}"
echo "{$Yellow} Klavye dilini girin (Ornek : us , trq){$CO}"
echo "{$BWhite}-------------------------------------------------{$CO}"
read keymap
echo "KEYMAP=$keymap" > /mnt/etc/vconsole.conf
arch-chroot /mnt /bin/bash -c "export $(cat /mnt/etc/vconsole.conf)" 
export $(cat /mnt/etc/vconsole.conf)

echo "{$BWhite}-------------------------------------------------{$CO}"
echo "{$Yellow}Ana makine adini girin{$CO}"
echo "{$BWhite}-------------------------------------------------{$CO}"
read hostname
echo "$hostname" > /mnt/etc/hostname
echo "# <ip-address> <hostname.domain.org> <hostname>" >> /mnt/etc/hosts
echo "127.0.0.1 localhost" >> /mnt/etc/hosts
echo "::1 localhost" >> /mnt/etc/hosts
echo "127.0.1.1 $hostname.localdomain $hostname" >> /mnt/etc/hosts
echo "Hostname: $(cat /mnt/etc/hostname)"
echo "Hosts: $(cat /mnt/etc/hosts)"

echo "{$BWhite}-------------------------------------------------{$CO}"
echo "{$Yellow}Yeni kullanici olusturun{$CO}"
echo "{$BWhite}-------------------------------------------------{$CO}"
read user
arch-chroot /mnt /bin/bash -c "useradd -mG wheel $user"
echo "{$BWhite}-------------------------------------------------{$CO}"
echo "{$Yellow}$user kullanicisi icin parola belirleyin{$CO}"
echo "{$BWhite}-------------------------------------------------{$CO}"
read userpasswd
arch-chroot /mnt /bin/bash -c "(echo $userpasswd ; echo $userpasswd) | passwd $user"
echo "{$BWhite}-------------------------------------------------{$CO}"
echo "{$Yellow}ROOT kullanicisi icin parola belirleyin{$CO}"
echo "{$BWhite}-------------------------------------------------{$CO}"
read rootpasswd
arch-chroot /mnt /bin/bash -c "(echo $rootpasswd ; echo $rootpasswd) | passwd root"

arch-chroot /mnt /bin/bash -c "pacman -Sy bspwm sxhkd dmenu alacritty thunar rofi rxvt-unicode --noconfirm"
arch-chroot /mnt /bin/bash -c "grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=$hostname"
arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"
arch-chroot /mnt /bin/bash -c "systemctl enable NetworkManager"
arch-chroot /mnt /bin/bash -c "systemctl enable NetworkManager"

mkdir -p /mnt/home/$user/.config/bspwm
mkdir -p /mnt/home/$user/.config/sxhkd

arch-chroot /mnt /bin/bash -c "cp /usr/share/doc/bspwm/examples/bspwmrc /home/$user/.config/bspwm/"
arch-chroot /mnt /bin/bash -c "cp /usr/share/doc/bspwm/examples/sxhkdrc /home/$user/.config/sxhkd/"

arch-chroot /mnt /bin/bash -c "chown -R $user:$user /home/$user/"
