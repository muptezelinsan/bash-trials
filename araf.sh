#!/bin/bash

clear
    
echo "  █████╗ ██████╗  ██████╗██╗  ██╗██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗        ";
echo " ██╔══██╗██╔══██╗██╔════╝██║  ██║██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║        ";
echo " ███████║██████╔╝██║     ███████║██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║        ";
echo " ██╔══██║██╔══██╗██║     ██╔══██║██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║        ";
echo " ██║  ██║██║  ██║╚██████╗██║  ██║██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗   ";
echo " ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝   ";
                                                                                      
sleep 4

#CAMBIAR EL LIVEUB A ESPAÑOL
clear
echo ""
echo "Sistema en español"
echo ""
echo "es_PE.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=es_PE.UTF-8" > /etc/locale.conf
export LANG=es_PE.UTF-8
echo ""
sleep 2

#ACTUALIZACION DE LLAVES Y MIRRORLIST
clear
pacman -Sy archlinux-keyring --noconfirm 
clear
pacman -Sy reflector python rsync --noconfirm 
clear
echo ""
echo "Actualizando lista de MirrorList"
echo ""
reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
clear
cat /etc/pacman.d/mirrorlist
clear

#DECLARAR USUARIOS Y CONTRASEÑAS EN MODO CLEAN PARA NO FALLAR
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _
echo "print devices" | parted | grep /dev/ | awk '{if (NR!=1) {print}}'
echo ''
read -p "Introduce tu disco a instalar Arch: " disco
echo ""
read -p "Introduce NOMBRE DEL EQUIPO (host): " hostname
echo ""
read -p "Introduce la clave ROOT: " rootpasswd
echo ""
read -p "Introduce Nombre de USUARIO Nuevo: " user
echo ""
read -p "Introduce la CLAVE de $user: " userpasswd
echo ""
read -p "Introduce tu ubicación, Ejemplo (es_PE.UTF-8 / es_MX.UTF-8 / es_AR.UTF-8): " userpais
echo ""
read -p "Introduce la distribucion de tu teclado, Ejemplo (es / latam / us): " teclado
echo ""
echo "Selección de Disco: $disco"
echo ''
echo "USUARIO: $user"
echo ''
echo "CLAVE DE USUARIO: $userpasswd"
echo ''
echo "CLAVE DE ADMINISTRADOR: $rootpasswd"
sleep 2
echo ''


# PARTICIONAR EL DISCO

uefi=$( ls /sys/firmware/efi/ | grep -ic efivars )


	clear
	echo "Sistema UEFI"
	echo ""
#---METODO CON EFI - SWAP - ROOT-----------------------------------
	sgdisk --zap-all ${disco}
	parted ${disco} mklabel gpt
	sgdisk ${disco} -n=1:0:+512M -t=1:ef00
	sgdisk ${disco} -n=2:0:0
	fdisk -l ${disco} > /tmp/partition
	echo ""
	cat /tmp/partition
	sleep 2

	partition="$(cat /tmp/partition | grep /dev/ | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1}')"

	echo $partition | awk -F ' ' '{print $1}' >  boot-efi
	echo $partition | awk -F ' ' '{print $2}' >  root-efi

	echo ""
	echo "Partición EFI es:" 
	cat boot-efi
	echo ""
	echo "Partición ROOT es:"
	cat root-efi
	echo ""
	sleep 2

# ENCRIPTANDO PARTICION ROOT

	clear
	echo ""
	echo "Encriptando Particion ROOT"
	echo ""
	
	cryptsetup luksFormat --perf-no_read_workqueue --perf-no_write_workqueue --type luks2 --cipher aes-xts-plain64 --key-size 512 --iter-time 2000 --pbkdf argon2id --hash sha3-512 $(cat root-efi)
	cryptsetup --allow-discards --perf-no_read_workqueue --perf-no_write_workqueue --persistent open $(cat root-efi) crypt

	sleep 2

# FORMATEANDO PARTICIONES

	clear
	echo ""
	echo "Formateando Particiones"
	echo ""

	mkfs.vfat -F 32 -n "EFI" $(cat boot-efi) 

	mkfs.btrfs -L Arch -f /dev/mapper/crypt


	sleep 2

