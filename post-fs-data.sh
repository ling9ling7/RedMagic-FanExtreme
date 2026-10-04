MODDIR=${0%/*}
[ "$(grep -o '^温控移除=.*' "$MODDIR/config.txt" 2>/dev/null | cut -d= -f2 | tr -d '\r\t' | sed 's/ *$//' | tail -1)" = "0" ] && exit 0
[ -f "$MODDIR/vendor/etc/thermal-engine.conf" ] || exit 0
mount --bind "$MODDIR/vendor/etc/thermal-engine.conf" /vendor/etc/thermal-engine.conf 2>/dev/null
exit 0