fan_extreme() {
    for i in $(seq 1 30); do
        [ -e "$FAN_LEVEL" ] && break
        sleep 2
    done
    if [ -e "$FAN_LEVEL" ]; then
        su system -c "echo 5 > $FAN_LEVEL" 2>>"$ERRLOG" || echo "[FAIL] fan_speed_level=$?" >>"$ERRLOG"
        chmod 444 "$FAN_LEVEL" 2>>"$ERRLOG"
    fi
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
    for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq /sys/class/kgsl/kgsl-3d0/devfreq/max_freq /sys/class/kgsl/kgsl-3d0/devfreq/min_freq; do
        chmod 644 "$f" 2>/dev/null
    done
}
vibe_boost() {
    local gain=""
    local dur=""
    local vmax=""
    [ -f "$MODDIR/vibe_gain" ] && gain=$(cat "$MODDIR/vibe_gain")
    [ -f "$MODDIR/vibe_duration" ] && dur=$(cat "$MODDIR/vibe_duration")
    [ -f "$MODDIR/vibe_vmax" ] && vmax=$(cat "$MODDIR/vibe_vmax")
    [ -z "$gain" ] && gain=$(cfg "振动增益" | sed 's/%%//g; s/%//g')
    [ -z "$dur" ] && dur=$(cfg "振动时长" | sed 's/ms//g')
    [ -z "$vmax" ] && vmax=$(cfg "振动上限")
    [ -z "$gain" ] && gain=168
    [ -z "$dur" ] && dur=18
    [ -z "$vmax" ] && vmax=128
    local VIBE=/sys/class/leds/vibrator
    for i in $(seq 1 15); do
        [ -e "$VIBE/gain" ] && break
        sleep 1
    done
    if [ -e "$VIBE/gain" ]; then
        printf 0x%x "$gain" > $VIBE/gain 2>>"$ERRLOG" || echo "[FAIL] vibe_gain=$?" >>"$ERRLOG"
        printf 0x%x "$dur" > $VIBE/duration_aw 2>>"$ERRLOG" || echo "[FAIL] vibe_dur=$?" >>"$ERRLOG"
        printf 0x%x "$vmax" > $VIBE/vmax 2>>"$ERRLOG" || echo "[FAIL] vibe_vmax=$?" >>"$ERRLOG"
        echo 0x01 > $VIBE/cont_brk_time 2>>"$ERRLOG"
        echo 0x03 > $VIBE/cont_wait_num 2>>"$ERRLOG"
    fi
}
touch_firmware() {
    for i in $(seq 1 15); do
        [ -d /vendor/firmware ] && break
        sleep 2
    done
    if [ -d /vendor/firmware ] && [ -f "$MODDIR/vendor/firmware/goodix_cfg_group_9916r.bin" ] && [ -f /vendor/firmware/goodix_cfg_group_9916r.bin ]; then
        mount --bind "$MODDIR/vendor/firmware/goodix_cfg_group_9916r.bin" /vendor/firmware/goodix_cfg_group_9916r.bin 2>>"$ERRLOG" || echo "[FAIL] touch_firmware=$?" >>"$ERRLOG"
    fi
}
touch_boost() {
    local TP=/proc/touchscreen
    for i in $(seq 1 15); do
        [ -e "$TP/tp_report_rate" ] && break
        sleep 1
    done
    if [ -e "$TP/tp_report_rate" ]; then
        echo 4 > $TP/tp_report_rate 2>>"$ERRLOG" || echo "[FAIL] tp_report_rate=$?" >>"$ERRLOG"
        echo 1 > $TP/play_game 2>>"$ERRLOG"
        echo 4 > $TP/follow_hand_level 2>>"$ERRLOG"
    fi
    settings put system touch_sampling_rate 960 2>/dev/null
}
brightness_unlock() {
    local BRIGHT_FILE=""
    local BRIGHT_MAX=""
    local TRIGGER_VALUE="7030"
    local TARGET_VALUE="8190"
    for d in /sys/class/backlight/panel0-backlight/brightness /sys/class/backlight/*/brightness; do
        [ -e "$d" ] && { BRIGHT_FILE="$d"; break; }
    done
    [ -z "$BRIGHT_FILE" ] && return 0
    BRIGHT_MAX=$(cat "${BRIGHT_FILE%/brightness}/max_brightness" 2>/dev/null)
    [ -n "$BRIGHT_MAX" ] && [ "$BRIGHT_MAX" -gt 0 ] && [ "$BRIGHT_MAX" -lt "$TARGET_VALUE" ] && TARGET_VALUE="$BRIGHT_MAX"
    for i in $(seq 1 30); do
        [ -f "$BRIGHT_FILE" ] && break
        sleep 2
    done
    if [ -f "$BRIGHT_FILE" ]; then
        (
            while true; do
                cur=$(cat "$BRIGHT_FILE" 2>/dev/null)
                if [ -n "$cur" ] && [ "$cur" = "$TRIGGER_VALUE" ]; then
                    echo "$TARGET_VALUE" > "$BRIGHT_FILE" 2>>"$ERRLOG" || echo "[FAIL] brightness_unlock=$?" >>"$ERRLOG"
                fi
                sleep 0.5
            done
        ) &
    fi
}
