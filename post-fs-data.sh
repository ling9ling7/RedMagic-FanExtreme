#!/system/bin/sh
# FanExtreme 温控移除：开机早期把高阈值 conf bind 到 /vendor
# 在 thermal-engine(class main) 启动前完成，使其首次启动即读取覆盖后的 conf
MODDIR=${0%/*}
[ "$(grep -o '^温控移除=.*' "$MODDIR/config.txt" 2>/dev/null | cut -d= -f2 | tail -1)" = "1" ] || exit 0
[ -f "$MODDIR/vendor/etc/thermal-engine.conf" ] || exit 0
mount --bind "$MODDIR/vendor/etc/thermal-engine.conf" /vendor/etc/thermal-engine.conf 2>/dev/null
exit 0