# CREANDO SUBVOLUMENES

	clear
	echo ""
	echo "Crear Subvolumenes"
	echo ""


	mount /dev/mapper/crypt /mnt
	btrfs sub create /mnt/@ && \
	btrfs sub create /mnt/@home && \
	btrfs sub create /mnt/@abs && \
	btrfs sub create /mnt/@tmp && \
	btrfs sub create /mnt/@srv && \
	btrfs sub create /mnt/@snapshots && \
	btrfs sub create /mnt/@btrfs && \
	btrfs sub create /mnt/@log && \
	btrfs sub create /mnt/@cache
	umount /mnt

	sleep 2

# MONTAR SUBVOLUMENES

	clear
	echo ""
	echo "Montar Subvolumenes"
	echo ""

	mount -o noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,autodefrag,subvol=@ /dev/mapper/crypt /mnt
	mkdir -p /mnt/{boot,home,var/cache,var/log,.snapshots,btrfs,var/tmp,var/abs,srv}
	mount -o noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,autodefrag,subvol=@home /dev/mapper/crypt /mnt/home  && \
	mount -o nodev,nosuid,noexec,noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,autodefrag,subvol=@abs /dev/mapper/crypt /mnt/var/abs && \
	mount -o nodev,nosuid,noexec,noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,autodefrag,subvol=@tmp /dev/mapper/crypt /mnt/var/tmp && \
	mount -o noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,autodefrag,subvol=@srv /dev/mapper/crypt /mnt/srv && \
	mount -o nodev,nosuid,noexec,noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,autodefrag,subvol=@log /dev/mapper/crypt /mnt/var/log && \
	mount -o nodev,nosuid,noexec,noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,autodefrag,subvol=@cache /dev/mapper/crypt /mnt/var/cache && \
	mount -o noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,autodefrag,subvol=@snapshots /dev/mapper/crypt /mnt/.snapshots && \
	mount -o noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,autodefrag,subvolid=5 /dev/mapper/crypt /mnt/btrfs

	mkdir -p /mnt/var/lib/{docker,machines,mysql,postgres} && \
	chattr +C /mnt/var/lib/{docker,machines,mysql,postgres}


	sleep 2

# MONTAR PARTICION EFI

	clear
	echo ""
	echo "Montar Particion EFI"
	echo ""

	mount -o nodev,nosuid,noexec $(cat boot-efi) /mnt/boot


	clear
	echo ""
	echo "Revise en punto de montaje en MOUNTPOINT"
	echo ""
	lsblk -l
	sleep 2

	clear

# INSTALAR SISTEMA BASE

echo ""
echo "Instalando Sistema base"
echo ""
pacstrap /mnt base base-devel nano reflector python rsync zsh

# pacstrap /mnt base base-devel linux linux-firmware amd-ucode btrfs-progs git go kanshi zstd iwd networkmanager mesa vulkan-radeon libva-mesa-driver openssh mesa-vdpau xf86-video-amdgpu docker libvirt qemu refind rustup wl-clipboard zsh sshguard npm bc ripgrep bat tokei hyperfine rust-analyzer xdg-user-dirs systemd-swap pigz pbzip2 snapper chrony noto-fonts a52dec faac iptables-nft tlp faad2 flac jasper grim libdca libdv libmad libmpeg2 libtheora libvorbis waybar wavpack xvidcore libde265 gstreamer gst-libav gst-plugins-bad breeze gst-plugins-base gst-plugins-good gst-plugins-ugly gstreamer-vaapi seahorse sway lollypop alacritty wofi polkit-gnome mako slurp xdg-desktop-portal-wlr gvfs libxv libsecret gnome-keyring nautilus nautilus-image-converter gdm fd xarchiver arj cpio lha udiskie nautilus-share nautilus-sendto imv mpv lrzip unrar zip chezmoi powertop brightnessctl lastpass-cli sbsigntools x264 lzip xorg-xwayland apparmor ttf-roboto ttf-roboto-mono ttf-dejavu ttf-liberation ttf-fira-code ttf-hanazono ttf-fira-mono seahorse-nautilus exa ttf-opensans pulseaudio lzop p7zip ttf-hack noto-fonts noto-fonts-emoji ttf-font-awesome ttf-droid adobe-source-code-pro-fonts firefox-decentraleyes libva-utils man firefox-dark-reader lame network-manager-applet unarj blueman yarn npm code firefox-ublock-origin irqbalance swayidle haveged profile-sync-daemon shfmt compsize pipewire-pulse pipewire-jack pipewire-alsa gnome-boxes wf-recorder dbus-broker wireplumber skim youtube-dl nftables python-nautilus celluloid entr reflector postgresql

