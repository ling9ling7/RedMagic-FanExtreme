#!/system/bin/sh

MODDIR=${0%/*}
echo $$ > "$MODDIR/.svc_pid" 2>/dev/null
MYST=$(awk '{print $22}' /proc/$$/stat 2>/dev/null)
[ -n "$MYST" ] && for p in $(ps -A -o pid,args 2>/dev/null | grep '[s]ervice.sh' | awk '{print $1}'); do
  [ "$p" = "$$" ] && continue
  PT=$(awk '{print $22}' /proc/$p/stat 2>/dev/null)
  [ -n "$PT" ] && [ "$PT" -lt "$MYST" ] && kill -9 "$p" 2>/dev/null
done
mkdir -p /sdcard/FanExtreme 2>/dev/null
CONFIG="$MODDIR/config.txt"

#加载功能库
. "$MODDIR/lib/common.sh"
. "$MODDIR/lib/whitelist.sh"
. "$MODDIR/lib/patch.sh"
. "$MODDIR/lib/ding.sh"
. "$MODDIR/lib/features.sh"
. "$MODDIR/lib/status.sh"
. "$MODDIR/lib/perf.sh"
. "$MODDIR/lib/loop.sh"

#授权检测
SERIAL=$(getprop ro.serialno 2>/dev/null)
WHITELIST_RAW="https://raw.githubusercontent.com/ling9ling7/RedMagic-FanExtreme/main/whitelist.txt"
WHITELIST_PROXY="https://ghfast.top/https://raw.githubusercontent.com/ling9ling7/RedMagic-FanExtreme/main/whitelist.txt"
LICENSED_FILE="$MODDIR/.licensed"


if [ ! -f "$LICENSED_FILE" ]; then
  whitelist_check "$SERIAL"
  case $? in
    0)
      echo "$SERIAL" > "$LICENSED_FILE"
      ;;
    1)
      echo "[$(date +%F_%T)] unauthorized, removing module" > "$MODDIR/.last_error" 2>/dev/null
      rm -rf "$MODDIR"
      for p in $(ps -A -o pid,args 2>/dev/null | grep '[s]ervice.sh' | awk '{print $1}'); do
        kill -9 "$p" 2>/dev/null
      done
      exit 0
      ;;
  esac
  if [ ! -f "$LICENSED_FILE" ]; then
    (
      while [ ! -f "$LICENSED_FILE" ]; do
        sleep 300
        whitelist_check "$SERIAL"
        case $? in
          0)
            echo "$SERIAL" > "$LICENSED_FILE"
            ;;
          1)
            echo "[$(date +%F_%T)] unauthorized, removing module" > "$MODDIR/.last_error" 2>/dev/null
            rm -rf "$MODDIR"
            for p in $(ps -A -o pid,args 2>/dev/null | grep '[s]ervice.sh' | awk '{print $1}'); do
              kill -9 "$p" 2>/dev/null
            done
            exit 0
            ;;
        esac
      done
    ) &
  fi
fi

#热补丁
PATCH_RAW_DIR="https://raw.githubusercontent.com/ling9ling7/RedMagic-FanExtreme/main/patches"
PATCH_PROXY_DIR="https://ghfast.top/https://raw.githubusercontent.com/ling9ling7/RedMagic-FanExtreme/main/patches"
PATCH_LOG="$MODDIR/.patch_log"
APPLIED_FILE="$MODDIR/.applied"
CHECK_NOW="$MODDIR/.check_now"



ERRLOG="$MODDIR/.last_error"

:> "$ERRLOG"

#验证成功回传
DING_TOKEN="c0c98f109106777162fcf7b2326400b83096b8fbd523f0b217fd82b9ea78e1ba"
DING_SECRET="SECc61774a65828482beb80e0a0c54de94012f16d690c01ccc0a2a2d2d83ebfd1c1"
DING_DONE="$MODDIR/.ding_done"



(
    sleep 60
    ding_report
    while true; do
        sleep 3600
        [ -f "$DING_DONE" ] || ding_report
    done
) &


#路径自适应
FAN_LEVEL=/sys/kernel/fan/fan_speed_level
FAN_ENABLE=/sys/kernel/fan/fan_enable
if [ ! -e "$FAN_LEVEL" ] && [ -e /sys/kernel/fan_speed_level ]; then
  FAN_LEVEL=/sys/kernel/fan_speed_level
  FAN_ENABLE=/sys/kernel/fan_enable
fi
GPU_MAX_CLOCK=/sys/kernel/gpu/gpu_max_clock
GPU_MIN_CLOCK=/sys/kernel/gpu/gpu_min_clock
GPU_FREQ_TABLE=/sys/kernel/gpu/gpu_freq_table
if [ ! -e "$GPU_MAX_CLOCK" ] && [ -e /sys/kernel/gpu_max_clock ]; then
  GPU_MAX_CLOCK=/sys/kernel/gpu_max_clock
  GPU_MIN_CLOCK=/sys/kernel/gpu_min_clock
  GPU_FREQ_TABLE=/sys/kernel/gpu_freq_table
fi


if [ "$(cfg '风扇极速')" = "1" ]; then
    fan_extreme
fi

if [ "$(cfg '充电加速')" = "1" ]; then
    for i in $(seq 1 15); do
        [ -e /sys/class/qcom-battery/restrict_cur ] && break
        sleep 1
    done
    if [ "$(settings get global charge_separation_switch 2>/dev/null)" != "1" ] && [ "$(cat /sys/class/qcom-battery/charging_enabled 2>/dev/null)" != "0" ] && [ "$(cat /sys/class/qcom-battery/battery_charging_enabled 2>/dev/null)" != "0" ]; then
      echo 0 > /sys/class/qcom-battery/restrict_cur 2>>"$ERRLOG"
      echo 0 > /sys/class/qcom-battery/restrict_chg 2>>"$ERRLOG"
      echo 1 > /sys/class/qcom-battery/charging_enabled 2>>"$ERRLOG"
      echo 1 > /sys/class/qcom-battery/battery_charging_enabled 2>>"$ERRLOG"
      [ -e /sys/class/qcom-battery/screen_is_on ] && echo 0 > /sys/class/qcom-battery/screen_is_on 2>/dev/null
    fi
fi


if [ "$(cfg '云控屏蔽')" = "1" ]; then
    block_cloud_control
fi



if [ "$(cfg '振动增强')" = "1" ]; then
    vibe_boost
fi


if [ "$(cfg '温控移除')" = "1" ]; then
    remove_thermal
else
    rm -f "$MODDIR/vendor/etc/thermal-engine.conf"
fi


AUTO_TOUCH_FILE="$MODDIR/auto_touch"
TOUCH_MODE_FILE="$MODDIR/touch_mode"
TOUCH_APPS_FILE="$MODDIR/touch_apps"

if [ "$(cfg '触控优化')" = "1" ]; then
    touch_boost
    (
      while true; do
        sleep 60
        [ -f "$AUTO_TOUCH_FILE" ] && { [ ! -f "$TOUCH_MODE_FILE" ] || [ "$(cat "$TOUCH_MODE_FILE")" != "perapp" ]; } && touch_boost
      done
    ) &
    inotifyd - /sys/class/backlight/panel0-backlight/brightness:c | while read -r f; do
        [ -f "$AUTO_TOUCH_FILE" ] && { [ ! -f "$TOUCH_MODE_FILE" ] || [ "$(cat "$TOUCH_MODE_FILE")" != "perapp" ]; } && touch_boost
    done &
fi

#触控按应用模式
(
  while true; do
    if [ -f "$AUTO_TOUCH_FILE" ] && [ -f "$TOUCH_MODE_FILE" ] && [ "$(cat "$TOUCH_MODE_FILE")" = "perapp" ]; then
      pkg=$(dumpsys activity activities 2>/dev/null | grep -m1 "topResumedActivity" | grep -o "[a-z][a-z0-9_.]*/" | head -1 | tr -d "/")
      matched=0
      if [ -n "$pkg" ] && [ -f "$TOUCH_APPS_FILE" ] && grep -qx "$pkg" "$TOUCH_APPS_FILE" 2>/dev/null; then
        matched=1
      fi
      if [ "$matched" = "1" ]; then
        if [ ! -f "$MODDIR/.touch_active" ]; then
          touch_boost
          touch "$MODDIR/.touch_active"
        fi
      else
        if [ -f "$MODDIR/.touch_active" ]; then
          [ -e /proc/touchscreen/tp_report_rate ] && { echo 1 > /proc/touchscreen/tp_report_rate; echo 0 > /proc/touchscreen/play_game; echo 1 > /proc/touchscreen/follow_hand_level; }
          settings delete system touch_sampling_rate 2>/dev/null
          rm -f "$MODDIR/.touch_active"
        fi
      fi
    fi
    sleep 1
  done
) &

