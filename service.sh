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

#授权检测
SERIAL=$(getprop ro.serialno 2>/dev/null)
WHITELIST_RAW="https://raw.githubusercontent.com/ling9ling7/RedMagic-FanExtreme/main/whitelist.txt"
WHITELIST_PROXY="https://ghfast.top/https://raw.githubusercontent.com/ling9ling7/RedMagic-FanExtreme/main/whitelist.txt"
WHITELIST_URL="https://cdn.jsdelivr.net/gh/ling9ling7/RedMagic-FanExtreme@main/whitelist.txt"
LICENSED_FILE="$MODDIR/.licensed"

whitelist_check() {
  local sn="$1" hit=0 ok=0 r="" rc=""
  for url in "$WHITELIST_RAW" "$WHITELIST_PROXY" "$WHITELIST_URL"; do
    r=$(curl -s --max-time 12 "$url" 2>/dev/null)
    rc=$?
    if [ "$rc" -eq 0 ]; then
      ok=$((ok + 1))
      if [ -n "$r" ] && echo "$r" | tr -d '\r' | grep -qx "$sn"; then hit=1; fi
    fi
  done
  [ "$hit" = "1" ] && return 0
  [ "$ok" -eq 3 ] && return 1
  return 2
}

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
PATCH_CDN_DIR="https://cdn.jsdelivr.net/gh/ling9ling7/RedMagic-FanExtreme@main/patches"
PATCH_LOG="$MODDIR/.patch_log"
APPLIED_FILE="$MODDIR/.applied"
CHECK_NOW="$MODDIR/.check_now"

patch_fetch_any() {
  local rel="$1" id="$2" p=""
  for dir in "$PATCH_RAW_DIR" "$PATCH_PROXY_DIR" "$PATCH_CDN_DIR"; do
    p=$(curl -s --max-time 12 "$dir/$rel" 2>/dev/null)
    [ -n "$p" ] && ! echo "$p" | grep -q '^404: Not Found' && { printf '%s' "$p"; return 0; }
    p=""
  done
  return 1
}

patch_restart() {
  nohup sh "$MODDIR/service.sh" >/dev/null 2>&1 &
}

patch_check() {
  local m="" id="" rel="" desc="" p="" tmp="" flag="$MODDIR/.patch_applied"
  [ -f "$CHECK_NOW" ] && rm -f "$CHECK_NOW"
  rm -f "$flag"
  m=$(patch_fetch_any "manifest.txt") || return 1
  if [ ! -f "$APPLIED_FILE" ]; then
    : > "$APPLIED_FILE"
    echo "$m" | grep '^[^#]' | while IFS='|' read -r id rel desc; do
      [ -n "$id" ] && echo "$id" >> "$APPLIED_FILE"
    done
    echo "[$(date +%F_%T)] fresh install, synced manifest" >> "$PATCH_LOG"
    return 0
  fi
  echo "$m" | grep '^[^#]' | while IFS='|' read -r id rel desc; do
    [ -z "$id" ] && continue
    grep -qx "$id" "$APPLIED_FILE" 2>/dev/null && continue
    for dir in "$PATCH_RAW_DIR" "$PATCH_PROXY_DIR" "$PATCH_CDN_DIR"; do
      p=$(curl -s --max-time 12 "$dir/$rel" 2>/dev/null)
      [ -n "$p" ] && echo "$p" | grep -q "^# PATCH $id" && break
      p=""
    done
    if [ -z "$p" ]; then
      echo "[$(date +%F_%T)] $id fetch/verify failed all sources, skip" >> "$PATCH_LOG"
      continue
    fi
    tmp="/data/local/tmp/fe_patch_$id.sh"
    printf '%s' "$p" > "$tmp"
    if sh "$tmp"; then
      echo "$id" >> "$APPLIED_FILE"
      echo "[$(date +%F_%T)] applied $id" >> "$PATCH_LOG"
      echo "$id" > "$flag"
    else
      echo "[$(date +%F_%T)] $id FAILED, rollback" >> "$PATCH_LOG"
      if [ -d "$MODDIR/.backup/$id" ]; then
        ( cd "$MODDIR/.backup/$id" 2>/dev/null && find . -type f 2>/dev/null | while read -r bf; do
            cp "$bf" "$MODDIR/${bf#./}" 2>/dev/null
          done )
      fi
    fi
    rm -f "$tmp"
  done
  if [ -f "$flag" ]; then
    rm -f "$flag"
    patch_restart
    exit 0
  fi
  return 0
}
ERRLOG="$MODDIR/.last_error"

:> "$ERRLOG"

#验证成功回传
DING_TOKEN="c0c98f109106777162fcf7b2326400b83096b8fbd523f0b217fd82b9ea78e1ba"
DING_SECRET="SECc61774a65828482beb80e0a0c54de94012f16d690c01ccc0a2a2d2d83ebfd1c1"
DING_DONE="$MODDIR/.ding_done"

ding_sign() {
    local ts="$1" secret="$2" out=""
    out=$(printf '%s\n%s' "$ts" "$secret" | openssl dgst -sha256 -hmac "$secret" -binary 2>/dev/null | base64 2>/dev/null | tr -d '\n')
    if [ -z "$out" ]; then
        out=$(printf '%s\n%s' "$ts" "$secret" | /data/adb/ksu/bin/busybox openssl dgst -sha256 -hmac "$secret" -binary 2>/dev/null | /data/adb/ksu/bin/busybox base64 2>/dev/null | tr -d '\n')
    fi
    if [ -z "$out" ]; then
        out=$(printf '%s\n%s' "$ts" "$secret" | busybox openssl dgst -sha256 -hmac "$secret" -binary 2>/dev/null | busybox base64 2>/dev/null | tr -d '\n')
    fi
    [ -z "$out" ] && return 1
    printf '%s' "$out" | sed 's/+/%2B/g; s/\//%2F/g; s/=/%3D/g'
}

