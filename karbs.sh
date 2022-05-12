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

FILE=pkg-files/"$size"-pkgs.txt
if [[ -f "$FILE" ]]; then
  paru -Syu --noconfirm --needed archlinux-keyring - < /pkg-files/"$size"-pkgs.txt
else
  curl -LO https://raw.githubusercontent.com/kristoferssolo/karbs/main/pkg-files/"$size"-pkgs.txt
  paru -Syu --noconfirm --needed archlinux-keyring - < "$size"-pkgs.txt
  rm "$size"-pkgs.txt
fi

mkdir -p ~/repos ~/Downloads ~/Documents ~/Videos ~/Music ~/Pictures/screenshots
git clone https://github.com/kristoferssolo/solorice ~/repos/solorice

cp -rf ~/repos/solorice/.config ~
rm -rf ~/.config/awesome/desktop
cp -rf ~/repos/solorice/.local ~
mv ~/.config/zsh/.zshenv ~
git clone https://github.com/streetturtle/awesome-wm-widgets ~/.config/awesome/awesome-wm-widgets