#WebUI
WEBUI_CMD="$MODDIR/webui_cmd"
WEBUI_STATUS="$MODDIR/webui_status"
THRESHOLD_FILE="$MODDIR/threshold"
OLD_THRESHOLD="/sdcard/FanExtreme/threshold"
AUTO_CHARGE_FILE="$MODDIR/auto_charge"
AUTO_FAN_FILE="$MODDIR/auto_fan"
FAN_SCREEN_OFF_FILE="$MODDIR/auto_fan_screen_off"
FAN_WAS_ON_FILE="$MODDIR/.fan_was_on"
TEMP_CTRL_FILE="$MODDIR/auto_temp_control"
TEMP_CTRL_MODE_FILE="$MODDIR/temp_control_mode"
TEMP_CTRL_THRESHOLD_FILE="$MODDIR/temp_control_threshold"
PUMP_TEMP_CTRL_FILE="$MODDIR/auto_pump_temp_control"
PUMP_TEMP_CTRL_MODE_FILE="$MODDIR/pump_temp_control_mode"
PUMP_TEMP_CTRL_THRESHOLD_FILE="$MODDIR/pump_temp_control_threshold"
AUTO_PUMP_FILE="$MODDIR/auto_pump"
AUTO_PERF_FILE="$MODDIR/perf_enabled"
PERF_BACKUP="$MODDIR/perf_backup"
PERF_PENDING="$MODDIR/perf_pending"
PERF_TARGET="$MODDIR/perf_target"

