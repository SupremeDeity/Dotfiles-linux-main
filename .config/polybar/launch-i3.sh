#!/bin/env sh

pkill polybar

sleep 1;

polybar middle-i3 &
polybar right-i3 &
polybar left-i3 &