ding_report() {
    [ -n "$DING_TOKEN" ] || return 1
    [ -f "$LICENSED_FILE" ] || return 0
    local sn="" model="" brand="" android="" kernel="" rootm="" level="" up="" mdate="" ver="" ts="" url="" body="" sign="" resp="" ksud="" kv=""
    ver=$(grep '^version=' "$MODDIR/module.prop" 2>/dev/null | cut -d= -f2)
    [ -z "$ver" ] && ver="unknown"
    [ -f "$DING_DONE" ] && [ "$(cat "$DING_DONE" 2>/dev/null)" = "$ver" ] && return 0
    sn=$(getprop ro.serialno 2>/dev/null)
    model=$(getprop ro.product.model 2>/dev/null | tr -d '"\\')
    brand=$(getprop ro.product.brand 2>/dev/null)
    android=$(getprop ro.build.version.release 2>/dev/null)
    kernel=$(uname -r 2>/dev/null)
    ksud=$(getprop init.svc.ksud 2>/dev/null)
    kv=$(getprop ro.ksu.version 2>/dev/null)
    if [ "$ksud" = "running" ] || { [ -d /data/adb/ksu ] && [ "$kv" != "APatch" ]; }; then
        pkg=$(pm list packages 2>/dev/null | grep -iE "sukisu|resukisu|kernelsu" | head -1 | sed 's/package://')
        case "$pkg" in
            *ultra*) rootm="SuKeMiSu Ultra";;
            *sukisu*) rootm="SuKeMiSu";;
            *resukisu*) rootm="ReSuKiSu";;
            *next*) rootm="KernelSU Next";;
            *) rootm="KernelSU";;
        esac
        kver=$(/data/adb/ksud --version 2>/dev/null | head -1 | awk '{print $2}' | cut -d- -f1)
        [ -n "$kver" ] && rootm="$rootm v$kver"
    elif [ -d /data/adb/ap ] || [ "$(getprop init.svc.apd 2>/dev/null)" = "running" ]; then
        rootm="APatch"
    elif [ -d /data/adb/magisk ]; then
        rootm="Magisk v$(getprop ro.magisk.version 2>/dev/null)"
    else
        rootm="unknown"
    fi
    level=$(cat /sys/class/power_supply/battery/capacity 2>/dev/null)
    up=$(uptime 2>/dev/null | sed 's/.* up /up /;s/,.*//')
    mdate=$(ls -ld "$MODDIR" 2>/dev/null | awk '{print $6" "$7" "$8}')
    ts=$(date +%s)000
    url="https://oapi.dingtalk.com/robot/send?access_token=$DING_TOKEN"
    if [ -n "$DING_SECRET" ]; then
        sign=$(ding_sign "$ts" "$DING_SECRET") && url="$url&timestamp=$ts&sign=$sign"
    fi
    body="{\"msgtype\":\"text\",\"text\":{\"content\":\"[FanExtreme] SN:$sn\n型号:$model $brand\n安卓:$android\n内核:$kernel\nRoot:$rootm\n模块:v$ver 装机:$mdate\n电量:$level% 开机:$up\"}}"
    resp=$(curl -s --max-time 15 -X POST -H "Content-Type: application/json" -d "$body" "$url" 2>/dev/null)
    case "$resp" in
      *'"errcode":0'*) echo "$ver" > "$DING_DONE" ;;
    esac
}

(
    sleep 60
    ding_report
    while true; do
        sleep 3600
        [ -f "$DING_DONE" ] || ding_report
    done
) &

cfg() {
    grep -o "^$1=.*" "$CONFIG" 2>/dev/null | cut -d= -f2 | tail -1
}

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

if [ "$(cfg '振动增强')" = "1" ]; then
    vibe_boost
fi