clear



# CONFIGURAR FSTAB

echo ""
echo "Archivo FSTAB"
echo ""
echo "genfstab -U -p /mnt >> /mnt/etc/fstab"
echo ""

genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
sleep 1
clear




# ACTUALIZAR HORA

echo ""
echo "Actualizando Hora"
echo ""

timedatectl set-ntp true


# COPIANDO CONFIGURACIONES DE ZSH PARA UNA MEJOR EXPERIENCIA

echo ""
echo "Copiando configuraciones de ZSH"
echo ""

cp /etc/zsh/zprofile /mnt/root/.zprofile && \
cp /etc/zsh/zshrc /mnt/root/.zshrc
clear



	
# ACTUALZAR MIRRORS

echo ""
echo "Actualizando lista de MirrorList"
echo ""
# arch-chroot /mnt /bin/zsh -c "reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist"
arch-chroot /mnt /bin/bash -c "reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist"

clear
cat /mnt/etc/pacman.d/mirrorlist
sleep 1
clear


# Add pacman mirrorlist
# cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist


# CHROOT EN EL NUEVO SISTEMA

# arch-chroot /mnt /bin/zsh



#CONFIGURANDO PACMAN

#sed -i 's/#UseSyslog/UseSyslog/' /mnt/etc/pacman.conf
sed -i 's/#Color/Color/g' /mnt/etc/pacman.conf
sed -i 's/#TotalDownload/TotalDownload/g' /mnt/etc/pacman.conf
sed -i 's/#VerbosePkgLists/VerbosePkgLists/g' /mnt/etc/pacman.conf
#sed -i 's/#CheckSpace/CheckSpace/' /mnt/etc/pacman.conf

sed -i "37i ILoveCandy" /mnt/etc/pacman.conf

sed -i '93d' /mnt/etc/pacman.conf
sed -i '94d' /mnt/etc/pacman.conf
sed -i "93i [multilib]" /mnt/etc/pacman.conf
sed -i "94i Include = /etc/pacman.d/mirrorlist" /mnt/etc/pacman.conf
clear






#HOST
clear
#NOMBRE DEL COMPUTADOR
echo "$hostname" > /mnt/etc/hostname
echo "# <ip-address> <hostname.domain.org> <hostname>" >> /mnt/etc/hosts
echo "127.0.0.1 localhost" >> /mnt/etc/hosts
echo "::1 localhost" >> /mnt/etc/hosts
echo "127.0.1.1 $hostname.localdomain $hostname" >> /mnt/etc/hosts


clear

echo "Hostname: $(cat /mnt/etc/hostname)"
echo ""
echo "Hosts: $(cat /mnt/etc/hosts)"
echo ""
clear




#USUARIO Y ADMIN
arch-chroot /mnt /bin/bash -c "(echo $rootpasswd ; echo $rootpasswd) | passwd root"
arch-chroot /mnt /bin/bash -c "useradd -m -g users -G docker,input,kvm,libvirt,storage,video,wheel -s /bin/zsh $user"
arch-chroot /mnt /bin/bash -c "(echo $userpasswd ; echo $userpasswd) | passwd $user"

sed -i "82c %wheel ALL=(ALL) NOPASSWD: ALL"  /mnt/etc/sudoers

#VERIFICARLOOOOOOOOO#######
#######################3###

echo "Defaults timestamp_timeout=0" >> /mnt/etc/sudoers



################################
################################
################################


#ACTUALIZACIÓN DE IDIOMA Y ZONA HORARIA
echo "" 
echo -e ""
echo -e "\t\t\t| Actualizando Idioma del Sistema |"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _
echo -e ""

