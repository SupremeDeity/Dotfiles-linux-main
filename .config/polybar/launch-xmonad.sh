#!/bin/env sh

killall polybar

sleep 1;

polybar middle-xmonad &
polybar right-xmonad &
polybar left-xmonad &
