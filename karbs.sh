#!/bin/sh
# Kristofers Auto Rice Boostrapping Script (KARBS)
# by Kristofers Solo
# License: GNU GPLv3

echo 'Choose display server (X11 / Wayland)[1/2]: '
read -r USER_INPUT


# Get display server type from user
if [ "$USER_INPUT" = 1 ]; then
    DISPLAY_SERVER="X11"
elif [ "$USER_INPUT" = 2 ]; then
    DISPLAY_SERVER="wayland"
else
    echo "Wrong input. Please try again."
    exit
fi


# Install paru
if pacman -Q paru; then
    :
else
    sudo pacman -S --noconfirm rust-src
    git clone 'https://aur.archlinux.org/paru-bin'
    cd paru-bin || exit
    makepkg -si
    cd ..
    rm -rf paru-bin
fi

FILE="pkg-files/$DISPLAY_SERVER-pkgs.txt"

if [ -f "$FILE" ]; then
    paru -Syu --noconfirm --needed - < "pkg-files/$DISPLAY_SERVER-pkgs"
else
    curl -LO "https://raw.githubusercontent.com/kristoferssolo/karbs/main/pkg-files/$DISPLAY_SERVER-pkgs"
    paru -Syu --noconfirm --needed - < "$DISPLAY_SERVER-pkgs"
    rm -f "$DISPLAY_SERVER-pkgs"
fi

mkdir -p "$HOME/{repos,Downloads,Documents,Videos,Music,Pictures/screenshots}"
git clone 'https://github.com/kristoferssolo/solorice' "$HOME/repos/solorice"

cp -raf "$HOME/repos/solorice/.config" "$HOME"
cp -raf "$HOME/repos/solorice/.local" "$HOME"
ln -sf "$HOME/.config/zsh/.zshenv" "$HOME"
sudo chsh -s /bin/zsh

if [ $DISPLAY_SERVER = "wayland" ]; then
    rm -rf "$HOME/.config/{awesome,picom,sx,zsh/.zprofile-X11}"
    mv "$HOME/.config/zsh/zprofile-wayland" "$HOME/.config/zsh/.zprofile"
    Hyprland
else
    rm -rf "$HOME/.config/{hypr,waybar,zsh/.zprofile-wayland}"
    mv "$HOME/.config/zsh/zprofile-X11" "$HOME/.config/zsh/.zprofile"
    git clone 'https://github.com/streetturtle/awesome-wm-widgets' "$HOME/.config/awesome/awesome-wm-widgets"
    echo -e "\n\n\033[1;31mFor weather widget to work, enter API-key from https://openweathermap.org, latitude and longitude in '~/.config/awesome/weather' file, each on seperate line.\033[0m"
    echo "API-key"
    echo "latitude"
    echo "longitude"
    echo -e "\nEverything else is ready to go. You can run 'sx' or reboot."
fi