echo "$userpais UTF-8" > /mnt/etc/locale.gen
arch-chroot /mnt /bin/bash -c "locale-gen" 
echo "LANG=$userpais" > /mnt/etc/locale.conf
echo ""
cat /mnt/etc/locale.conf 
cat /mnt/etc/locale.gen
sleep 3
echo ""
arch-chroot /mnt /bin/bash -c "export $(cat /mnt/etc/locale.conf)" 
export $(cat /mnt/etc/locale.conf)
arch-chroot /mnt /bin/bash -c "sudo -u $user export $(cat /etc/locale.conf)"
export $(cat /mnt/etc/locale.conf)
sleep 2

clear
arch-chroot /mnt /bin/bash -c "pacman -Sy curl --noconfirm"
arch-chroot /mnt /bin/bash -c "ln -sf /usr/share/zoneinfo/$(curl https://ipapi.co/timezone) /etc/localtime"

#OPCIONAL

arch-chroot /mnt /bin/bash -c "timedatectl set-timezone $(curl https://ipapi.co/timezone)"
arch-chroot /mnt /bin/bash -c "pacman -S ntp --noconfirm"
clear
arch-chroot /mnt /bin/bash -c "ntpd -qg"
arch-chroot /mnt /bin/bash -c "hwclock --systohc"
sleep 2

clear

#INSTALACION DEL KERNEL
# arch-chroot /mnt /bin/bash -c "pacman -S linux-lts linux-firmware linux-lts-headers mkinitcpio --noconfirm"
arch-chroot /mnt /bin/bash -c "pacman -S linux linux-firmware linux-headers mkinitcpio --noconfirm"



#arch-chroot /mnt /bin/bash -c "pacman -S gnome-shell gdm gnome-control-center gnome-backgrounds gnome-tweaks --noconfirm"
#arch-chroot /mnt /bin/bash -c "systemctl enable gdm"


###################################
##################################
##################################





#INSTALACION DE WIFI
arch-chroot /mnt /bin/bash -c "pacman -S dhcpcd networkmanager net-tools ifplugd --noconfirm"

#INSTALACION DE DRIVERS WIFI
arch-chroot /mnt /bin/bash -c "pacman -S wireless_tools wpa_supplicant wireless-regdb --noconfirm"

#INSTALACION DE DRIVERS BLUETOOTH
arch-chroot /mnt /bin/bash -c "pacman -S bluez bluez-utils pulseaudio-bluetooth --noconfirm"

#ACTIVAR SERVICIOS
arch-chroot /mnt /bin/bash -c "systemctl enable dhcpcd NetworkManager ntpd"
arch-chroot /mnt /bin/bash -c "systemctl enable bluetooth.service"

echo "noipv6rs" >> /mnt/etc/dhcpcd.conf
echo "noipv6" >> /mnt/etc/dhcpcd.conf

#SHELL
arch-chroot /mnt /bin/bash -c "pacman -S zsh-autosuggestions zsh-history-substring-search zsh-completions zsh-syntax-highlighting --noconfirm"

#INSTALACION DE SERVIDOR X
arch-chroot /mnt /bin/bash -c "pacman -S xorg-server xorg-apps xorg-xinit --noconfirm"

#UTILIDADES
arch-chroot /mnt /bin/bash -c "pacman -S p7zip unrar zip unzip gzip bzip2 lzop git wget neofetch lsb-release xdg-user-dirs android-file-transfer android-tools android-udev libmtp libcddb gvfs gvfs-afc gvfs-smb gvfs-gphoto2 gvfs-mtp gvfs-goa gvfs-nfs dosfstools jfsutils f2fs-tools btrfs-progs exfat-utils ntfs-3g reiserfsprogs xfsprogs nilfs-utils polkit gpart mtools ffmpeg aom libde265 x265 x264 libmpeg2 xvidcore libtheora libvpx schroedinger sdl gstreamer gst-plugins-bad gst-plugins-base gst-plugins-base-libs gst-plugins-good gst-plugins-ugly xine-lib lame --noconfirm"
arch-chroot /mnt /bin/bash -c "xdg-user-dirs-update"
clear
echo ""
arch-chroot /mnt /bin/bash -c "ls -l /home/$user"
sleep 2

