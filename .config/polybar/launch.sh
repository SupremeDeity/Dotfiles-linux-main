#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar
# If all your bars have ipc enabled, you can also use 
# polybar-msg cmd quit

# Launch bar1 and bar2
echo "---" | tee -a /tmp/polybar-right.log /tmp/polybar-left.log /tmp/polybar-center.log
polybar left 2>&1 | tee -a /tmp/polybar-left.log & disown
polybar right 2>&1 | tee -a /tmp/polybar-right.log & disown
polybar middle 2>&1 | tee -a /tmp/polybar-center.log & disown

echo "Bars launched..."