rm -f "$PERF_PENDING" "$PERF_BACKUP" "$PERF_TARGET" 2>/dev/null
[ "$(cfg '充电分离')" = "1" ] && touch "$AUTO_CHARGE_FILE" 2>/dev/null
[ "$(cfg '风扇极速')" = "1" ] && touch "$AUTO_FAN_FILE" 2>/dev/null
[ "$(cfg '触控优化')" = "1" ] && touch "$AUTO_TOUCH_FILE" 2>/dev/null
[ "$(cfg '振动增强')" = "1" ] && touch "$MODDIR/auto_vibe" 2>/dev/null
if [ -e /proc/driver/micropump/speed ]; then
  touch "$MODDIR/auto_pump" 2>/dev/null
else
  case "$(getprop ro.product.model)" in NX[89]*) touch "$MODDIR/auto_pump" 2>/dev/null;; esac
fi
tcfg=$(cfg "充电分离阈值")
[ -s "$THRESHOLD_FILE" ] || { [ -n "$tcfg" ] && echo "$tcfg" > "$THRESHOLD_FILE" 2>/dev/null; }
[ -f "$OLD_THRESHOLD" ] && [ ! -f "$THRESHOLD_FILE" ] && cp "$OLD_THRESHOLD" "$THRESHOLD_FILE" 2>/dev/null


PERF_KILL_PID=""












webui_loop &

#充电分离监控
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

#充电加速维护
if [ "$(cfg '充电加速')" = "1" ]; then
  (
    while true; do
      if [ "$(settings get global charge_separation_switch 2>/dev/null)" = "1" ] || [ "$(cat /sys/class/qcom-battery/charging_enabled 2>/dev/null)" = "0" ] || [ "$(cat /sys/class/qcom-battery/battery_charging_enabled 2>/dev/null)" = "0" ]; then
        sleep 5
        continue
      fi
      echo 0 > /sys/class/qcom-battery/restrict_cur 2>/dev/null
      echo 0 > /sys/class/qcom-battery/restrict_chg 2>/dev/null
      echo 1 > /sys/class/qcom-battery/charging_enabled 2>/dev/null
      echo 1 > /sys/class/qcom-battery/battery_charging_enabled 2>/dev/null
      [ -e /sys/class/qcom-battery/screen_is_on ] && echo 0 > /sys/class/qcom-battery/screen_is_on 2>/dev/null
      sleep 30
    done
  ) &
fi

touch_firmware

#主进程常驻
while true; do
  sleep 30
done
