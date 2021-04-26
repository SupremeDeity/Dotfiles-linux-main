#starship init fish | source

function fish_greeting
  eval (random choice (ls /usr/local/bin/colorscripts) neofetch)
end

export PATH="/home/mohsin/.cargo/bin/:/home/mohsin/.local/bin/:/usr/local/bin/colorscripts/:/home/mohsin/godot/Godot_v3.2.3-stable_mono_x11_64/:/home/mohsin/.config/bspwm/scripts/:/home/mohsin/.emacs.d/bin/:$PATH"

export SUDO_EDITOR="/usr/bin/nvim"

# For non-kitty terminals, import colorscheme
#(cat ~/.cache/wal/sequences &)

alias tb="nc termbin.com 9999"
