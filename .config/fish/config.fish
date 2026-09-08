source /usr/share/cachyos-fish-config/cachyos-config.fish
function albion
    prime-run flatpak run com.albiononline.AlbionOnline >/dev/null 2>&1 &
    disown
end
# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
