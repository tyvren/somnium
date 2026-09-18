#!/bin/bash

clear

IDLE_CONFIG="$HOME/.config/hypr/hypridle.conf"

header() {
  gum style --foreground 99 --border double --align center --margin "1 2" --padding "2 4" \
    "$1"
}

header "Choose display dim time (minutes)"
chosen_dimtime=$(printf "5\n10\n15\n30\n" | gum choose --limit=1)
clear

header "Choose lock time (minutes)"
chosen_locktime=$(printf "5\n10\n15\n30\n" | gum choose --limit=1)
clear

header "Choose display sleep time (minutes)"
chosen_displaytime=$(printf "10\n15\n30\n" | gum choose --limit=1)
clear

header "Enable computer sleep?"
enable_sleep_choice=$(printf "Yes\nNo" | gum choose --limit=1)
clear

if [ "$enable_sleep_choice" = "Yes" ]; then
  enable_sleep=true
  header "Choose computer sleep time (minutes)"
  chosen_sleeptime=$(printf "15\n30\n45\n60\n" | gum choose --limit=1)
else
  enable_sleep=false
fi
clear

dim_seconds=$((chosen_dimtime * 60))
lock_seconds=$((chosen_locktime * 60))
display_seconds=$((chosen_displaytime * 60))
sleep_seconds=$((chosen_sleeptime * 60))

cat >"$IDLE_CONFIG" <<-EOF
general {
  lock_cmd = qs ipc call lockscreen lock
  before_sleep_cmd = loginctl lock-session
  after_sleep_cmd = hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })' 
}

listener {
  timeout = $dim_seconds
  on-timeout = brightnessctl -s set 10
  on-resume = brightnessctl -r
}

listener {
  timeout = $lock_seconds
  on-timeout = loginctl lock-session
}

listener {
  timeout = $display_seconds
  on-timeout = hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })' 
  on-resume = hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })'
}
EOF

if $enable_sleep; then
  cat >>"$IDLE_CONFIG" <<-EOF
listener {
  timeout = $sleep_seconds
  on-timeout = systemctl suspend
}
EOF
else
  cat >>"$IDLE_CONFIG" <<-'EOF'
# listener {
#   timeout = 1800
#   on-timeout = systemctl suspend
# }
EOF
fi
