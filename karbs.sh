#!/bin/sh

git clone https://aur.archlinux.org/paru
cd paru
makepkg -si
cd ..
rm -rf paru

paru -S archlinux-keyring
paru -Syu --noconfirm --needed - < pkg-files/minimal.txt

cp -rf .config ~
cp -rf .local ~
cp -f .zshenv ~
git clone https://github.com/streetturtle/awesome-wm-widgets ~/.config/awesome/awesome-wm-widgets

mkdir ~/Pictures ~/Documents ~/Videos ~/Downloads ~/Music