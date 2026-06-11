#!/bin/sh

# Merge Xresources configurations (Colors, Fonts, DPI settings)
if [ -f "$HOME/.Xresources" ]; then
    xrdb -merge "$HOME/.Xresources"
fi

# Start picom
picom -b

# Finally, launch your desktop
exec dbus-run-session i3
