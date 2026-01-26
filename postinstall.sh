#!/usr/bin/env bash
set -e

echo "=== Arch post-install : packages & services ==="

# -------------------------------------------------
# Vérifications de base
# -------------------------------------------------
if ! command -v pacman >/dev/null; then
  echo "pacman introuvable, abort."
  exit 1
fi

if ! command -v yay >/dev/null; then
  echo "yay non installé, installation..."
  pacman -S --needed --noconfirm git base-devel
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
fi

# -------------------------------------------------
# Paquets core / système
# -------------------------------------------------
pacman -S --needed --noconfirm \
  base-devel \
  bash-completion \
  pacman-contrib \
  reflector \
  rebuild-detector \
  sudo \
  man-db man-pages tldr \
  which wget curl rsync \
  nano less \
  plocate \
  logrotate \
  ntp \
  openssh \
  firewalld

# -------------------------------------------------
# Réseau & hardware
# -------------------------------------------------
pacman -S --needed --noconfirm \
  networkmanager \
  networkmanager-openvpn \
  networkmanager-openconnect \
  bluez bluez-utils bluedevil \
  modemmanager \
  ethtool \
  inetutils \
  usbutils \
  hwinfo inxi dmidecode \
  smartmontools \
  upower power-profiles-daemon

# -------------------------------------------------
# Audio / vidéo
# -------------------------------------------------
pacman -S --needed --noconfirm \
  pipewire pipewire-alsa pipewire-pulse pipewire-jack \
  wireplumber \
  pavucontrol \
  alsa-utils alsa-plugins alsa-firmware \
  sof-firmware \
  rtkit

# -------------------------------------------------
# Graphique / GPU / Vulkan
# -------------------------------------------------
pacman -S --needed --noconfirm \
  mesa-utils \
  vulkan-radeon \
  vulkan-headers \
  vulkan-validation-layers \
  xf86-video-amdgpu \
  xf86-input-libinput \
  xorg-server xorg-xinit \
  xorg-xrandr xorg-xinput xorg-xkill xorg-xdpyinfo

# -------------------------------------------------
# KDE / Plasma usuel
# -------------------------------------------------
pacman -S --needed --noconfirm \
  dolphin dolphin-plugins \
  konsole kate \
  gwenview okular spectacle ark \
  plasma-nm plasma-pa plasma-firewall \
  kdeconnect \
  kio-extras kio-admin \
  kde-gtk-config \
  breeze-gtk \
  sddm-kcm \
  kinfocenter

# -------------------------------------------------
# Fonts
# -------------------------------------------------
pacman -S --needed --noconfirm \
  ttf-cascadia-code-nerd ttf-cascadia-mono-nerd \
  ttf-jetbrains-mono-nerd \
  ttf-anonymouspro-nerd \
  ttf-nerd-fonts-symbols \
  ttf-ubuntu-nerd ttf-ubuntu-mono-nerd \
  noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra \
  ttf-dejavu ttf-liberation \
  ttf-meslo-nerd

# -------------------------------------------------
# Développement
# -------------------------------------------------
pacman -S --needed --noconfirm \
  git cmake gdb valgrind ninja \
  python python-packaging python-defusedxml \
  perl \
  texinfo doxygen

# -------------------------------------------------
# Filesystems & outils disque
# -------------------------------------------------
pacman -S --needed --noconfirm \
  btrfs-progs snapper \
  dosfstools ntfs-3g exfatprogs \
  e2fsprogs xfsprogs jfsutils \
  lvm2 mdadm \
  cryptsetup \
  gparted

# -------------------------------------------------
# Snapshots & boot
# -------------------------------------------------
yay -S --needed --noconfirm \
  snap-pac \
  grub-btrfs

# -------------------------------------------------
# Applications AUR
# -------------------------------------------------
yay -S --needed --noconfirm \
  brave-bin \
  discord \
  steam \
  obsidian \
  jetbrains-toolbox \
  protonup-qt

# -------------------------------------------------
# Services systemd
# -------------------------------------------------
systemctl enable --now \
  NetworkManager \
  bluetooth \
  firewalld \
  ntpd \
  power-profiles-daemon \
  snapper-timeline.timer \
  snapper-cleanup.timer \
  grub-btrfs.path \
  sddm

echo "=== Installation terminée ==="
echo "Un redémarrage est recommandé."
