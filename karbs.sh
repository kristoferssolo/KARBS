#!/bin/sh

echo "Choose installation size: minimal or full"
read size

if pacman -Q paru; then echo
else
  git clone https://aur.archlinux.org/paru
  cd paru
  makepkg -si
  cd ..
  rm -rf paru
fi

paru -Syu --noconfirm --needed archlinux-keyring - < /pkg-files/"$size"-pkgs.txt


cp -rf .config ~
cp -rf .local ~
cp -f .cofig/zsh/.zshenv ~
git clone https://github.com/streetturtle/awesome-wm-widgets ~/.config/awesome/awesome-wm-widgets

mkdir ~/Pictures ~/Documents ~/Videos ~/Downloads ~/Music
