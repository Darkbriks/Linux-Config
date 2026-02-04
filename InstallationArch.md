# Etapes d'installation d'Arch Linux (sans utiliser archinstall)

## Keyboard layout and fonts

```bash
loadkeys fr-latin9
setfont ter-132b
```

## Network

```bash
ip link # pour voir les interfaces réseau disponibles
```

Si ce n'est pas le cas, mettre l'interface a `up`:

```bash
ip link set <interface> up
```

### Wifi

```bash
iwctl
device list # pour voir les interfaces wifi disponibles
device <interface> set-property Powered on
station <interface> scan
station <interface> get-networks
station <interface> connect <SSID>
station <interface> show
```

Vérifier la connexion:

```bash
ping ping.archlinux.org
```

## Verification de l'heure

```
timedatectl
```

## Partitionnement (BTRFS)

Schema de partitionnement:
```
/dev/nvme0n1p1  EFI    512M   FAT32
/dev/nvme0n1p2  ROOT   reste  BTRFS
```

Subvolumes:
```
@        → /
@home    → /home
@log     → /var/log
@pkg     → /var/cache/pacman/pkg
@snap    → /.snapshots
```

Utilisation de `fdisk` pour s'assurer que la table de partition est en GPT et créer les partitions:

```bash
fdisk /dev/<disk>
g # pour créer une table de partition GPT
n # pour créer une nouvelle partition
    Partition number: 1
    First sector: (default)
    Last sector: +512M
t # pour changer le type de la partition
    Partition number: 1
    Type: EFI System (code ef00)
n # pour créer une nouvelle partition
    Partition number: 2
    First sector: (default)
    Last sector: (default)
p # pour afficher la table de partition
w # pour écrire les changements sur le disque
```

Formater les partitions:

```bash
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.btrfs /dev/nvme0n1p2
```

Montage temporaire pour créer les subvolumes:

```bash
mount /dev/nvme0n1p2 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@pkg
umount /mnt
```

Montage des subvolumes:

```bash
mkdir -p /mnt/{boot,home,.snapshots,var/log,var/cache/pacman/pkg}

mount -o subvol=@,compress=zstd,noatime /dev/nvme0n1p2 /mnt
mount -o subvol=@home,compress=zstd,noatime /dev/nvme0n1p2 /mnt/home
mount -o subvol=@snapshots,compress=zstd,noatime /dev/nvme0n1p2 /mnt/.snapshots
mount -o subvol=@log,compress=zstd,noatime /dev/nvme0n1p2 /mnt/var/log
mount -o subvol=@pkg,compress=zstd,noatime /dev/nvme0n1p2 /mnt/var/cache/pacman/pkg

mount /dev/nvme0n1p1 /mnt/boot
```

## Installation du système de base

```bash
pacstrap /mnt base linux linux-firmware <amd|intel>-ucode btrfs-progs grub efibootmgr iw iwd networkmanager nano sudo
```

## Configuration du système

```bash
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab # pour vérifier que le fichier fstab est correct
arch-chroot /mnt
```

### Timezone

```bash
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc
```

### Locales

```bash
nano /etc/locale.gen # décommenter la ligne fr_FR.UTF-8 UTF-8
locale-gen
```

```bash
nano /etc/locale.conf
# ajouter les lignes suivantes:
LANG=fr_FR.UTF-8
LC_MESSAGES=FR.UTF-8
```

```bash
nano /etc/vconsole.conf
# ajouter les lignes suivantes:
KEYMAP=fr-latin9
FONT=ter-132b
```

### Hostname

```bash
echo <hostname> > /etc/hostname
```

### Mot de passe root

```bash
passwd
```

### Bootloader

#### GRUB

Choix par défaut, si le système est installé en UEFI:

```bash
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

## Exit chroot et redémarrer

```bash
exit
umount -R /mnt
reboot
```

## Après le redémarrage, se connecter en tant que root

Activer NetworkManager:

```bash
systemctl enable --now NetworkManager
```

Si le wifi ne se connecte pas automatiquement, utiliser `iwctl` pour se connecter manuellement.

```bash
ping ping.archlinux.org # pour vérifier la connexion internet
```

## Services supplémentaires

```bash
# activer le service de gestion de l'heure
systemctl enable --now systemd-timesyncd
```

## Ajouter un utilisateur non-root

```bash
useradd -m -G wheel -s /bin/bash <username>
passwd <username>
```

Ajouter les permissions sudo pour les utilisateurs du groupe wheel:

```bash
EDITOR=nano visudo
# décommenter la ligne suivante:
%wheel ALL=(ALL) ALL
```

Tester les permissions sudo:

```bash
su - <username>
sudo ls -la /
exit
```

## Pacman configuration

```bash
nano /etc/pacman.conf
# décommenter la ligne suivante pour activer les couleurs dans la sortie de pacman:
Color
# (optionnel) decommenter les deux lignes suivantes pour activer le depot multilib (pour les applications 32 bits sur un système 64 bits):
[multilib]
Include = /etc/pacman.d/mirrorlist
```

## KDE Plasma

### Meta packages

Installe l'environnement de bureau KDE Plasma et un certain nombre d'applications KDE.
Utile pour aller plus vite, mais moins de contrôle sur les applications installées.

```bash
pacman -S plasma-meta
```

### Installation minimale

Installe uniquement l'environnement de bureau KDE Plasma, sans les applications KDE.

```bash
pacman -S plasma-desktop konsole kate
```

## SDDM

```bash
pacman -S sddm
systemctl enable --now sddm
localectl --no-convert set-x11-keymap fr pc104 .oss
reboot
```
