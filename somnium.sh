#!/bin/bash
set -e

for file in ./core/*.sh; do
  source "$file"
done

install_gum
create_log
header

log_step "Getting username"
get_username

log_step "Updating system packages"
spinner "Updating system..." sudo pacman -Syu --noconfirm

log_step "Installing yay AUR helper"
install_yay

log_step "Setting up default configuration"
config_setup

log_step "Configuring hardware type (Laptop/Desktop)"
configure_hardware_type

log_step "Configuring GPU (Nvidia/AMD)"
configure_gpu

log_step "Installing system utilities"
install_packages "${system_utils[@]}"

log_step "Installing file and disk management utilities"
install_packages "${files_disk_management[@]}"

log_step "Installing network and bluetooth utilities"
install_packages "${network_bluetooth[@]}"

log_step "Enabling iwd for wifi backend"
enable_iwd

log_step "Installing desktop environment packages"
install_packages "${desktop_environment[@]}"

log_step "Installing development tools"
install_packages "${development[@]}"

log_step "Installing terminal emulator and shell tools"
install_packages "${terminal_shell[@]}"

log_step "Installing LazyVim"
install_lazyvim

log_step "Installing theme icons, cursors and fonts"
install_packages "${themes_fonts_packages[@]}"

log_step "Installing default applications"
install_packages "${default_packages[@]}"

log_step "Installing Hyprland packages"
install_packages "${hypr_packages[@]}"

log_step "Enabling system services"
enable_service "networkmanager"
enable_service "bluetooth.service"
enable_service "cups"
enable_service "lm_sensors"
enable_service "paccache.timer"
enable_service "hyprpolkitagent"
enable_service "power-profiles-daemon.service"

log_step "Enabling user services"
enable_user_service "app-com.mitchellh.ghostty.service"

log_step "Setting up somnium bootloader logo"
enable_plymouth

log_step "Setting up quickconfig bash alias"
setup_quickconfig_alias

log_step "Configuring Hyprland login settings"
hyprland_autologin

log_success "Somnium installation complete!"
log_info "Please reboot for all changes to take effect."

if prompt_yes_no "Reboot now?"; then
  clear
  spinner "Rebooting system..." sudo systemctl reboot --no-wall 2>/dev/null || reboot 2>/dev/null
fi