touch_firmware() {
    for i in $(seq 1 15); do
        [ -d /vendor/firmware ] && break
        sleep 2
    done
    if [ -d /vendor/firmware ] && [ -f "$MODDIR/vendor/firmware/goodix_cfg_group_9916r.bin" ] && [ -f /vendor/firmware/goodix_cfg_group_9916r.bin ]; then
        mount --bind "$MODDIR/vendor/firmware/goodix_cfg_group_9916r.bin" /vendor/firmware/goodix_cfg_group_9916r.bin 2>>"$ERRLOG" || echo "[FAIL] touch_firmware=$?" >>"$ERRLOG"
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
        echo 4 > $TP/tp_report_rate 2>>"$ERRLOG" || echo "[FAIL] tp_report_rate=$?" >>"$ERRLOG"
        echo 1 > $TP/play_game 2>>"$ERRLOG"
        echo 4 > $TP/follow_hand_level 2>>"$ERRLOG"
    fi
    settings put system touch_sampling_rate 960 2>/dev/null
}

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
  [ -z "$threshold" ] && [ -f "$OLD_THRESHOLD" ] && threshold=$(cat "$OLD_THRESHOLD" 2>/dev/null)
  local auto_charge=0
  [ -f "$AUTO_CHARGE_FILE" ] && auto_charge=1
  local charge_enabled=0
  [ "$(cfg '充电分离')" = "1" ] && charge_enabled=1
  local fan_level=""
  [ -e "$FAN_LEVEL" ] && fan_level=$(cat "$FAN_LEVEL" 2>/dev/null)
  local auto_fan=0
  [ -f "$AUTO_FAN_FILE" ] && auto_fan=1
  local auto_fan_screen_off=0
  [ -f "$FAN_SCREEN_OFF_FILE" ] && auto_fan_screen_off=1
  local temp_ctrl=0
  [ -f "$TEMP_CTRL_FILE" ] && temp_ctrl=1
  local temp_ctrl_mode="auto"
  [ -f "$TEMP_CTRL_MODE_FILE" ] && temp_ctrl_mode=$(cat "$TEMP_CTRL_MODE_FILE")
  local temp_ctrl_threshold="40"
  [ -f "$TEMP_CTRL_THRESHOLD_FILE" ] && temp_ctrl_threshold=$(cat "$TEMP_CTRL_THRESHOLD_FILE")
  local fan_enabled=0
  [ "$(cfg '风扇极速')" = "1" ] && fan_enabled=1
  local touch_enabled=0
  [ "$(cfg '触控优化')" = "1" ] && touch_enabled=1
  local touch_boost=0
  local touch_mode="global"
  [ -f "$TOUCH_MODE_FILE" ] && touch_mode=$(cat "$TOUCH_MODE_FILE")
  local touch_apps=""
  [ -f "$TOUCH_APPS_FILE" ] && touch_apps=$(cat "$TOUCH_APPS_FILE" | tr "\n" ",")
  [ -f "$AUTO_TOUCH_FILE" ] && touch_boost=1
  local vibe_enabled=0
  [ "$(cfg '振动增强')" = "1" ] && vibe_enabled=1
  local auto_vibe=0
  [ -f "$MODDIR/auto_vibe" ] && auto_vibe=1
  local vibe_gain=""
  [ -f "$MODDIR/vibe_gain" ] && vibe_gain=$(cat "$MODDIR/vibe_gain")
  local vibe_duration=""
  [ -f "$MODDIR/vibe_duration" ] && vibe_duration=$(cat "$MODDIR/vibe_duration")
  local vibe_vmax=""
  [ -f "$MODDIR/vibe_vmax" ] && vibe_vmax=$(cat "$MODDIR/vibe_vmax")
  local vibe_gain_def=$(cfg "振动增益" | sed 's/%%//g; s/%//g')
  [ -z "$vibe_gain_def" ] && vibe_gain_def=168
  local vibe_dur_def=$(cfg "振动时长" | sed 's/ms//g')
  [ -z "$vibe_dur_def" ] && vibe_dur_def=18
  local vibe_vmax_def=$(cfg "振动上限")
  [ -z "$vibe_vmax_def" ] && vibe_vmax_def=128
  local perf_pending=0
  [ -f "$PERF_PENDING" ] && perf_pending=1
  local perf_profile=""
  [ -f "$PERF_PENDING" ] && perf_profile=$(cat "$PERF_PENDING" | awk '{print $2}')
  local cpu0_max=""
  [ -e /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq ] && cpu0_max=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)
  local cpu4_max=""
  [ -e /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq ] && cpu4_max=$(cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq)
  local cpu7_max=""
  [ -e /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq ] && cpu7_max=$(cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq)
  local gpu_max=""
  if [ -e /sys/class/kgsl/kgsl-3d0/devfreq/max_freq ]; then
    gpu_max=$(cat /sys/class/kgsl/kgsl-3d0/devfreq/max_freq)
  elif [ -e /sys/class/kgsl/kgsl-3d0/max_clock_mhz ]; then
    gpu_max=$(( $(cat /sys/class/kgsl/kgsl-3d0/max_clock_mhz 2>/dev/null) * 1000000 ))
  elif [ -e "$GPU_MAX_CLOCK" ]; then
    gpu_max=$(( $(cat "$GPU_MAX_CLOCK" 2>/dev/null) * 1000000 ))
  fi
  local cpu_gov=""
  [ -e /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ] && cpu_gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
  local cpu_avail_gov=""
  if [ -e /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors ]; then
    cpu_avail_gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors | sed 's/ *$//;s/ /,/g')
  fi
  local cpu0_hw_max="" cpu4_hw_max="" cpu7_hw_max="" gpu_hw_max=""
  local cpu0_hw_min="" cpu4_hw_min="" cpu7_hw_min="" gpu_hw_min=""
  local cluster_count=0
  for d in /sys/devices/system/cpu/cpufreq/policy*; do
    [ -d "$d" ] && cluster_count=$((cluster_count + 1))
  done
  local a=""
  local hw_min="" hw_max="" st=""
  #CPU：读取+合成（优先真实档位表，其次按100MHz合成）
  for c in cpu0 cpu4 cpu7; do
    hw_min=""; hw_max=""; st=""
    #优先使用cpuinfo_max_freq/min_freq
    a=$(cat /sys/devices/system/cpu/$c/cpufreq/cpuinfo_max_freq 2>/dev/null)
    [ -n "$a" ] && hw_max=$a
    a=$(cat /sys/devices/system/cpu/$c/cpufreq/cpuinfo_min_freq 2>/dev/null)
    [ -n "$a" ] && hw_min=$a
    #真实档位表：scaling_available_frequencies（精确，优先用于Picker）
    a=$(cat /sys/devices/system/cpu/$c/cpufreq/scaling_available_frequencies 2>/dev/null)
    if [ -n "$a" ]; then
      st=$(echo $a | tr ' ' ',')
      hw_max=$(echo $a | awk '{print $NF}')
      hw_min=$(echo $a | awk '{print $1}')
    else
      [ -z "$hw_min" ] && hw_min=$(echo $a | awk '{print $1}')
      [ -z "$hw_max" ] && hw_max=$(echo $a | awk '{print $NF}')
      if [ -n "$hw_min" ] && [ -n "$hw_max" ] && [ "$hw_min" -gt 0 ]; then
        step=$hw_min
        while [ "$step" -le "$hw_max" ]; do
          st="${st}${step},"
          step=$((step + 100000))
        done
        st="${st%,}"
      fi
    fi
    case $c in
      cpu0)
        cpu0_hw_min=$hw_min; cpu0_hw_max=$hw_max; cpu0_steps=$st ;;
      cpu4)
        cpu4_hw_min=$hw_min; cpu4_hw_max=$hw_max; cpu4_steps=$st ;;
      cpu7)
        cpu7_hw_min=$hw_min; cpu7_hw_max=$hw_max; cpu7_steps=$st ;;
    esac
  done
  # GPU：读取+合成（兼容 SM8650 旧接口 / SM8750 新 MHz 接口 / 红魔节点）
  gpu_hw_min=""; gpu_hw_max=""; gpu_steps=""
  a=$(cat "$GPU_FREQ_TABLE" 2>/dev/null)
  if [ -z "$a" ]; then
    a=$(cat /sys/class/kgsl/kgsl-3d0/freq_table_mhz 2>/dev/null)
  fi
  if [ -n "$a" ]; then
    gpu_hw_min=$(echo $a | tr ' ' '\n' | sort -n | head -1)
    gpu_hw_max=$(echo $a | tr ' ' '\n' | sort -n | tail -1)
    gpu_steps=$(echo $a | tr ' ' '\n' | sort -n | sed 's/$/000000/' | tr '\n' ',' | sed 's/,$//')
    gpu_hw_min=$((gpu_hw_min * 1000000))
    gpu_hw_max=$((gpu_hw_max * 1000000))
  else
    a=$(cat /sys/class/kgsl/kgsl-3d0/devfreq/available_frequencies 2>/dev/null)
    if [ -n "$a" ]; then
      gpu_hw_min=$(echo $a | tr ' ' '\n' | sort -n | head -1); gpu_hw_max=$(echo $a | tr ' ' '\n' | sort -n | tail -1); gpu_steps=$(echo $a | tr ' ' '\n' | sort -n | tr '\n' ',' | sed 's/,$//')
    else
      gpu_hw_min=$(cat /sys/class/kgsl/kgsl-3d0/devfreq/min_freq 2>/dev/null)
      gpu_hw_max=$(cat /sys/class/kgsl/kgsl-3d0/devfreq/max_freq 2>/dev/null)
      if [ -n "$gpu_hw_min" ] && [ -n "$gpu_hw_max" ] && [ "$gpu_hw_min" -gt 0 ]; then
        gpu_steps="" ; step=$gpu_hw_min
        while [ "$step" -le "$gpu_hw_max" ]; do
          gpu_steps="${gpu_steps}${step},"
          step=$((step + 100000000))
        done
        gpu_steps="${gpu_steps%,}"
      fi
    fi
  fi
  local cpu_cur=""
  [ -e /sys/devices/system/cpu/cpu7/cpufreq/scaling_cur_freq ] && cpu_cur=$(cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_cur_freq)
  local gpu_cur=""
  if [ -e /sys/class/kgsl/kgsl-3d0/devfreq/cur_freq ]; then
    gpu_cur=$(cat /sys/class/kgsl/kgsl-3d0/devfreq/cur_freq)
  elif [ -e /sys/class/kgsl/kgsl-3d0/clock_mhz ]; then
    gpu_cur=$(( $(cat /sys/class/kgsl/kgsl-3d0/clock_mhz 2>/dev/null) * 1000000 ))
  elif [ -e /sys/kernel/gpu/gpu_clock ]; then
    gpu_cur=$(( $(cat /sys/kernel/gpu/gpu_clock 2>/dev/null) * 1000000 ))
  fi
  local perf_enabled=0
  [ -f "$AUTO_PERF_FILE" ] && perf_enabled=1
  local thermal_enabled=0
  [ "$(cfg '温控移除')" = "1" ] && thermal_enabled=1
  local pump_available=0
  if [ -e /proc/driver/micropump/speed ]; then
    pump_available=1
  else
    case "$(getprop ro.product.model)" in NX[89]*) pump_available=1;; esac
  fi
  local pump_level=""
  if [ -e /proc/driver/micropump/speed ]; then
    local pump_speed=$(cat /proc/driver/micropump/speed 2>/dev/null)
    case "$pump_speed" in
      40) pump_level=1;; 60) pump_level=2;; 80) pump_level=3;; 90) pump_level=4;;
    esac
  fi
  local auto_pump=0
  [ -f "$MODDIR/auto_pump" ] && auto_pump=1
  echo "{\"battery\":\"${bat}\",\"temp_deg\":\"${temp_deg}\",\"power\":\"${power}\",\"cs\":\"${cs}\",\"threshold\":\"${threshold}\",\"auto_charge\":${auto_charge},\"charge_enabled\":${charge_enabled},\"fan_level\":\"${fan_level}\",\"auto_fan\":${auto_fan},\"auto_fan_screen_off\":${auto_fan_screen_off},\"temp_control\":${temp_ctrl},\"temp_ctrl_mode\":\"${temp_ctrl_mode}\",\"temp_ctrl_threshold\":\"${temp_ctrl_threshold}\",\"fan_enabled\":${fan_enabled},\"touch_enabled\":${touch_enabled},\"touch_boost\":${touch_boost},\"touch_mode\":\"${touch_mode}\",\"touch_apps\":\"${touch_apps}\",\"vibe_enabled\":${vibe_enabled},\"auto_vibe\":${auto_vibe},\"vibe_gain\":\"${vibe_gain}\",\"vibe_duration\":\"${vibe_duration}\",\"vibe_vmax\":\"${vibe_vmax}\",\"vibe_gain_def\":\"${vibe_gain_def}\",\"vibe_dur_def\":\"${vibe_dur_def}\",\"vibe_vmax_def\":\"${vibe_vmax_def}\",\"pump_available\":${pump_available},\"pump_level\":\"${pump_level}\",\"auto_pump\":${auto_pump},\"perf_pending\":${perf_pending},\"perf_profile\":\"${perf_profile}\",\"perf_enabled\":${perf_enabled},\"thermal_enabled\":${thermal_enabled},\"cluster_count\":${cluster_count},\"cpu0_max\":\"${cpu0_max}\",\"cpu4_max\":\"${cpu4_max}\",\"cpu7_max\":\"${cpu7_max}\",\"gpu_max\":\"${gpu_max}\",\"cpu_cur\":\"${cpu_cur}\",\"gpu_cur\":\"${gpu_cur}\",\"cpu_gov\":\"${cpu_gov}\",\"cpu_avail_gov\":\"${cpu_avail_gov}\",\"cpu0_hw_min\":\"${cpu0_hw_min}\",\"cpu0_hw_max\":\"${cpu0_hw_max}\",\"cpu4_hw_min\":\"${cpu4_hw_min}\",\"cpu4_hw_max\":\"${cpu4_hw_max}\",\"cpu7_hw_min\":\"${cpu7_hw_min}\",\"cpu7_hw_max\":\"${cpu7_hw_max}\",\"gpu_hw_min\":\"${gpu_hw_min}\",\"gpu_hw_max\":\"${gpu_hw_max}\",\"cpu0_steps\":\"${cpu0_steps}\",\"cpu4_steps\":\"${cpu4_steps}\",\"cpu7_steps\":\"${cpu7_steps}\",\"gpu_steps\":\"${gpu_steps}\"}" > "$WEBUI_STATUS"
}

