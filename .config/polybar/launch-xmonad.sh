#!/bin/env sh

killall polybar

polybar middle-xmonad &
polybar right-xmonad &
polybar left-xmonad &
