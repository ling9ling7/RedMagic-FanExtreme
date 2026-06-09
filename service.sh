#!/system/bin/sh

MODDIR=${0%/*}
CONFIG="$MODDIR/config.txt"

cfg() {
    grep -o "^$1=.*" "$CONFIG" 2>/dev/null | cut -d= -f2 | tail -1
}

fan_extreme() {
    for i in $(seq 1 30); do
        [ -e /sys/kernel/fan/fan_speed_level ] && break
        sleep 2
    done
    if [ -e /sys/kernel/fan/fan_speed_level ]; then
        su system -c "echo 5 > /sys/kernel/fan/fan_speed_level" 2>/dev/null
        chmod 444 /sys/kernel/fan/fan_speed_level 2>/dev/null
    fi
}

if [ "$(cfg '风扇极速')" = "1" ]; then
    fan_extreme
fi

if [ "$(cfg '充电加速')" = "1" ]; then
    for i in $(seq 1 15); do
        [ -e /sys/class/qcom-battery/restrict_cur ] && break
        sleep 1
    done
    echo 0 > /sys/class/qcom-battery/restrict_cur 2>/dev/null
    echo 0 > /sys/class/qcom-battery/restrict_chg 2>/dev/null
fi

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

if [ "$(cfg '云控屏蔽')" = "1" ]; then
    block_cloud_control
fi

remove_thermal() { :; }

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
    (
      while true; do
        sleep 60
        [ -f "$AUTO_TOUCH_FILE" ] && touch_boost
      done
    ) &
    inotifyd - /sys/class/backlight/panel0-backlight/brightness:d | while read -r f; do
        [ -f "$AUTO_TOUCH_FILE" ] && touch_boost
    done &
fi

# === WebUI ===
WEBUI_CMD="$MODDIR/webui_cmd"
WEBUI_STATUS="$MODDIR/webui_status"
THRESHOLD_FILE="/sdcard/FanExtreme/threshold"
AUTO_CHARGE_FILE="$MODDIR/auto_charge"
AUTO_FAN_FILE="$MODDIR/auto_fan"
AUTO_TOUCH_FILE="$MODDIR/auto_touch"

mkdir -p /sdcard/FanExtreme 2>/dev/null
[ "$(cfg '充电分离')" = "1" ] && touch "$AUTO_CHARGE_FILE" 2>/dev/null
[ "$(cfg '风扇极速')" = "1" ] && touch "$AUTO_FAN_FILE" 2>/dev/null
[ "$(cfg '触控优化')" = "1" ] && touch "$AUTO_TOUCH_FILE" 2>/dev/null
tcfg=$(cfg "充电分离阈值")
[ -s "$THRESHOLD_FILE" ] || { [ -n "$tcfg" ] && echo "$tcfg" > "$THRESHOLD_FILE" 2>/dev/null; }

webui_status() {
  local info=$(dumpsys battery 2>/dev/null)
  local bat=$(echo "$info" | grep level | head -1 | tr -d ' ' | cut -d: -f2)
  local temp_raw=$(cat /sys/class/power_supply/battery/temp 2>/dev/null)
  local temp_deg=""
  [ -n "$temp_raw" ] && temp_deg=$(awk "BEGIN{printf \"%.1f\", $temp_raw/10}")
  local cur=$(cat /sys/class/power_supply/battery/current_now 2>/dev/null)
  local vol=$(cat /sys/class/power_supply/battery/voltage_now 2>/dev/null)
  local power=""
  local ac=$(echo "$info" | grep 'AC powered:' | head -1 | awk '{print $3}')
  local usb=$(echo "$info" | grep 'USB powered:' | head -1 | awk '{print $3}')
  if { [ "$ac" = "true" ] || [ "$usb" = "true" ]; } && [ -n "$cur" ] && [ -n "$vol" ]; then
    local cur_abs="${cur#-}"
    power=$(awk "BEGIN{printf \"%.1f\", $cur_abs*$vol/1000000000000}")
  fi
  local cs=$(settings get global charge_separation_switch 2>/dev/null)
  local threshold=""
  [ -f "$THRESHOLD_FILE" ] && threshold=$(cat "$THRESHOLD_FILE")
  local auto_charge=0
  [ -f "$AUTO_CHARGE_FILE" ] && auto_charge=1
  local charge_enabled=0
  [ "$(cfg '充电分离')" = "1" ] && charge_enabled=1
  local fan_level=""
  [ -e /sys/kernel/fan/fan_speed_level ] && fan_level=$(cat /sys/kernel/fan/fan_speed_level 2>/dev/null)
  local auto_fan=0
  [ -f "$AUTO_FAN_FILE" ] && auto_fan=1
  local fan_enabled=0
  [ "$(cfg '风扇极速')" = "1" ] && fan_enabled=1
  local touch_enabled=0
  [ "$(cfg '触控优化')" = "1" ] && touch_enabled=1
  local touch_boost=0
  [ -f "$AUTO_TOUCH_FILE" ] && touch_boost=1
  echo "{\"battery\":\"${bat}\",\"temp_deg\":\"${temp_deg}\",\"power\":\"${power}\",\"cs\":\"${cs}\",\"threshold\":\"${threshold}\",\"auto_charge\":${auto_charge},\"charge_enabled\":${charge_enabled},\"fan_level\":\"${fan_level}\",\"auto_fan\":${auto_fan},\"fan_enabled\":${fan_enabled},\"touch_enabled\":${touch_enabled},\"touch_boost\":${touch_boost}}" > "$WEBUI_STATUS"
}

webui_loop() {
  mkdir -p /sdcard/FanExtreme 2>/dev/null
  while true; do
    if [ -f "$WEBUI_CMD" ]; then
      local cmd=$(cat "$WEBUI_CMD" 2>/dev/null)
      if [ -n "$cmd" ]; then
        local action=""
        local value=""
        action=$(echo "$cmd" | sed 's/.*"action":"\([^"]*\)".*/\1/')
        value=$(echo "$cmd" | sed 's/.*"value":"\([^"]*\)".*/\1/')
        case "$action" in
          auto_fan)
            if [ "$value" = "on" ]; then
              touch "$AUTO_FAN_FILE"
              [ -e /sys/kernel/fan/fan_speed_level ] && chmod 644 /sys/kernel/fan/fan_speed_level 2>/dev/null && chmod 644 /sys/kernel/fan/fan_enable 2>/dev/null && echo 1 > /sys/kernel/fan/fan_enable && echo 5 > /sys/kernel/fan/fan_speed_level
            else
              rm -f "$AUTO_FAN_FILE"
            fi
            ;;
          fan_level)
            [ -n "$value" ] && [ -e /sys/kernel/fan/fan_speed_level ] && chmod 644 /sys/kernel/fan/fan_speed_level 2>/dev/null && echo "$value" > /sys/kernel/fan/fan_speed_level && echo 1 > /sys/kernel/fan/fan_enable 2>/dev/null
            ;;
          auto_charge)
            if [ "$value" = "on" ]; then
              touch "$AUTO_CHARGE_FILE"
            else
              rm -f "$AUTO_CHARGE_FILE"
              tcfg=$(cfg "充电分离阈值")
              if [ -n "$tcfg" ] && [ "$tcfg" != "$(cat "$THRESHOLD_FILE" 2>/dev/null)" ]; then
                local cs_now=$(settings get global charge_separation_switch 2>/dev/null)
                if [ "$cs_now" = "1" ]; then
                  settings put global charge_separation_switch 0
                fi
              fi
              [ -n "$tcfg" ] && echo "$tcfg" > "$THRESHOLD_FILE" 2>/dev/null
            fi
            ;;
          threshold)
            [ -n "$value" ] && echo "$value" > "$THRESHOLD_FILE"
            ;;
          touch_boost)
            if [ "$value" = "on" ]; then
              touch "$AUTO_TOUCH_FILE"
              local TP=/proc/touchscreen
              [ -e "$TP/tp_report_rate" ] && { echo 4 > $TP/tp_report_rate; echo 1 > $TP/play_game; echo 4 > $TP/follow_hand_level; }
              settings put system touch_sampling_rate 960 2>/dev/null
            else
              rm -f "$AUTO_TOUCH_FILE"
              [ -e /proc/touchscreen/tp_report_rate ] && { echo 1 > /proc/touchscreen/tp_report_rate; echo 0 > /proc/touchscreen/play_game; echo 1 > /proc/touchscreen/follow_hand_level; }
              settings delete system touch_sampling_rate 2>/dev/null
            fi
            ;;
        esac
        rm -f "$WEBUI_CMD"
      fi
    fi
    webui_status
    sleep 2
  done
}

webui_loop &

# 充电分离监控
if [ "$(cfg '充电分离')" = "1" ]; then
  (
    while true; do
      if [ -f "$AUTO_CHARGE_FILE" ]; then
        threshold=$(cat "$THRESHOLD_FILE" 2>/dev/null)
        [ -z "$threshold" ] && threshold=$(cfg "充电分离阈值")
        [ -z "$threshold" ] && threshold=100
        local_info=$(dumpsys battery 2>/dev/null)
        [ -z "$local_info" ] && sleep 3 && continue
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
        sleep 3
      else
        sleep 3
      fi
    done
  ) &
fi

touch_firmware
