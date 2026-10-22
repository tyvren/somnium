#!/bin/bash

IMAGE_PATH="${1#file://}"
IMAGE_PATH="$(printf '%b' "${IMAGE_PATH//%/\\x}")"

cp "$IMAGE_PATH" "$HOME/.face"

qs kill && qs -d

sleep 2

notify-send "Shell reloaded - User icon updated"