#AUDIO
arch-chroot /mnt /bin/bash -c "pacman -S pulseaudio pulseaudio-alsa pavucontrol alsa-plugins alsa-utils --noconfirm"

#FONTS (TIPOGRAFIAS)
arch-chroot /mnt /bin/bash -c "pacman -S ttf-dejavu ttf-liberation xorg-fonts-type1 ttf-bitstream-vera gnu-free-fonts --noconfirm"

#NAVEGADOR WEB
#arch-chroot /mnt /bin/bash -c "pacman -S chromium --noconfirm"
#chromium
#opera
#vivaldi

#ESTABLECER FORMATO DE TECLADO
clear
        
case $teclado in
 
	latam) teclado_tty="la-latin1"
	;;  
  
	*) teclado_tty=$teclado
	;;
	
esac
 
echo "KEYMAP=$teclado_tty" > /mnt/etc/vconsole.conf
cat /mnt/etc/vconsole.conf 
clear
 
      arch-chroot /mnt /bin/bash -c "localectl --no-convert set-x11-keymap "$teclado"" 
      
      echo -e 'Section "InputClass"' > /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
      echo -e 'Identifier "system-keyboard"' >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
      echo -e 'MatchIsKeyboard "on"' >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
      echo -e 'Option "XkbLayout" "'$teclado'"' >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
      echo -e 'EndSection' >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf           
      echo ""
      cat /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
      sleep 2
      clear
      
# INSTALAR YAY
echo "cd && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si --noconfirm && cd && rm -rf yay-bin" | arch-chroot /mnt /bin/bash -c "su $user"
sed -i "82c %wheel ALL=(ALL) ALL"  /mnt/etc/sudoers

#INSTALACION DE DRIVERS DE VIDEO

case $(systemd-detect-virt) in
        oracle)
            grafica="virtualbox-guest-utils xf86-video-vmware virtualbox-host-modules-arch mesa"
        ;;
        vmware)
            grafica="xf86-video-vmware xf86-input-vmmouse open-vm-tools net-tools gtkmm mesa"
        ;;
        qemu)
            grafica="spice-vdagent xf86-video-fbdev mesa mesa-libgl qemu-guest-agent"
        ;;
        kvm)
            grafica="spice-vdagent xf86-video-fbdev mesa mesa-libgl qemu-guest-agent"
        ;;
        microsoft)
            grafica="xf86-video-fbdev mesa-libgl"
        ;;
        xen)
            grafica="xf86-video-fbdev mesa-libgl"
        ;;
        *)
            if (lspci | grep VGA | grep "NVIDIA\|nVidia" &>/dev/null); then
                grafica="xf86-video-nouveau mesa lib32-mesa mesa-vdpau libva-mesa-driver"
                
            elif (lspci | grep VGA | grep "Radeon R\|R2/R3/R4/R5" &>/dev/null); then
                grafica="xf86-video-amdgpu mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon mesa-vdpau libva-mesa-driver lib32-mesa-vdpau lib32-libva-mesa-driver libva-vdpau-driver libvdpau-va-gl libva-utils vdpauinfo opencl-mesa clinfo ocl-icd lib32-ocl-icd opencl-headers"

            elif (lspci | grep VGA | grep "ATI\|AMD/ATI" &>/dev/null); then
                grafica="xf86-video-ati mesa lib32-mesa mesa-vdpau libva-mesa-driver lib32-mesa-vdpau lib32-libva-mesa-driver libva-vdpau-driver libvdpau-va-gl libva-utils vdpauinfo opencl-mesa clinfo ocl-icd lib32-ocl-icd opencl-headers"

             elif (lspci | grep VGA | grep "Intel" &>/dev/null); then
                grafica="xf86-video-intel vulkan-intel mesa lib32-mesa intel-media-driver libva-intel-driver libva-vdpau-driver libvdpau-va-gl libva-utils vdpauinfo intel-compute-runtime clinfo ocl-icd lib32-ocl-icd opencl-headers"
                
             else
                grafica="xf86-video-vesa"
            
        fi
        ;;
    esac

arch-chroot /mnt /bin/bash -c "pacman -S $grafica --noconfirm --needed"


