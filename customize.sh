#!/system/bin/sh

ui_print "===================================="
ui_print "  FanExtreme v3.0.0"
ui_print "===================================="

INSTALLED_CONFIG="/data/adb/modules/FanExtreme/config.txt"
NEW_CONFIG="$MODPATH/config.txt"

if [ -f "$INSTALLED_CONFIG" ]; then
    ui_print "  📋 检测到已安装版本，保留现有配置"
    cp -f "$INSTALLED_CONFIG" "$NEW_CONFIG"
else
    ui_print "  📋 全新安装，使用默认配置"
fi

cfg() { grep -o "^$1=.*" "$NEW_CONFIG" 2>/dev/null | cut -d= -f2 | tr -d '\r' | tail -1; }

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
    DESC="$DESC 充电分离($threshold%)"
fi

if [ "$(cfg '云控屏蔽')" = "1" ]; then
    ui_print "  ✅ 云控屏蔽"
    touch "$MODPATH/.cloud"
    DESC="$DESC 云控屏蔽"
fi

if [ "$(cfg '温控移除')" = "1" ]; then
    PLAT=$(getprop ro.board.platform 2>/dev/null)
    THERMAL_PLATS="pineapple"
    case " $THERMAL_PLATS " in
        *" $PLAT "*)
            ui_print "  ✅ 温控移除 ($PLAT)"
            touch "$MODPATH/.thermal"
            DESC="$DESC 温控移除"
            ;;
        *)
            ui_print "  ⚠️ 温控移除：当前平台($PLAT)无专用配置，已跳过"
            rm -f "$MODPATH/vendor/etc/thermal-engine.conf"
            ;;
    esac
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

sed -i '/^description=/d' "$MODPATH/module.prop"
echo "description=${DESC# }" >> "$MODPATH/module.prop"

ui_print "===================================="
ui_print "重启生效"
ui_print "===================================="
