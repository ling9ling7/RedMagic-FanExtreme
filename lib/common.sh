cfg() {
    grep -o "^$1=.*" "$CONFIG" 2>/dev/null | cut -d= -f2 | tail -1
}
