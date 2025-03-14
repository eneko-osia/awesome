#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

# set liquid cooler rgb colors
liquidctl --match Corsair set logo color alert 00ff00 ffff00 ff0000
liquidctl --match Corsair set fan speed  20 50  30 70  40 100

# set display mode
xrandr --output HDMI-A-1 --mode 1920x1080 --rate 60 --pos 0x0 --set TearFree on --output HDMI-A-0 --mode 2560x1440 --rate 164 --pos 1920x-360 --primary --set TearFree on

# set keyboard layout
setxkbmap -layout gb

# load xresources
[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

# execute xinitrc.d applications
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# applications
xcompmgr -c -l0 -t0 -r0 -o.00 &
xscreensaver -no-splash &

# harry potter 
# sudo sh -c "echo 1000000 > /proc/sys/vm/max_map_count"

# execute awesome
exec awesome
