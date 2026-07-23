#!/system/bin/sh

MODDIR=${0%/*}
mkdir -p /sdcard/FanExtreme 2>/dev/null
CONFIG="$MODDIR/config.txt"
ERRLOG="$MODDIR/.last_error"

:> "$ERRLOG"

cfg() {
    grep -o "^$1=.*" "$CONFIG" 2>/dev/null | cut -d= -f2 | tail -1
}

fan_extreme() {
    for i in $(seq 1 30); do
        [ -e /sys/kernel/fan/fan_speed_level ] && break
        sleep 2
    done
    if [ -e /sys/kernel/fan/fan_speed_level ]; then
        su system -c "echo 5 > /sys/kernel/fan/fan_speed_level" 2>>"$ERRLOG" || echo "[FAIL] fan_speed_level=$?" >>"$ERRLOG"
        chmod 444 /sys/kernel/fan/fan_speed_level 2>>"$ERRLOG"
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
    echo 0 > /sys/class/qcom-battery/restrict_cur 2>>"$ERRLOG" || echo "[FAIL] restrict_cur=$?" >>"$ERRLOG"
    echo 0 > /sys/class/qcom-battery/restrict_chg 2>>"$ERRLOG" || echo "[FAIL] restrict_chg=$?" >>"$ERRLOG"
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

# === 触控按应用模式 ===
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

# === WebUI ===
WEBUI_CMD="/sdcard/FanExtreme/webui_cmd"
WEBUI_STATUS="$MODDIR/webui_status"
THRESHOLD_FILE="/sdcard/FanExtreme/threshold"
AUTO_CHARGE_FILE="$MODDIR/auto_charge"
AUTO_FAN_FILE="$MODDIR/auto_fan"
AUTO_PERF_FILE="$MODDIR/perf_enabled"
PERF_BACKUP="$MODDIR/perf_backup"
PERF_PENDING="$MODDIR/perf_pending"

rm -f "$PERF_PENDING" "$PERF_BACKUP" 2>/dev/null
[ "$(cfg '充电分离')" = "1" ] && touch "$AUTO_CHARGE_FILE" 2>/dev/null
[ "$(cfg '风扇极速')" = "1" ] && touch "$AUTO_FAN_FILE" 2>/dev/null
[ "$(cfg '触控优化')" = "1" ] && touch "$AUTO_TOUCH_FILE" 2>/dev/null
[ "$(cfg '振动增强')" = "1" ] && touch "$MODDIR/auto_vibe" 2>/dev/null
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
  [ -e /sys/class/kgsl/kgsl-3d0/devfreq/max_freq ] && gpu_max=$(cat /sys/class/kgsl/kgsl-3d0/devfreq/max_freq)
  local cpu_gov=""
  [ -e /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ] && cpu_gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
  local cpu0_hw_max="" cpu4_hw_max="" cpu7_hw_max="" gpu_hw_max=""
  local cpu0_hw_min="" cpu4_hw_min="" cpu7_hw_min="" gpu_hw_min=""
  local a=""
  a=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies 2>/dev/null)
  [ -n "$a" ] && { cpu0_hw_min=$(echo $a | awk '{print $1}'); cpu0_hw_max=$(echo $a | awk '{print $NF}'); cpu0_steps=$(echo $a | tr " " ","); }
  a=$(cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_available_frequencies 2>/dev/null)
  [ -n "$a" ] && { cpu4_hw_min=$(echo $a | awk '{print $1}'); cpu4_hw_max=$(echo $a | awk '{print $NF}'); cpu4_steps=$(echo $a | tr " " ","); }
  a=$(cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_available_frequencies 2>/dev/null)
  [ -n "$a" ] && { cpu7_hw_min=$(echo $a | awk '{print $1}'); cpu7_hw_max=$(echo $a | awk '{print $NF}'); cpu7_steps=$(echo $a | tr " " ","); }
  a=$(cat /sys/class/kgsl/kgsl-3d0/devfreq/available_frequencies 2>/dev/null)
  [ -n "$a" ] && { gpu_hw_min=$(echo $a | tr ' ' '
' | sort -n | head -1); gpu_hw_max=$(echo $a | tr ' ' '
' | sort -n | tail -1); gpu_steps=$(echo $a | tr ' ' ','); }
  local cpu_cur=""
  [ -e /sys/devices/system/cpu/cpu7/cpufreq/scaling_cur_freq ] && cpu_cur=$(cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_cur_freq)
  local gpu_cur=""
  [ -e /sys/class/kgsl/kgsl-3d0/devfreq/cur_freq ] && gpu_cur=$(cat /sys/class/kgsl/kgsl-3d0/devfreq/cur_freq)
  local perf_enabled=0
  [ -f "$AUTO_PERF_FILE" ] && perf_enabled=1
  local thermal_enabled=0
  [ "$(cfg '温控移除')" = "1" ] && thermal_enabled=1
  echo "{\"battery\":\"${bat}\",\"temp_deg\":\"${temp_deg}\",\"power\":\"${power}\",\"cs\":\"${cs}\",\"threshold\":\"${threshold}\",\"auto_charge\":${auto_charge},\"charge_enabled\":${charge_enabled},\"fan_level\":\"${fan_level}\",\"auto_fan\":${auto_fan},\"fan_enabled\":${fan_enabled},\"touch_enabled\":${touch_enabled},\"touch_boost\":${touch_boost},\"touch_mode\":\"${touch_mode}\",\"touch_apps\":\"${touch_apps}\",\"vibe_enabled\":${vibe_enabled},\"auto_vibe\":${auto_vibe},\"vibe_gain\":\"${vibe_gain}\",\"vibe_duration\":\"${vibe_duration}\",\"vibe_vmax\":\"${vibe_vmax}\",\"vibe_gain_def\":\"${vibe_gain_def}\",\"vibe_dur_def\":\"${vibe_dur_def}\",\"vibe_vmax_def\":\"${vibe_vmax_def}\",\"perf_pending\":${perf_pending},\"perf_profile\":\"${perf_profile}\",\"perf_enabled\":${perf_enabled},\"thermal_enabled\":${thermal_enabled},\"cpu0_max\":\"${cpu0_max}\",\"cpu4_max\":\"${cpu4_max}\",\"cpu7_max\":\"${cpu7_max}\",\"gpu_max\":\"${gpu_max}\",\"cpu_cur\":\"${cpu_cur}\",\"gpu_cur\":\"${gpu_cur}\",\"cpu_gov\":\"${cpu_gov}\",\"cpu0_hw_min\":\"${cpu0_hw_min}\",\"cpu0_hw_max\":\"${cpu0_hw_max}\",\"cpu4_hw_min\":\"${cpu4_hw_min}\",\"cpu4_hw_max\":\"${cpu4_hw_max}\",\"cpu7_hw_min\":\"${cpu7_hw_min}\",\"cpu7_hw_max\":\"${cpu7_hw_max}\",\"gpu_hw_min\":\"${gpu_hw_min}\",\"gpu_hw_max\":\"${gpu_hw_max}\",\"cpu0_steps\":\"${cpu0_steps}\",\"cpu4_steps\":\"${cpu4_steps}\",\"cpu7_steps\":\"${cpu7_steps}\",\"gpu_steps\":\"${gpu_steps}\"}" > "$WEBUI_STATUS"
}

PERF_KILL_PID=""

perf_kill_loop() {
    while true; do
        ps -A -o pid,comm 2>/dev/null | grep -E 'thermal-engine|thermal-hal|perfservice|perf2-hal' | awk '{print $1}' | while read p; do kill -9 $p 2>/dev/null; done
        ps -A -o pid,name 2>/dev/null | grep -E 'thermald|thermalbridge' | awk '{print $1}' | while read p; do kill -9 $p 2>/dev/null; done
        sleep 0.1
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

perf_apply_internal() {
    local cpu0="$1" cpu4="$2" cpu7="$3" gpu="$4" gov="$5" name="$6"
    local cur_cpu0=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null)
    local cur_cpu4=$(cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 2>/dev/null)
    local cur_cpu7=$(cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq 2>/dev/null)
    local cur_gpu=$(cat /sys/class/kgsl/kgsl-3d0/devfreq/max_freq 2>/dev/null)
    local cur_cpu0_min=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 2>/dev/null)
    local cur_cpu4_min=$(cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq 2>/dev/null)
    local cur_cpu7_min=$(cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_min_freq 2>/dev/null)
    local cur_gpu_min=$(cat /sys/class/kgsl/kgsl-3d0/devfreq/min_freq 2>/dev/null)
    local cur_gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)
    echo "{\"cpu0_max\":\"$cur_cpu0\",\"cpu4_max\":\"$cur_cpu4\",\"cpu7_max\":\"$cur_cpu7\",\"gpu_max\":\"$cur_gpu\",\"cpu0_min\":\"$cur_cpu0_min\",\"cpu4_min\":\"$cur_cpu4_min\",\"cpu7_min\":\"$cur_cpu7_min\",\"gpu_min\":\"$cur_gpu_min\",\"gov\":\"$cur_gov\"}" > "$PERF_BACKUP"
    [ -n "$cpu0" ] && echo "$cpu0" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null
    [ -n "$cpu4" ] && echo "$cpu4" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 2>/dev/null
    [ -n "$cpu7" ] && echo "$cpu7" > /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq 2>/dev/null
    [ -n "$gpu" ] && echo "$gpu" > /sys/class/kgsl/kgsl-3d0/devfreq/max_freq 2>/dev/null
    if [ "$name" = "performance" ]; then
      perf_start_kill
      echo "$cpu0" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null && chmod 444 /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null
      echo "$cpu0" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 2>/dev/null && chmod 444 /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 2>/dev/null
      echo "$cpu4" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 2>/dev/null && chmod 444 /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 2>/dev/null
      echo "$cpu4" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq 2>/dev/null && chmod 444 /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq 2>/dev/null
      echo "$cpu7" > /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq 2>/dev/null && chmod 444 /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq 2>/dev/null
      echo "$cpu7" > /sys/devices/system/cpu/cpu7/cpufreq/scaling_min_freq 2>/dev/null && chmod 444 /sys/devices/system/cpu/cpu7/cpufreq/scaling_min_freq 2>/dev/null
      echo "$gpu" > /sys/class/kgsl/kgsl-3d0/devfreq/max_freq 2>/dev/null && chmod 444 /sys/class/kgsl/kgsl-3d0/devfreq/max_freq 2>/dev/null
      echo "$gpu" > /sys/class/kgsl/kgsl-3d0/devfreq/min_freq 2>/dev/null && chmod 444 /sys/class/kgsl/kgsl-3d0/devfreq/min_freq 2>/dev/null
    else
      perf_stop_kill
      for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq /sys/class/kgsl/kgsl-3d0/devfreq/max_freq /sys/class/kgsl/kgsl-3d0/devfreq/min_freq; do
        chmod 644 "$f" 2>/dev/null
      done
    fi
    if [ -n "$gov" ]; then
        for c in /sys/devices/system/cpu/cpu*/cpufreq; do
            echo "$gov" > "$c/scaling_governor" 2>/dev/null
        done
    fi
    echo "$(date +%s) $name" > "$PERF_PENDING"
}

