function fish_greeting
  eval (random choice (ls /usr/local/bin/colorscripts) neofetch)
   
end

starship init fish | source
export PATH="/home/mohsin/.cargo/bin/:/home/mohsin/.local/bin/:/usr/local/bin/colorscripts/:/home/mohsin/godot/Godot_v3.2.3-stable_mono_x11_64/:$PATH"
export SUDO_EDITOR="/usr/bin/nvim"
wal -r && clear