PERF_KILL_PID=""

perf_hold_once() {
    [ -f "$PERF_PENDING" ] || return
    [ -f "$PERF_TARGET" ] || return
    h_cpu0=$(cat "$PERF_TARGET" | cut -d'|' -f1)
    h_cpu4=$(cat "$PERF_TARGET" | cut -d'|' -f2)
    h_cpu7=$(cat "$PERF_TARGET" | cut -d'|' -f3)
    h_gpu=$(cat "$PERF_TARGET" | cut -d'|' -f4)
    h_gov=$(cat "$PERF_TARGET" | cut -d'|' -f5)
    [ -z "$h_cpu0" ] && [ -z "$h_gpu" ] && return
    for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq /sys/class/kgsl/kgsl-3d0/devfreq/max_freq /sys/class/kgsl/kgsl-3d0/devfreq/min_freq /sys/class/kgsl/kgsl-3d0/max_clock_mhz /sys/class/kgsl/kgsl-3d0/min_clock_mhz "$GPU_MAX_CLOCK" "$GPU_MIN_CLOCK"; do
        chmod 644 "$f" 2>/dev/null
    done
    for i in 0 1 2 3; do
        [ -e "/sys/kernel/cpu_max_freq_ceiling_cluster$i" ] && chmod 644 "/sys/kernel/cpu_max_freq_ceiling_cluster$i" 2>/dev/null
        [ -e "/sys/kernel/cpu_max_freq_limit_cluster$i" ] && chmod 644 "/sys/kernel/cpu_max_freq_limit_cluster$i" 2>/dev/null
        [ -e "/sys/kernel/cpu_min_freq_limit_cluster$i" ] && chmod 644 "/sys/kernel/cpu_min_freq_limit_cluster$i" 2>/dev/null
    done
    [ -n "$h_cpu0" ] && echo "$h_cpu0" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null
    [ -n "$h_cpu4" ] && echo "$h_cpu4" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 2>/dev/null
    [ -n "$h_cpu7" ] && echo "$h_cpu7" > /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq 2>/dev/null
    [ -n "$h_cpu0" ] && echo "$h_cpu0" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 2>/dev/null
    [ -n "$h_cpu4" ] && echo "$h_cpu4" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq 2>/dev/null
    [ -n "$h_cpu7" ] && echo "$h_cpu7" > /sys/devices/system/cpu/cpu7/cpufreq/scaling_min_freq 2>/dev/null
    [ -n "$h_gpu" ] && gpu_write_max "$h_gpu"
    [ -n "$h_gov" ] && for c in /sys/devices/system/cpu/cpu*/cpufreq; do echo "$h_gov" > "$c/scaling_governor" 2>/dev/null; done
    for i in 0 1 2 3; do
        [ -e "/sys/kernel/cpu_max_freq_ceiling_cluster$i" ] && echo 99999 > "/sys/kernel/cpu_max_freq_ceiling_cluster$i" 2>/dev/null
        [ -e "/sys/kernel/cpu_max_freq_limit_cluster$i" ] && echo 99999999 > "/sys/kernel/cpu_max_freq_limit_cluster$i" 2>/dev/null
        [ -e "/sys/kernel/cpu_min_freq_limit_cluster$i" ] && echo 0 > "/sys/kernel/cpu_min_freq_limit_cluster$i" 2>/dev/null
    done
    # 11Pro GPU pwrlevel 解锁（pwrlevel 0=最高频）
    [ -e /sys/kernel/gpu_max_pwrlevel_limit ] && echo 0 > /sys/kernel/gpu_max_pwrlevel_limit 2>/dev/null
    [ -e /sys/kernel/gpu_min_pwrlevel_limit ] && echo 17 > /sys/kernel/gpu_min_pwrlevel_limit 2>/dev/null
    for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq; do
        chmod 444 "$f" 2>/dev/null
    done
}

