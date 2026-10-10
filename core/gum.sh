install_gum() {
  sudo pacman -S gum --noconfirm
}

header() {
  gum style \
    --foreground 37 \
    --border double \
    --border-foreground 69 \
    --padding "0 2" \
    --margin "1 0" \
    --align center \
    "
  ▄▄▄▄▄                                         
 ██▀▀▀▀█▄                                       
 ▀██▄   ▀       ▄        ▄     ▀▀       ▄       
   ▀██▄▄  ▄███▄ ███▄███▄ ████▄ ██ ██ ██ ███▄███▄
 ▄   ▀██▄ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██
 ▀██████▀ ▀███▀ ██ ██ ▀█ ██ ▀█ ██ ▀███▀ ██ ██ ▀█"
}

spinner() {
  local title="$1"
  shift
  gum spin --spinner dot --title "$title" --show-error -- "$@" >/dev/null 2>&1
}

prompt_yes_no() {
  local prompt="$1"
  gum confirm "$prompt" && return 0 || return 1
}
