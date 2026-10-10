#!/bin/bash
set -e
print_logo() {
  cat <<"EOF"
  ▄▄▄▄▄                                         
 ██▀▀▀▀█▄                                       
 ▀██▄   ▀       ▄        ▄     ▀▀       ▄       
   ▀██▄▄  ▄███▄ ███▄███▄ ████▄ ██ ██ ██ ███▄███▄
 ▄   ▀██▄ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██
 ▀██████▀ ▀███▀ ██ ██ ▀█ ██ ▀█ ██ ▀███▀ ██ ██ ▀█
EOF
}
clear
print_logo

sudo pacman -Sy --noconfirm --needed git

INSTALL_DIR="$HOME/.config/somnium"
echo -e "\nCloning somnium"
git clone https://github.com/tyvren/somnium.git "$INSTALL_DIR"

echo "Starting Somnium installation..."
cd "$INSTALL_DIR"
chmod +x ./somnium.sh
source ./somnium.sh