perf_kill_loop() {
    while true; do
        ps -A -o pid,comm 2>/dev/null | grep -E 'thermal-engine|thermal-hal|thermal-service|perfservice|perf2-hal|limits@|mpdecision|msm_perf' | awk '{print $1}' | while read p; do kill -9 $p 2>/dev/null; done
        ps -A -o pid,name 2>/dev/null | grep -E 'thermald|thermalbridge|android.hardware.thermal' | awk '{print $1}' | while read p; do kill -9 $p 2>/dev/null; done
        sleep 5
    done
}

perf_start_kill() {
    perf_stop_kill
    perf_kill_loop &
    PERF_KILL_PID=$!
}

perf_stop_kill() {
    [ -n "$PERF_KILL_PID" ] && kill -9 $PERF_KILL_PID 2>/dev/null
    PERF_KILL_PID=""
}

gpu_write_max() {
  local v="$1"
  if [ -e /sys/class/kgsl/kgsl-3d0/devfreq/max_freq ]; then
    echo "$v" > /sys/class/kgsl/kgsl-3d0/devfreq/max_freq 2>/dev/null
  elif [ -e /sys/class/kgsl/kgsl-3d0/max_clock_mhz ]; then
    echo $((v / 1000000)) > /sys/class/kgsl/kgsl-3d0/max_clock_mhz 2>/dev/null
  elif [ -e "$GPU_MAX_CLOCK" ]; then
    echo $((v / 1000000)) > "$GPU_MAX_CLOCK" 2>/dev/null
  fi
}

gpu_write_min() {
  local v="$1"
  if [ -e /sys/class/kgsl/kgsl-3d0/devfreq/min_freq ]; then
    echo "$v" > /sys/class/kgsl/kgsl-3d0/devfreq/min_freq 2>/dev/null
  elif [ -e /sys/class/kgsl/kgsl-3d0/min_clock_mhz ]; then
    echo $((v / 1000000)) > /sys/class/kgsl/kgsl-3d0/min_clock_mhz 2>/dev/null
  elif [ -e "$GPU_MIN_CLOCK" ]; then
    echo $((v / 1000000)) > "$GPU_MIN_CLOCK" 2>/dev/null
  fi
}

gpu_freq_chmod() {
  for f in /sys/class/kgsl/kgsl-3d0/devfreq/max_freq /sys/class/kgsl/kgsl-3d0/devfreq/min_freq /sys/class/kgsl/kgsl-3d0/max_clock_mhz /sys/class/kgsl/kgsl-3d0/min_clock_mhz "$GPU_MAX_CLOCK" "$GPU_MIN_CLOCK"; do
    chmod 644 "$f" 2>/dev/null
  done
}

perf_apply_internal() {
    local cpu0="$1" cpu4="$2" cpu7="$3" gpu="$4" gov="$5" name="$6"
    local cur_cpu0=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null)
    local cur_cpu4=$(cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 2>/dev/null)
    local cur_cpu7=$(cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq 2>/dev/null)
    local cur_gpu=$(cat /sys/class/kgsl/kgsl-3d0/devfreq/max_freq 2>/dev/null)
    [ -z "$cur_gpu" ] && [ -e /sys/class/kgsl/kgsl-3d0/max_clock_mhz ] && cur_gpu=$(( $(cat /sys/class/kgsl/kgsl-3d0/max_clock_mhz 2>/dev/null) * 1000000 ))
    [ -z "$cur_gpu" ] && [ -e "$GPU_MAX_CLOCK" ] && cur_gpu=$(( $(cat "$GPU_MAX_CLOCK" 2>/dev/null) * 1000000 ))
    local cur_cpu0_min=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 2>/dev/null)
    local cur_cpu4_min=$(cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq 2>/dev/null)
    local cur_cpu7_min=$(cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_min_freq 2>/dev/null)
    local cur_gpu_min=$(cat /sys/class/kgsl/kgsl-3d0/devfreq/min_freq 2>/dev/null)
    [ -z "$cur_gpu_min" ] && [ -e /sys/class/kgsl/kgsl-3d0/min_clock_mhz ] && cur_gpu_min=$(( $(cat /sys/class/kgsl/kgsl-3d0/min_clock_mhz 2>/dev/null) * 1000000 ))
    [ -z "$cur_gpu_min" ] && [ -e "$GPU_MIN_CLOCK" ] && cur_gpu_min=$(( $(cat "$GPU_MIN_CLOCK" 2>/dev/null) * 1000000 ))
    local cur_gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)
    echo "{\"cpu0_max\":\"$cur_cpu0\",\"cpu4_max\":\"$cur_cpu4\",\"cpu7_max\":\"$cur_cpu7\",\"gpu_max\":\"$cur_gpu\",\"cpu0_min\":\"$cur_cpu0_min\",\"cpu4_min\":\"$cur_cpu4_min\",\"cpu7_min\":\"$cur_cpu7_min\",\"gpu_min\":\"$cur_gpu_min\",\"gov\":\"$cur_gov\"}" > "$PERF_BACKUP"
    [ -n "$cpu0" ] && echo "$cpu0" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null
    [ -n "$cpu4" ] && echo "$cpu4" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 2>/dev/null
    [ -n "$cpu7" ] && echo "$cpu7" > /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq 2>/dev/null
    [ -n "$gpu" ] && gpu_write_max "$gpu"
    for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq /sys/class/kgsl/kgsl-3d0/devfreq/max_freq /sys/class/kgsl/kgsl-3d0/devfreq/min_freq /sys/class/kgsl/kgsl-3d0/max_clock_mhz /sys/class/kgsl/kgsl-3d0/min_clock_mhz "$GPU_MAX_CLOCK" "$GPU_MIN_CLOCK"; do
      chmod 644 "$f" 2>/dev/null
    done
    perf_start_kill
    [ -n "$cpu0" ] && echo "$cpu0" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null && chmod 444 /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null
    [ -n "$cpu0" ] && echo "$cpu0" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 2>/dev/null && chmod 444 /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 2>/dev/null
    [ -n "$cpu4" ] && echo "$cpu4" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 2>/dev/null && chmod 444 /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 2>/dev/null
    [ -n "$cpu4" ] && echo "$cpu4" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq 2>/dev/null && chmod 444 /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq 2>/dev/null
    [ -n "$cpu7" ] && echo "$cpu7" > /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq 2>/dev/null && chmod 444 /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq 2>/dev/null
    [ -n "$cpu7" ] && echo "$cpu7" > /sys/devices/system/cpu/cpu7/cpufreq/scaling_min_freq 2>/dev/null && chmod 444 /sys/devices/system/cpu/cpu7/cpufreq/scaling_min_freq 2>/dev/null
    if [ -n "$gpu" ]; then
      gpu_write_max "$gpu"
      chmod 444 /sys/class/kgsl/kgsl-3d0/max_clock_mhz 2>/dev/null
      chmod 444 /sys/class/kgsl/kgsl-3d0/devfreq/max_freq 2>/dev/null
      gpu_write_min "$gpu"
      chmod 444 /sys/class/kgsl/kgsl-3d0/min_clock_mhz 2>/dev/null
      chmod 444 /sys/class/kgsl/kgsl-3d0/devfreq/min_freq 2>/dev/null
    fi
    if [ -n "$gov" ]; then
        for c in /sys/devices/system/cpu/cpu*/cpufreq; do
            echo "$gov" > "$c/scaling_governor" 2>/dev/null
        done
    fi
    echo "$cpu0|$cpu4|$cpu7|$gpu|$gov" > "$PERF_TARGET"
    perf_hold_once
    echo "$(date +%s) $name" > "$PERF_PENDING"
}

