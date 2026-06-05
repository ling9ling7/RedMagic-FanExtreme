#!/system/bin/sh

MODDIR=${0%/*}
CONFIG="$MODDIR/config.txt"
FAN_LEVEL=/sys/kernel/fan/fan_speed_level

cfg() {
    grep -o "^$1=.*" "$CONFIG" 2>/dev/null | cut -d= -f2 | tail -1
}

fan_extreme() {
    for i in $(seq 1 30); do
        [ -e "$FAN_LEVEL" ] && break
        sleep 2
    done
    if [ -e "$FAN_LEVEL" ]; then
        su system -c "echo 5 > $FAN_LEVEL" 2>/dev/null
        chmod 444 $FAN_LEVEL 2>/dev/null
    fi
}

charge_separation_monitor() {
    local threshold=$(cfg "充电分离阈值")
    [ -z "$threshold" ] && threshold=100
    while true; do
        local_info=$(dumpsys battery 2>/dev/null)
        [ -z "$local_info" ] && sleep 10 && continue
        level=$(echo "$local_info" | grep 'level:' | head -1 | tr -d ' ' | cut -d: -f2)
        ac=$(echo "$local_info" | grep 'AC powered:' | head -1 | awk '{print $3}')
        usb=$(echo "$local_info" | grep 'USB powered:' | head -1 | awk '{print $3}')
        wireless=$(echo "$local_info" | grep 'Wireless powered:' | head -1 | awk '{print $3}')
        if [ "$level" -ge "$threshold" ] && { [ "$ac" = "true" ] || [ "$usb" = "true" ] || [ "$wireless" = "true" ]; }; then
            current=$(settings get global charge_separation_switch 2>/dev/null)
            if [ "$current" != "1" ]; then
                settings put global charge_separation_switch 1
            fi
        fi
        sleep 10
    done
}

block_cloud_control() {
    for d in \
        /data/system/cube \
        /data/system/cube/SM8650 \
        /data/system/cube/SM8650/NX769J \
        /data/system/cube/SM8650/app \
        /data/system/cube/app \
        /data/system/cubeusercfg; do
        if [ -d "$d" ]; then
            chattr -i "$d" 2>/dev/null
            for f in "$d"/*; do
                [ -e "$f" ] && { chattr -i "$f" 2>/dev/null; rm -rf "$f"; }
            done
            chattr +i "$d" 2>/dev/null
        fi
    done
}

remove_thermal() {
    :
}

if [ "$(cfg '风扇极速')" = "1" ]; then
    fan_extreme
fi

if [ "$(cfg '充电分离')" = "1" ]; then
    charge_separation_monitor &
fi

if [ "$(cfg '充电加速')" = "1" ]; then
    for i in $(seq 1 15); do
        [ -e /sys/class/qcom-battery/restrict_cur ] && break
        sleep 1
    done
    echo 0 > /sys/class/qcom-battery/restrict_cur 2>/dev/null
    echo 0 > /sys/class/qcom-battery/restrict_chg 2>/dev/null
fi

if [ "$(cfg '云控屏蔽')" = "1" ]; then
    block_cloud_control
fi

vibe_boost() {
    local gain=$(cfg "振动增益" | sed 's/%%//g; s/%//g')
    local dur=$(cfg "振动时长" | sed 's/ms//g')
    local vmax=$(cfg "振动上限")
    [ -z "$gain" ] && gain=168
    [ -z "$dur" ] && dur=18
    [ -z "$vmax" ] && vmax=128
    local VIBE=/sys/class/leds/vibrator
    for i in $(seq 1 15); do
        [ -e "$VIBE/gain" ] && break
        sleep 1
    done
    if [ -e "$VIBE/gain" ]; then
        printf 0x%x "$gain" > $VIBE/gain
        printf 0x%x "$dur" > $VIBE/duration_aw
        printf 0x%x "$vmax" > $VIBE/vmax
        echo 0x01 > $VIBE/cont_brk_time
        echo 0x03 > $VIBE/cont_wait_num
    fi
}

if [ "$(cfg '振动增强')" = "1" ]; then
    vibe_boost
fi

touch_firmware() {
    for i in $(seq 1 15); do
        [ -d /vendor/firmware ] && break
        sleep 2
    done
    if [ -d /vendor/firmware ]; then
        mount --bind "$MODDIR/vendor/firmware/goodix_cfg_group_9916r.bin" /vendor/firmware/goodix_cfg_group_9916r.bin
    fi
}

if [ "$(cfg '温控移除')" = "1" ]; then
    remove_thermal
else
    rm -f "$MODDIR/vendor/etc/thermal-engine.conf"
fi

touch_boost() {
    local TP=/proc/touchscreen
    for i in $(seq 1 15); do
        [ -e "$TP/tp_report_rate" ] && break
        sleep 1
    done
    if [ -e "$TP/tp_report_rate" ]; then
        echo 4 > $TP/tp_report_rate
        echo 1 > $TP/play_game
        echo 4 > $TP/follow_hand_level
    fi
    settings put system touch_sampling_rate 960 2>/dev/null
}

if [ "$(cfg '触控优化')" = "1" ]; then
    touch_boost
    inotifyd - /sys/class/backlight/panel0-backlight/brightness:d | while read -r f; do
        touch_boost
    done &
fi

touch_firmware