# INSTALAR UTILIDADES DESDE YAY



# Sign bootloader & kernel for Secure Boot

arch-chroot /mnt /bin/bash -c "yay --noremovemake --nodiffmenu -S shim-signed"
arch-chroot /mnt /bin/bash -c "refind-install --shim /usr/share/shim-signed/shimx64.efi --localkeys"
arch-chroot /mnt /bin/bash -c "sbsign --key /etc/refind.d/keys/refind_local.key --cert /etc/refind.d/keys/refind_local.crt --output /boot/vmlinuz-linux /boot/vmlinuz-linux"



# Add some user niceties whiler you are there

arch-chroot /mnt /bin/bash -c "rustup default stable"
arch-chroot /mnt /bin/bash -c "yay --noremovemake --nodiffmenu --batchinstall -S otf-san-francisco fedora-firefox-wayland-bin otf-san-francisco pamac-aur starship-bin firefox-extension-amazon-container gst-plugin-libde265 firefox-extension-privacybadger poweralertd zoxide-bin firefox-extension-https-everywhere firefox-extension-facebook-container wob firefox-extension-containerise ananicy-git lastpass nwg-launchers persway neovim-nightly-git swaylock-effects-git lazygit-bin grimshot memavaild prelockd nohang-git auto-cpufreq-git otf-nerd-fonts-monacob-mono refind-btrfs bat-extras-git opennic-up ttf-wps-office-fonts wps-office wps-office-mime neovim-remote git-delta-bin  git-journal just gitui-bin procs-bin"
arch-chroot /mnt /bin/bash -c "yay --noremovemake --nodiffmenu --editmenu -S linux-xanmod-cacule linux-xanmod-cacule-headers"
arch-chroot /mnt /bin/bash -c "export PATH=/usr/bin/ && yay -S nerd-fonts-jetbrains-mono"


# Add rEFInd theme

arch-chroot /mnt /bin/bash -c "mkdir /boot/EFI/refind/themes"
arch-chroot /mnt /bin/bash -c "git clone https://github.com/dheishman/refind-dreary.git /boot/EFI/refind/themes/refind-dreary-git"
arch-chroot /mnt /bin/bash -c "mv /boot/EFI/refind/themes/refind-dreary-git/highres /boot/EFI/refind/themes/refind-dreary"
arch-chroot /mnt /bin/bash -c "rm -dR /boot/EFI/refind/themes/refind-dreary-git"
rm -dR /boot/EFI/refind/themes/refind-dreary-git

# Configure rEFInd

sed -i 's/#resolution 3/resolution 1920 1080/' /mnt/boot/EFI/refind/refind.conf
sed -i 's/#use_graphics_for osx,linux/use_graphics_for linux/' /mnt/boot/EFI/refind/refind.conf
sed -i 's/#scanfor internal,external,optical,manual/scanfor manual,external/' /mnt/boot/EFI/refind/refind.conf
sed -i 's/^hideui.*/hideui singleuser,hints,arrows,badges/' /mnt/boot/EFI/refind/themes/refind-dreary/theme.conf

# Add rEFInd Manual Stanza

cat << EOF >> /mnt/boot/EFI/refind/refind.conf

menuentry "Arch Linux" {
    icon     /EFI/refind/themes/refind-dreary/icons/os_arch.png
    volume   "Arch Linux"
    loader   /vmlinuz-linux
    initrd   /initramfs-linux.img
    options  "rd.luks.name=$(blkid /dev/sda2 | cut -d " " -f2 | cut -d '=' -f2 | sed 's/\"//g')=crypt root=/dev/mapper/crypt rootflags=subvol=@ rw quiet nmi_watchdog=0 kernel.unprivileged_userns_clone=0 net.core.bpf_jit_harden=2 apparmor=1 lsm=lockdown,yama,apparmor systemd.unified_cgroup_hierarchy=1 add_efi_memmap initrd=\intel-ucode.img"
    submenuentry "Boot - terminal" {
        add_options "systemd.unit=multi-user.target"
    }
}