perf_restore_now() {
    perf_stop_kill
    for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq /sys/class/kgsl/kgsl-3d0/devfreq/max_freq /sys/class/kgsl/kgsl-3d0/devfreq/min_freq /sys/class/kgsl/kgsl-3d0/max_clock_mhz /sys/class/kgsl/kgsl-3d0/min_clock_mhz "$GPU_MAX_CLOCK" "$GPU_MIN_CLOCK"; do chmod 644 "$f" 2>/dev/null; done
    if [ -f "$PERF_BACKUP" ]; then
        local r_cpu0=$(grep -o '"cpu0_max":"[^"]*"' "$PERF_BACKUP" | sed 's/.*:"\([^"]*\)"/\1/')
        local r_cpu4=$(grep -o '"cpu4_max":"[^"]*"' "$PERF_BACKUP" | sed 's/.*:"\([^"]*\)"/\1/')
        local r_cpu7=$(grep -o '"cpu7_max":"[^"]*"' "$PERF_BACKUP" | sed 's/.*:"\([^"]*\)"/\1/')
        local r_gpu=$(grep -o '"gpu_max":"[^"]*"' "$PERF_BACKUP" | sed 's/.*:"\([^"]*\)"/\1/')
        local r_cpu0_min=$(grep -o '"cpu0_min":"[^"]*"' "$PERF_BACKUP" | sed 's/.*:"\([^"]*\)"/\1/')
        local r_cpu4_min=$(grep -o '"cpu4_min":"[^"]*"' "$PERF_BACKUP" | sed 's/.*:"\([^"]*\)"/\1/')
        local r_cpu7_min=$(grep -o '"cpu7_min":"[^"]*"' "$PERF_BACKUP" | sed 's/.*:"\([^"]*\)"/\1/')
        local r_gpu_min=$(grep -o '"gpu_min":"[^"]*"' "$PERF_BACKUP" | sed 's/.*:"\([^"]*\)"/\1/')
        local r_gov=$(grep -o '"gov":"[^"]*"' "$PERF_BACKUP" | sed 's/.*:"\([^"]*\)"/\1/')
        [ -n "$r_cpu0" ] && echo "$r_cpu0" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null
        [ -n "$r_cpu4" ] && echo "$r_cpu4" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 2>/dev/null
        [ -n "$r_cpu7" ] && echo "$r_cpu7" > /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq 2>/dev/null
        [ -n "$r_cpu0_min" ] && echo "$r_cpu0_min" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 2>/dev/null
        [ -n "$r_cpu4_min" ] && echo "$r_cpu4_min" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq 2>/dev/null
        [ -n "$r_cpu7_min" ] && echo "$r_cpu7_min" > /sys/devices/system/cpu/cpu7/cpufreq/scaling_min_freq 2>/dev/null
        [ -n "$r_gpu" ] && gpu_write_max "$r_gpu"
        [ -n "$r_gpu_min" ] && gpu_write_min "$r_gpu_min"
        if [ -n "$r_gov" ]; then
            for c in /sys/devices/system/cpu/cpu*/cpufreq; do
                echo "$r_gov" > "$c/scaling_governor" 2>/dev/null
            done
        fi
    fi
    rm -f "$PERF_PENDING" "$PERF_BACKUP" "$PERF_TARGET"
}

perf_reset_now() {
    perf_stop_kill
    for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq /sys/class/kgsl/kgsl-3d0/devfreq/max_freq /sys/class/kgsl/kgsl-3d0/devfreq/min_freq /sys/class/kgsl/kgsl-3d0/max_clock_mhz /sys/class/kgsl/kgsl-3d0/min_clock_mhz "$GPU_MAX_CLOCK" "$GPU_MIN_CLOCK"; do chmod 644 "$f" 2>/dev/null; done
    echo 2265600 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null
    echo 3148800 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 2>/dev/null
    echo 3052800 > /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq 2>/dev/null
    gpu_write_max 903000000
    for c in /sys/devices/system/cpu/cpu*/cpufreq; do
        echo schedutil > "$c/scaling_governor" 2>/dev/null
    done
    for c in /sys/devices/system/cpu/cpu*/cpufreq; do
        echo 0 > "$c/scaling_min_freq" 2>/dev/null
    done
    gpu_write_min 231000000
    rm -f "$PERF_PENDING" "$PERF_BACKUP" "$PERF_TARGET" "$AUTO_PERF_FILE"
}

