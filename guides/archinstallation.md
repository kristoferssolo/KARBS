# Arch Linux Installation Guide

<!-- toc -->

- [Pre-installation](#pre-installation)
  * [Update the system clock](#update-the-system-clock)
  * [Partition the disks](#partition-the-disks)
    + [Example layout](#example-layout)
  * [Format the partitions](#format-the-partitions)
  * [Mount the file systems](#mount-the-file-systems)
    + [Flag explanation](#flag-explanation)
- [Installation](#installation)
  * [Install essential packages](#install-essential-packages)
- [Configure the system](#configure-the-system)
  * [Fstab](#fstab)
  * [Chroot](#chroot)
  * [Time zone](#time-zone)
  * [Localization](#localization)
  * [Variations](#variations)
  * [Boot loader](#boot-loader)
    + [For BIOS systems](#for-bios-systems)
    + [For UEFI systems](#for-uefi-systems)
  * [Root password](#root-password)
  * [Add user(s)](#add-users)
  * [Configure sudo](#configure-sudo)
  * [Package manager](#package-manager)
  * [Network configuration](#network-configuration)
  * [Reboot the system](#reboot-the-system)
- [Post-installation configuration](#post-installation-configuration)
  * [Desktop Environment](#desktop-environment)
  * [Display Login Manager](#display-login-manager)
    + [KDE](#kde)
    + [GNOME](#gnome)
  * [Wi-Fi](#wi-fi)
  * [Optional](#optional)
    + [Reflector](#reflector)
    + [Paru](#paru)

<!-- tocstop -->

## Pre-installation

### Update the system clock

```shell
timedatectl set-ntp true
```

### Partition the disks

Partition your hard drive with [cfdisk](https://man.archlinux.org/man/cfdisk.8).\
It can be *sda*, *sdb*, *sdc*, *nvme0n1* or other drive names.

```shell
cfdisk /dev/sdx
```

Chose `dos` if available.

#### Example layout

*   `boot` - 256M
*   `swap` - (optional, recommended size is the size of RAM or half of it)
*   `root` - 30GB (10GB for root in VM will be enough, but on physical hardware 30GB-50GB is recommended)
*   `home` - rest of the drive

### Format the partitions

```shell
mkfs.fat -F 32 /dev/sdx1           # boot partition
fatlabel /dev/vda1 boot

mkswap -L swap /dev/sdx2           # swap partition, if created
mkfs.ext4 -L root /dev/sdx3        # root partition
mkfs.ext4 -L root /dev/sdx4        # home partition
```

You can replace [ext4](https://wiki.archlinux.org/title/ext4) with [btrfs](https://wiki.archlinux.org/title/Btrfs).

### Mount the file systems

```shell
mount -L root /mnt
mount -Lm boot /mnt/boot
mount -Lm home /mnt/home
swapon /dev/sdx2
```

#### Flag explanation

*   `-L, --label` - Mount the partition that has the specified label.
*   `-m, --mkdir` - Allow to make a target directory (mountpoint) if it does not exist yet.

Mount additional drives/partitions if exist and needed with:

```shell
mount /dev/sdy /mnt/exampleFolder
```

## Installation

### Install essential packages

Use the [pacstrap](https://man.archlinux.org/man/pacstrap.8) script to install the base package, Linux [kernel](https://wiki.archlinux.org/title/Kernel) and firmware for common hardware:

```shell
pacstrap /mnt base base-devel linux linux-firmware
```

## Configure the system

### Fstab

Generate an [fstab](https://wiki.archlinux.org/title/Fstab) file:

```shell
genfstab -U /mnt >> /mnt/etc/fstab
```

### Chroot

[Change root](https://wiki.archlinux.org/title/Chroot) into the new system:

```shell
arch-chroot /mnt
```

### Time zone

Set the [time zone](https://wiki.archlinux.org/title/System_time#Time_zone):

```shell
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
```

Run [hwclock](https://man.archlinux.org/man/hwclock.8) to generate `/etc/adjtime`:

```shell
hwclock --systohc
```

### Localization

Install any text editor ([vim](https://wiki.archlinux.org/title/Vim), [nano](https://wiki.archlinux.org/title/Nano)) of your choice.

```shell
pacman -S vim
```

Edit `/etc/locale.gen` and uncomment `en_US.UTF-8 UTF-8` and other needed locales.

```shell
vim /etc/locale.gen
```

Generate the locales by running:

```shell
locale-gen
```

Create the [locale.conf](https://man.archlinux.org/man/locale.conf.5) file, and set the LANG variables accordingly:

```shell
vim /etc/locale.conf
```

```config
LANG=en_US.UTF-8
```

### Variations

If you want to specify which time, number, etc. formats to use, you can do so using the following variables:

*   `LANG`
*   `LANGUAGE`
*   `LC_ADDRESS`
*   `LC_COLLATE`
*   `LC_CTYPE`
*   `LC_IDENTIFICATION`
*   `LC_MEASUREMENT`
*   `LC_MESSAGES`
*   `LC_MONETARY`
*   `LC_NAME`
*   `LC_NUMERIC`
*   `LC_PAPER`
*   `LC_TELEPHONE`
*   `LC_TIME`

For example:

```config
LC_ADDRESS=lv_LV.UTF-8
LC_IDENTIFICATION=lv_LV.UTF-8
LC_MEASUREMENT=lv_LV.UTF-8
LC_MONETARY=lv_LV.UTF-8
LC_NUMERIC=lv_LV.UTF-8
LC_PAPER=lv_LV.UTF-8
LC_TELEPHONE=lv_LV.UTF-8
LC_TIME=lv_LV.UTF-8
```

### Boot loader

First install `grub` and `os-prober` (to detect other operating systems installed):

```shell
pacman -S grub os-prober efibootmgr
```

If `ls /sys/firmware/efi/efivars` lists files, you have a UEFI system.

```shell
ls /sys/firmware/efi/efivars
```

Install grub:

#### For BIOS systems

```shell
grub-install --recheck /dev/sdx
```

#### For UEFI systems

```shell
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
```

To enable os-prober uncomment `GRUB_DISABLE_OS_PROBER=false` in `/etc/default/grub` file:
To enable os-prober, `GRUB_DISABLE_OS_PROBER=false` in `/etc/default/grub`:

```shell
vim /etc/default/grub
```

Must be at the end of the file.

Make config

```shell
grub-mkconfig -o /boot/grub/grub.cfg
```

### Root password

Set the root password:

```shell
passwd
```

### Add user(s)

Create a regular user and password. Replace *username* with your desired username.

```shell
useradd -mG username wheel
passwd username
```

### Configure sudo

Uncomment `%whell ALL=(ALL:ALL) ALL` or `%whell ALL=(ALL:ALL) NOPASSWD: ALL` for no password option:

```shell
vim /etc/sudoers
```

### Package manager

Enable several handy features of [pacman](https://man.archlinux.org/man/pacman.8) package manager:

```shell
vim /etc/pacman.conf
```

Uncomment/add the following lines:

```config
Color                             # Automatically enable colors only when pacman’s output is on a tty.
VerbosePkgLists                   # Displays name, version and size of target packages formatted as a table for upgrade, sync and remove operations.
ParallelDownloads = 12            # Specifies number of concurrent download streams. The value needs to be a positive integer. The number of CPU threads on your computer is recommended.
ILoveCandy                        # Otherwise what is the point of using Arch Linux at all?

[multilib]                        # Enable 32bit repository (required by steam)
Include = /etc/pacman.d/mirrorlist
```

### Network configuration

Create the [hostname](https://wiki.archlinux.org/title/Network_configuration#Set_the_hostname) file and enter machine name.
Replace *myhostname* with a name that will be seen by other devices on the same network.

```shell
vim /etc/hostname
```

```config
myhostname
```

Add matching entries to hosts:

```shell
vim /etc/hosts
```

```config
127.0.0.1   localhost
::1         localhost
127.0.1.1   myhostname.localdomain myhostname
```

If the system has a permanent IP address, it should be used instead of `127.0.1.1`.

Install and enable [networkmanager](https://wiki.archlinux.org/title/NetworkManager) and/or [bluez](http://www.bluez.org/):

```shell
pacman -Syu networkmanager bluez wget git
systemctl enable NetworkManager
systemctl enable bluetooth
```

### Reboot the system

```shell
exit                # exit chroot environment
umount -R /mnt
reboot
```

## Post-installation configuration

Once shutdown is complete, remove your installation media.
If all went well, you should boot into your new system. Log in as your root to complete the post-installation configuration.
See [Arch linux's general recommendations](https://wiki.archlinux.org/title/General_recommendations) for system management directions and post-installation tutorials.

### Desktop Environment

Install your favorite desktop environment, for example [KDE](https://kde.org/), [GNOME](https://www.gnome.org) or other:

```shell
pacman -S plasma kde-applications
```

```shell
pacman -S gnome
```

### Display Login Manager

Enable login manager at launch.

#### KDE

```shell
sudo systemctl enable sddm
sudo systemctl start sddm
```

#### GNOME

```shell
sudo systemctl enable gdm
sudo systemctl start gdm
```

### Wi-Fi

To connect to Wi-Fi run:

```shell
nmcli dev wifi list               # list all available networks
nmcli dev wifi -a connect "name"  # connect to network
```

### Optional

#### Reflector

Install [reflector](https://wiki.archlinux.org/title/reflector) for better Arch Linux mirror setup:

```shell
sudo pacman -S reflector
sudo reflector --sort rate --protocol https --save /etc/pacman.d/mirrorlist --latest 200
```

Configure [reflector](https://wiki.archlinux.org/title/reflector) to run on startup:

```shell
sudo systemctl start reflector.timer
sudo systemctl enable reflector.timer
sudo vim /etc/xdg/reflector/reflector.conf
```

Uncomment/add the following lines:

```config
--save /etc/pacman.d/mirrorlist
--protocol https
--sort rate
--latest 200
```

#### Paru

Install [paru](https://github.com/Morganamilo/paru) - [AUR helper](https://wiki.archlinux.org/title/AUR_helpers):

```shell
git clone https://aur.archlinux.org/paru-bin
cd paru-bin
makepkg -si
```