menuentry "Arch Linux - Low Latency" {
    icon     /EFI/refind/themes/refind-dreary/icons/os_arch.png
    volume   "Arch Linux"
    loader   /vmlinuz-linux-xanmod-cacule
    initrd   /initramfs-linux-xanmod-cacule.img
    options  "rd.luks.name=$(blkid /dev/sda2 | cut -d " " -f2 | cut -d '=' -f2 | sed 's/\"//g')=crypt root=/dev/mapper/crypt rootflags=subvol=@ rw quiet nmi_watchdog=0 kernel.unprivileged_userns_clone=0 net.core.bpf_jit_harden=2 apparmor=1 lsm=lockdown,yama,apparmor systemd.unified_cgroup_hierarchy=1 add_efi_memmap initrd=\intel-ucode.img"
    submenuentry "Boot - terminal" {
        add_options "systemd.unit=multi-user.target"
    }
}

include themes/refind-dreary/theme.conf
EOF

###############################
###############################

# Edit refing-btrfs

sed -i 's/^count.*/count = "inf"/' /mnt/etc/refind-btrfs.conf
sed -i 's/^include_sub_menus.*/include_sub_menus = true/' /mnt/etc/refind-btrfs.conf

# Add snap-pac for automatic pre/post backups for package install/uninstalls/updates

arch-chroot /mnt /bin/bash -c "pacman --noconfirm -S snap-pac"


# Make scripts to start service & setup snapshots

cat << EOF >> /mnt/home/$USER/init.sh

sudo umount /.snapshots
sudo rm -r /.snapshots
sudo snapper -c root create-config /
sudo mount -a
sudo chmod 750 -R /.snapshots
sudo chmod a+rx /.snapshots
sudo chown :wheel /.snapshots
sudo snapper -c root create --description "Fresh Install"
sudo sed -i 's/^TIMELINE_MIN_AGE.*/TIMELINE_MIN_AGE="1800"/' /etc/snapper/configs/root && \
sudo sed -i 's/^TIMELINE_LIMIT_HOURLY.*/TIMELINE_LIMIT_HOURLY="0"/' /etc/snapper/configs/root && \
sudo sed -i 's/^TIMELINE_LIMIT_DAILY.*/TIMELINE_LIMIT_DAILY="7"/' /etc/snapper/configs/root && \
sudo sed -i 's/^TIMELINE_LIMIT_WEEKLY.*/TIMELINE_LIMIT_WEEKLY="0"/' /etc/snapper/configs/root && \
sudo sed -i 's/^TIMELINE_LIMIT_MONTHLY.*/TIMELINE_LIMIT_MONTHLY="0"/' /etc/snapper/configs/root && \
sudo sed -i 's/^TIMELINE_LIMIT_YEARLY.*/TIMELINE_LIMIT_YEARLY="0"/' /etc/snapper/configs/root
sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer
sudo systemctl disable --now systemd-timesyncd.service
sudo systemctl mask systemd-rfkill.socket systemd-rfkill.service
sudo systemctl enable --now NetworkManager 
sudo systemctl enable --now NetworkManager-wait-online
sudo systemctl enable --now NetworkManager-dispatcher
sudo systemctl enable --now nftables
sudo systemctl enable --now opennic-up.timer
sudo systemctl enable --now sshd 
sudo systemctl enable --now chronyd
sudo systemctl enable --now reflector
sudo systemctl enable --now apparmor 
sudo systemctl enable --now sshguard
sudo systemctl enable --now tlp 
sudo systemctl enable --now memavaild 
sudo systemctl enable --now haveged 
sudo systemctl enable --now irqbalance 
sudo systemctl enable --now prelockd 
sudo systemctl enable --now systemd-swap 
sudo systemctl enable --now nohang-desktop 
sudo systemctl enable --now auto-cpufreq 
sudo systemctl enable --now dbus-broker
sudo systemctl enable --now postgresql
sudo systemctl enable --now refind-btrfs
systemctl --user start psd
sudo systemctl enable --now gdm
rm /home/$USER/init.sh
EOF

chown $USER /mnt/home/$USER/init.sh

### Step 10 - Reboot into your new install






#DESMONTAR Y REINICIAR
umount -R /mnt
swapoff -a
      clear 
      echo "Arch Linux Instalado"               
      sleep 3
reboot