perf_restore_now() {
    perf_stop_kill
    for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq /sys/class/kgsl/kgsl-3d0/devfreq/max_freq /sys/class/kgsl/kgsl-3d0/devfreq/min_freq; do chmod 644 "$f" 2>/dev/null; done
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
        [ -n "$r_gpu" ] && echo "$r_gpu" > /sys/class/kgsl/kgsl-3d0/devfreq/max_freq 2>/dev/null
        [ -n "$r_gpu_min" ] && echo "$r_gpu_min" > /sys/class/kgsl/kgsl-3d0/devfreq/min_freq 2>/dev/null
        if [ -n "$r_gov" ]; then
            for c in /sys/devices/system/cpu/cpu*/cpufreq; do
                echo "$r_gov" > "$c/scaling_governor" 2>/dev/null
            done
        fi
    fi
    rm -f "$PERF_PENDING" "$PERF_BACKUP"
}

perf_reset_now() {
    perf_stop_kill
    for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq /sys/class/kgsl/kgsl-3d0/devfreq/max_freq /sys/class/kgsl/kgsl-3d0/devfreq/min_freq; do chmod 644 "$f" 2>/dev/null; done
    echo 2265600 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null
    echo 3148800 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 2>/dev/null
    echo 3052800 > /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq 2>/dev/null
    echo 903000000 > /sys/class/kgsl/kgsl-3d0/devfreq/max_freq 2>/dev/null
    for c in /sys/devices/system/cpu/cpu*/cpufreq; do
        echo schedutil > "$c/scaling_governor" 2>/dev/null
    done
    for c in /sys/devices/system/cpu/cpu*/cpufreq; do
        echo 0 > "$c/scaling_min_freq" 2>/dev/null
    done
    echo 231000000 > /sys/class/kgsl/kgsl-3d0/devfreq/min_freq 2>/dev/null
    rm -f "$PERF_PENDING" "$PERF_BACKUP" "$AUTO_PERF_FILE"
}

