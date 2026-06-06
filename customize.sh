#!/system/bin/sh

ui_print "===================================="
ui_print "  FanExtreme v2.0.0"
ui_print "===================================="

CONFIG="$MODPATH/config.txt"
cfg() { grep -o "^$1=.*" "$CONFIG" 2>/dev/null | cut -d= -f2 | tail -1; }

DESC=""

if [ "$(cfg '风扇极速')" = "1" ]; then
    ui_print "  ✅ 风扇极速"
    touch "$MODPATH/.fan"
    DESC="$DESC 风扇极速"
fi

if [ "$(cfg '充电分离')" = "1" ]; then
    threshold=$(cfg '充电分离阈值')
    [ -z "$threshold" ] && threshold=100
    ui_print "  ✅ 充电分离 ($threshold%)"
    touch "$MODPATH/.charge"
    DESC="$DESC 充电分离($threshold%%)"
fi

if [ "$(cfg '云控屏蔽')" = "1" ]; then
    ui_print "  ✅ 云控屏蔽"
    touch "$MODPATH/.cloud"
    DESC="$DESC 云控屏蔽"
fi

if [ "$(cfg '温控移除')" = "1" ]; then
    ui_print "  ✅ 温控移除"
    touch "$MODPATH/.thermal"
    DESC="$DESC 温控移除"
else
    rm -f "$MODPATH/vendor/etc/thermal-engine.conf"
fi

if [ "$(cfg '振动增强')" = "1" ]; then
    gain=$(cfg '振动增益')
    dur=$(cfg '振动时长')
    vmax=$(cfg '振动上限')
    [ -z "$gain" ] && gain=168
    [ -z "$dur" ] && dur=18
    [ -z "$vmax" ] && vmax=128
    ui_print "  ✅ 振动增强 (增益${gain}/时长${dur}/上限${vmax})"
    touch "$MODPATH/.vibe"
    DESC="$DESC 振动增强(${gain}/${dur}/${vmax})"
fi

rate=$(cfg '触控优化')
if [ "$rate" = "1" ]; then
    ui_print "  ✅ 触控优化 (采样率4档+游戏模式+跟手度拉满+960Hz)"
    touch "$MODPATH/.touch"
    DESC="$DESC 触控优化"
fi

if [ "$(cfg '充电加速')" = "1" ]; then
    ui_print "  ✅ 充电加速 (解除充电时的部分电流限制)"
    touch "$MODPATH/.chargeboost"
    DESC="$DESC 充电加速"
fi

echo "description=${DESC# }" >> "$MODPATH/module.prop"

ui_print "===================================="
ui_print "重启生效"
ui_print "===================================="