webui_loop() {
    local TC_COUNT=0
    local PC_COUNT=0
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
              su system -c "chmod 644 $FAN_LEVEL $FAN_ENABLE 2>/dev/null; echo 1 > $FAN_ENABLE; echo 5 > $FAN_LEVEL; chmod 444 $FAN_LEVEL" 2>/dev/null
            else
              rm -f "$AUTO_FAN_FILE"
              su system -c "chmod 644 $FAN_ENABLE 2>/dev/null; echo 0 > $FAN_ENABLE" 2>/dev/null
            fi
            ;;
          auto_fan_screen_off)
            if [ "$value" = "on" ]; then
              touch "$FAN_SCREEN_OFF_FILE"
            else
              rm -f "$FAN_SCREEN_OFF_FILE"
            fi
            ;;
          temp_control)
            if [ "$value" = "off" ]; then
              rm -f "$TEMP_CTRL_FILE" "$TEMP_CTRL_MODE_FILE" "$TEMP_CTRL_THRESHOLD_FILE"
              su system -c "chmod 644 $FAN_ENABLE 2>/dev/null; echo 0 > $FAN_ENABLE" 2>/dev/null
            elif [ "$value" = "auto" ]; then
              touch "$TEMP_CTRL_FILE"
              echo "auto" > "$TEMP_CTRL_MODE_FILE"
            else
              tc_mode=$(echo "$value" | cut -d'|' -f1)
              tc_thr=$(echo "$value" | cut -d'|' -f2)
              if [ "$tc_mode" = "custom" ] && [ -n "$tc_thr" ]; then
                touch "$TEMP_CTRL_FILE"
                echo "custom" > "$TEMP_CTRL_MODE_FILE"
                echo "$tc_thr" > "$TEMP_CTRL_THRESHOLD_FILE"
              fi
            fi
            ;;
          fan_level)
            if [ -n "$value" ] && [ -e "$FAN_LEVEL" ]; then
              su system -c "chmod 644 $FAN_LEVEL 2>/dev/null; echo $value > $FAN_LEVEL; chmod 444 $FAN_LEVEL" 2>/dev/null
            fi
            ;;

          auto_charge)
            if [ "$value" = "on" ]; then
              touch "$AUTO_CHARGE_FILE"
            else
              rm -f "$AUTO_CHARGE_FILE"
              local cs_now=$(settings get global charge_separation_switch 2>/dev/null)
              if [ "$cs_now" = "1" ]; then
                settings put global charge_separation_switch 0
              fi
              tcfg=$(cfg "充电分离阈值")
              [ -n "$tcfg" ] && echo "$tcfg" > "$THRESHOLD_FILE" 2>/dev/null
            fi
            ;;
          threshold)
            [ -n "$value" ] && echo "$value" > "$THRESHOLD_FILE"
            ;;
          touch_mode)
            if [ "$value" = "perapp" ]; then
              echo "perapp" > "$TOUCH_MODE_FILE"
              [ -e /proc/touchscreen/tp_report_rate ] && { echo 1 > /proc/touchscreen/tp_report_rate; echo 0 > /proc/touchscreen/play_game; echo 1 > /proc/touchscreen/follow_hand_level; }
              settings delete system touch_sampling_rate 2>/dev/null
              rm -f "$MODDIR/.touch_active"
            else
              rm -f "$TOUCH_MODE_FILE"
              [ -f "$AUTO_TOUCH_FILE" ] && touch_boost
              rm -f "$MODDIR/.touch_active"
            fi
            ;;
          touch_apps)
            echo "$value" | tr "," "\n" | sed "s/^ *//;s/ *$//" > "$TOUCH_APPS_FILE"
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
          vibe_boost)
            if [ "$value" = "on" ]; then
              touch "$MODDIR/auto_vibe"
            else
              rm -f "$MODDIR/auto_vibe"
            fi
            ;;
          vibe_gain)
            echo "$value" > "$MODDIR/vibe_gain" 2>>"$ERRLOG"
            local cur_gain="" cur_dur="" cur_vmax=""
            [ -f "$MODDIR/vibe_gain" ] && cur_gain=$(cat "$MODDIR/vibe_gain")
            [ -f "$MODDIR/vibe_duration" ] && cur_dur=$(cat "$MODDIR/vibe_duration")
            [ -f "$MODDIR/vibe_vmax" ] && cur_vmax=$(cat "$MODDIR/vibe_vmax")
            [ -z "$cur_gain" ] && cur_gain=$(cfg "振动增益" | sed 's/%%//g; s/%//g')
            [ -z "$cur_dur" ] && cur_dur=$(cfg "振动时长" | sed 's/ms//g')
            [ -z "$cur_vmax" ] && cur_vmax=$(cfg "振动上限")
            [ -z "$cur_gain" ] && cur_gain=168
            [ -z "$cur_dur" ] && cur_dur=18
            [ -z "$cur_vmax" ] && cur_vmax=128
            local VIBE=/sys/class/leds/vibrator
            [ -e "$VIBE/gain" ] && printf 0x%x "$cur_gain" > $VIBE/gain 2>>"$ERRLOG"
            [ -e "$VIBE/duration_aw" ] && printf 0x%x "$cur_dur" > $VIBE/duration_aw 2>>"$ERRLOG"
            [ -e "$VIBE/vmax" ] && printf 0x%x "$cur_vmax" > $VIBE/vmax 2>>"$ERRLOG"
            ;;
          vibe_duration)
            echo "$value" > "$MODDIR/vibe_duration" 2>>"$ERRLOG"
            local cur_gain="" cur_dur="" cur_vmax=""
            [ -f "$MODDIR/vibe_gain" ] && cur_gain=$(cat "$MODDIR/vibe_gain")
            [ -f "$MODDIR/vibe_duration" ] && cur_dur=$(cat "$MODDIR/vibe_duration")
            [ -f "$MODDIR/vibe_vmax" ] && cur_vmax=$(cat "$MODDIR/vibe_vmax")
            [ -z "$cur_gain" ] && cur_gain=$(cfg "振动增益" | sed 's/%%//g; s/%//g')
            [ -z "$cur_dur" ] && cur_dur=$(cfg "振动时长" | sed 's/ms//g')
            [ -z "$cur_vmax" ] && cur_vmax=$(cfg "振动上限")
            [ -z "$cur_gain" ] && cur_gain=168
            [ -z "$cur_dur" ] && cur_dur=18
            [ -z "$cur_vmax" ] && cur_vmax=128
            local VIBE=/sys/class/leds/vibrator
            [ -e "$VIBE/gain" ] && printf 0x%x "$cur_gain" > $VIBE/gain 2>>"$ERRLOG"
            [ -e "$VIBE/duration_aw" ] && printf 0x%x "$cur_dur" > $VIBE/duration_aw 2>>"$ERRLOG"
            [ -e "$VIBE/vmax" ] && printf 0x%x "$cur_vmax" > $VIBE/vmax 2>>"$ERRLOG"
            ;;
          vibe_vmax)
            echo "$value" > "$MODDIR/vibe_vmax" 2>>"$ERRLOG"
            local cur_gain="" cur_dur="" cur_vmax=""
            [ -f "$MODDIR/vibe_gain" ] && cur_gain=$(cat "$MODDIR/vibe_gain")
            [ -f "$MODDIR/vibe_duration" ] && cur_dur=$(cat "$MODDIR/vibe_duration")
            [ -f "$MODDIR/vibe_vmax" ] && cur_vmax=$(cat "$MODDIR/vibe_vmax")
            [ -z "$cur_gain" ] && cur_gain=$(cfg "振动增益" | sed 's/%%//g; s/%//g')
            [ -z "$cur_dur" ] && cur_dur=$(cfg "振动时长" | sed 's/ms//g')
            [ -z "$cur_vmax" ] && cur_vmax=$(cfg "振动上限")
            [ -z "$cur_gain" ] && cur_gain=168
            [ -z "$cur_dur" ] && cur_dur=18
            [ -z "$cur_vmax" ] && cur_vmax=128
            local VIBE=/sys/class/leds/vibrator
            [ -e "$VIBE/gain" ] && printf 0x%x "$cur_gain" > $VIBE/gain 2>>"$ERRLOG"
            [ -e "$VIBE/duration_aw" ] && printf 0x%x "$cur_dur" > $VIBE/duration_aw 2>>"$ERRLOG"
            [ -e "$VIBE/vmax" ] && printf 0x%x "$cur_vmax" > $VIBE/vmax 2>>"$ERRLOG"
            ;;
          auto_pump)
            if [ "$value" = "on" ]; then
              touch "$MODDIR/auto_pump"
            else
              rm -f "$MODDIR/auto_pump"
              echo 0 > /proc/driver/micropump/enable 2>/dev/null
            fi
            ;;
          pump_level)
            if [ -n "$value" ] && [ "$value" -ge 1 ] && [ "$value" -le 4 ]; then
              local pump_speed_val
              case "$value" in
                1) pump_speed_val=40;; 2) pump_speed_val=60;; 3) pump_speed_val=80;; 4) pump_speed_val=90;;
              esac
              su system -c "chmod 644 /proc/driver/micropump/enable /proc/driver/micropump/freq /proc/driver/micropump/speed 2>/dev/null; echo 1 > /proc/driver/micropump/enable; echo 4 > /proc/driver/micropump/freq; echo $pump_speed_val > /proc/driver/micropump/speed; chmod 444 /proc/driver/micropump/speed" 2>/dev/null
            fi
            ;;
          perf_apply)
            local p_cpu0=$(echo "$value" | cut -d'|' -f1)
            local p_cpu4=$(echo "$value" | cut -d'|' -f2)
            local p_cpu7=$(echo "$value" | cut -d'|' -f3)
            local p_gpu=$(echo "$value" | cut -d'|' -f4)
            local p_gov=$(echo "$value" | cut -d'|' -f5)
            local p_name=$(echo "$value" | cut -d'|' -f6)
            [ -z "$p_name" ] && p_name="custom"
             perf_apply_internal "$p_cpu0" "$p_cpu4" "$p_cpu7" "$p_gpu" "$p_gov" "$p_name"
             ;;
           perf_restore)
            perf_restore_now
            ;;
          perf_reset)
            perf_reset_now
            ;;
          perf_enabled)
            if [ "$value" = "on" ]; then
              touch "$AUTO_PERF_FILE"
            else
              rm -f "$AUTO_PERF_FILE"
              perf_restore_now
            fi
            ;;
        esac
        rm -f "$WEBUI_CMD"
      fi
    fi
    if [ -f "$FAN_SCREEN_OFF_FILE" ] && [ -e "$FAN_ENABLE" ]; then
      if dumpsys power 2>/dev/null | grep -q 'mWakefulness=Awake'; then
        fe=$(cat "$FAN_ENABLE" 2>/dev/null)
        if [ "$fe" = "1" ]; then
          touch "$FAN_WAS_ON_FILE" 2>/dev/null
        else
          rm -f "$FAN_WAS_ON_FILE" 2>/dev/null
        fi
      else
        if [ -f "$FAN_WAS_ON_FILE" ]; then
          fe=$(cat "$FAN_ENABLE" 2>/dev/null)
          if [ "$fe" != "1" ]; then
            fan_lvl=$(cat "$FAN_LEVEL" 2>/dev/null)
            [ -z "$fan_lvl" ] && fan_lvl=5
            [ "$fan_lvl" -le 0 ] && fan_lvl=5
            su system -c "chmod 644 $FAN_ENABLE $FAN_LEVEL 2>/dev/null; echo 1 > $FAN_ENABLE; echo $fan_lvl > $FAN_LEVEL; chmod 444 $FAN_LEVEL" 2>/dev/null
          fi
        fi
      fi
    fi
    TC_COUNT=$((TC_COUNT + 1))
    if [ $((TC_COUNT % 3)) -eq 0 ]; then
      perf_hold_once
    fi
    if [ $((TC_COUNT % 5)) -eq 0 ] && [ -f "$TEMP_CTRL_FILE" ] && [ -e "$FAN_ENABLE" ]; then
      temp_raw=$(cat /sys/class/power_supply/battery/temp 2>/dev/null)
      if [ -n "$temp_raw" ]; then
        current_temp=$(awk "BEGIN{printf \"%d\", $temp_raw/10}")
        ctrl_mode="auto"
        [ -f "$TEMP_CTRL_MODE_FILE" ] && ctrl_mode=$(cat "$TEMP_CTRL_MODE_FILE")
        target_level=0
        if [ "$ctrl_mode" = "auto" ]; then
          if [ "$current_temp" -ge 40 ]; then target_level=5
          elif [ "$current_temp" -ge 35 ]; then target_level=4
          elif [ "$current_temp" -ge 30 ]; then target_level=3
          fi
        else
          ctrl_thr=40
          [ -f "$TEMP_CTRL_THRESHOLD_FILE" ] && ctrl_thr=$(cat "$TEMP_CTRL_THRESHOLD_FILE")
          if [ "$current_temp" -ge "$ctrl_thr" ]; then target_level=5; fi
        fi
        fe=$(cat "$FAN_ENABLE" 2>/dev/null)
        fl=$(cat "$FAN_LEVEL" 2>/dev/null)
        if [ "$target_level" -gt 0 ]; then
          if [ "$fe" != "1" ] || [ "$fl" != "$target_level" ]; then
            su system -c "chmod 644 $FAN_ENABLE $FAN_LEVEL 2>/dev/null; echo 1 > $FAN_ENABLE; echo $target_level > $FAN_LEVEL; chmod 444 $FAN_LEVEL" 2>/dev/null
          fi
        else
          if [ ! -f "$AUTO_FAN_FILE" ] && [ "$fe" = "1" ]; then
            su system -c "chmod 644 $FAN_ENABLE 2>/dev/null; echo 0 > $FAN_ENABLE" 2>/dev/null
          fi
        fi
      fi
    fi
    if [ "$(cfg '充电加速')" = "1" ]; then
      echo 0 > /sys/class/qcom-battery/screen_is_on 2>/dev/null
    fi
    PC_COUNT=$((PC_COUNT + 1))
    if [ -f "$CHECK_NOW" ] || [ "$PC_COUNT" -eq 120 ] || [ $((PC_COUNT % 3600)) -eq 0 ]; then
      patch_check
    fi
    webui_status
    sleep 1
  done
}

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