webui_loop() {
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
              [ -e /sys/kernel/fan/fan_speed_level ] && chmod 644 /sys/kernel/fan/fan_speed_level 2>/dev/null && chmod 644 /sys/kernel/fan/fan_enable 2>/dev/null && echo 1 > /sys/kernel/fan/fan_enable && echo 5 > /sys/kernel/fan/fan_speed_level && chmod 444 /sys/kernel/fan/fan_speed_level 2>/dev/null
            else
              rm -f "$AUTO_FAN_FILE"
            fi
            ;;
          fan_level)
            if [ -n "$value" ] && [ -e /sys/kernel/fan/fan_speed_level ]; then
              chmod 644 /sys/kernel/fan/fan_speed_level 2>/dev/null
              echo "$value" > /sys/kernel/fan/fan_speed_level 2>/dev/null
              chmod 444 /sys/kernel/fan/fan_speed_level 2>/dev/null
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
          perf_apply)
            local p_cpu0=$(echo "$value" | cut -d'|' -f1)
            local p_cpu4=$(echo "$value" | cut -d'|' -f2)
            local p_cpu7=$(echo "$value" | cut -d'|' -f3)
            local p_gpu=$(echo "$value" | cut -d'|' -f4)
            local p_gov=$(echo "$value" | cut -d'|' -f5)
            local p_name=$(echo "$value" | cut -d'|' -f6)
            [ -z "$p_name" ] && p_name="custom"
            perf_apply_internal "$p_cpu0" "$p_cpu4" "$p_cpu7" "$p_gpu" "$p_gov" "$p_name"
            rm -f "$PERF_PENDING" "$PERF_BACKUP"
            ;;
          perf_confirm)
            rm -f "$PERF_PENDING" "$PERF_BACKUP"
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
    if [ -f "$PERF_PENDING" ]; then
      local ptime=$(cat "$PERF_PENDING" | head -1 | awk '{print $1}')
      local now=$(date +%s)
      if [ $((now - ptime)) -ge 30 ]; then
        perf_restore_now
      fi
    fi
    webui_status
    sleep 1
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
        else
          current=$(settings get global charge_separation_switch 2>/dev/null)
          if [ "$current" = "1" ]; then
            settings put global charge_separation_switch 0
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
