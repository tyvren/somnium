INSTALL_DIR="$HOME/.config/somnium"

config_setup() {
  log_info "Copying Somnium theme files..."
  cp -r "$INSTALL_DIR/themes/Somnium/." "$HOME/.config/"

  log_info "Copying config files..."
  cp -r "$INSTALL_DIR/config/"* "$HOME/.config/"

  log_info "Cloning wallpapers repo..."
  git clone --depth 1 https://github.com/tyvren/somnium-wallpapers.git /tmp/wallpapers
  log_info "Copying wallpapers..."
  rm -rf /tmp/wallpapers/.git
  rm -rf /tmp/wallpapers/README.md
  cp -r /tmp/wallpapers/. "$INSTALL_DIR/wallpapers/"
  rm -rf /tmp/wallpapers

  chmod +x "$HOME/.config/somnium/modules/diskmanagement/"*
  chmod +x "$HOME/.config/somnium/modules/packages/"*
  chmod +x "$HOME/.config/somnium/modules/quickconfig/"*
  chmod +x "$HOME/.config/somnium/modules/quickshell/"*
  chmod +x "$HOME/.config/somnium/modules/style/"*
  chmod +x "$HOME/.config/somnium/modules/updates/"*

  log_success "Configuration setup complete"
}

setup_greetd() {
  log_info "Setting up greetd configuration..."
  sudo mkdir -p /etc/greetd

  log_info "Setting up greeter files..."
  sudo mkdir -p /usr/local/share/somnium
  sudo cp -r "$INSTALL_DIR/greeter" "/usr/local/share/somnium"

  cat <<'EOF' | sudo tee /etc/greetd/config.toml >/dev/null
[terminal]
vt = 1

[default_session]
command = "start-hyprland -- -c /etc/greetd/hyprland.lua"
user = "greeter"
EOF

  cat <<'EOF' | sudo tee /etc/greetd/hyprland.lua >/dev/null
hl.config({
  animations = {
    enabled = false,
  },

  misc = {
    disable_hyprland_logo = true,
    force_default_wallpaper = 0,
    disable_splash_rendering = true,
    background_color = 0x1e1e2e,
  },
})

hl.on("hyprland.start", function()
  hl.exec_cmd("qs -p /usr/local/share/somnium/greeter/greeter.qml")
end)
EOF

  sudo chmod 644 /etc/greetd/config.toml
  sudo chmod 644 /etc/greetd/hyprland.lua

  log_success "greetd setup complete"
}

setup_limine() {
  LIMINE_CONF="/boot/EFI/BOOT/limine.conf"
  LIMINE_DIR="/boot/EFI/Linux"
  WALLPAPER_SRC="$INSTALL_DIR/wallpapers/Somnium/somnium.png"
  sudo cp "$WALLPAPER_SRC" "$LIMINE_DIR/"
  sudo sed -i '/^wallpaper:/d' "$LIMINE_CONF"
  sudo sed -i '/^wallpaper_style:/d' "$LIMINE_CONF"
  sudo sed -i '/^timeout:/a wallpaper: boot():/EFI/Linux/somnium.png\nwallpaper_style: stretched' "$LIMINE_CONF"
}

setup_quickconfig_alias() {
  SHELL_RC="$HOME/.bashrc"
  FUNCTION_NAME="config"
  SCRIPT_PATH="$INSTALL_DIR/modules/quickconfig/quickconfig.sh"
  FUNCTION_DEF=$(
    cat <<EOF
# quickconfig CLI
$FUNCTION_NAME() {
    bash "$SCRIPT_PATH"
}
EOF
  )
  if ! grep -q "$FUNCTION_NAME()" "$SHELL_RC"; then
    echo "$FUNCTION_DEF" >>"$SHELL_RC"
    log_success "Alias function '$FUNCTION_NAME' added to $SHELL_RC"
  else
    log_info "Function '$FUNCTION_NAME' already exists in $SHELL_RC"
  fi
}
