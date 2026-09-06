cfg() {
    grep -o "^$1=.*" "$CONFIG" 2>/dev/null | cut -d= -f2 | tail -1
}
st() {
    grep -o "^$1=.*" "$STATE" 2>/dev/null | cut -d= -f2 | tail -1
}
cfg_set() {
    if [ ! -f "$STATE" ]; then
        [ -f "$CONFIG" ] && cp "$CONFIG" "$STATE" 2>/dev/null
        [ -f "$STATE" ] || return 0
    fi
    if grep -q "^$1=" "$STATE" 2>/dev/null; then
        sed -i "s/^$1=.*/$1=$2/" "$STATE" 2>/dev/null
    else
        [ -n "$(tail -c 1 "$STATE" 2>/dev/null)" ] && echo >> "$STATE" 2>/dev/null
        echo "$1=$2" >> "$STATE" 2>/dev/null
    fi
}
