_rrwm() {
    _arguments -s \
        '--waybar[Run in Waybar client mode (receive JSON status stream)]' \
        '--appid[List all active windows and their AppIDs]' \
        '--help[Print help message]'
}

compdef _rrwm rrwm
