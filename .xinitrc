#!/bin/sh

xrdb $HOME/.Xresources
if (xrandr | rg -q 'HDMI-?. connected'); then
  xrdb -override .Xresources-96dpi
  mons -s
  export WINDOW_SCALING='1'
else
  xrdb -override .Xresources-144dpi
  export WINDOW_SCALING='1.5'
fi
xset s off && xset dpms 10800 10800 10800

export XIM=nabi
export XIM_ARGS=
export XIM_PROGRAM="nabi"
export XMODIFIERS="@im=nabi"
export GTK_IM_MODULE=xim
export QT_IM_MODULE=xim

$HOME/bin/configure-inputs
xsetroot -solid '#1B2B34'
xsetroot -cursor_name left_ptr
eval $(ssh-agent)

autocutsel -fork &
autocutsel -selection PRIMARY -fork &
unclutter &
sxhkd -c $HOME/.config/sxhkd/sxhkdrc &
cp $HOME/.fgwm.log $HOME/.fgwm.old.log

wm-init &
exec fgwm &> $HOME/.fgwm.log
