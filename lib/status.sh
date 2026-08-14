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
  [ -f "$AUTO_PUMP_FILE" ] && auto_pump=1
  local pump_temp_ctrl=0
  [ -f "$PUMP_TEMP_CTRL_FILE" ] && pump_temp_ctrl=1
  local pump_temp_ctrl_mode="auto"
  [ -f "$PUMP_TEMP_CTRL_MODE_FILE" ] && pump_temp_ctrl_mode=$(cat "$PUMP_TEMP_CTRL_MODE_FILE")
  local pump_temp_ctrl_threshold="40"
  [ -f "$PUMP_TEMP_CTRL_THRESHOLD_FILE" ] && pump_temp_ctrl_threshold=$(cat "$PUMP_TEMP_CTRL_THRESHOLD_FILE")
  echo "{\"battery\":\"${bat}\",\"temp_deg\":\"${temp_deg}\",\"power\":\"${power}\",\"cs\":\"${cs}\",\"threshold\":\"${threshold}\",\"auto_charge\":${auto_charge},\"charge_enabled\":${charge_enabled},\"fan_level\":\"${fan_level}\",\"auto_fan\":${auto_fan},\"auto_fan_screen_off\":${auto_fan_screen_off},\"temp_control\":${temp_ctrl},\"temp_ctrl_mode\":\"${temp_ctrl_mode}\",\"temp_ctrl_threshold\":\"${temp_ctrl_threshold}\",\"fan_enabled\":${fan_enabled},\"touch_enabled\":${touch_enabled},\"touch_boost\":${touch_boost},\"touch_mode\":\"${touch_mode}\",\"touch_apps\":\"${touch_apps}\",\"vibe_enabled\":${vibe_enabled},\"auto_vibe\":${auto_vibe},\"vibe_gain\":\"${vibe_gain}\",\"vibe_duration\":\"${vibe_duration}\",\"vibe_vmax\":\"${vibe_vmax}\",\"vibe_gain_def\":\"${vibe_gain_def}\",\"vibe_dur_def\":\"${vibe_dur_def}\",\"vibe_vmax_def\":\"${vibe_vmax_def}\",\"pump_available\":${pump_available},\"pump_level\":\"${pump_level}\",\"auto_pump\":${auto_pump},\"pump_temp_control\":${pump_temp_ctrl},\"pump_temp_ctrl_mode\":\"${pump_temp_ctrl_mode}\",\"pump_temp_ctrl_threshold\":\"${pump_temp_ctrl_threshold}\",\"perf_pending\":${perf_pending},\"perf_profile\":\"${perf_profile}\",\"perf_enabled\":${perf_enabled},\"thermal_enabled\":${thermal_enabled},\"cluster_count\":${cluster_count},\"cpu0_max\":\"${cpu0_max}\",\"cpu4_max\":\"${cpu4_max}\",\"cpu7_max\":\"${cpu7_max}\",\"gpu_max\":\"${gpu_max}\",\"cpu_cur\":\"${cpu_cur}\",\"gpu_cur\":\"${gpu_cur}\",\"cpu_gov\":\"${cpu_gov}\",\"cpu_avail_gov\":\"${cpu_avail_gov}\",\"cpu0_hw_min\":\"${cpu0_hw_min}\",\"cpu0_hw_max\":\"${cpu0_hw_max}\",\"cpu4_hw_min\":\"${cpu4_hw_min}\",\"cpu4_hw_max\":\"${cpu4_hw_max}\",\"cpu7_hw_min\":\"${cpu7_hw_min}\",\"cpu7_hw_max\":\"${cpu7_hw_max}\",\"gpu_hw_min\":\"${gpu_hw_min}\",\"gpu_hw_max\":\"${gpu_hw_max}\",\"cpu0_steps\":\"${cpu0_steps}\",\"cpu4_steps\":\"${cpu4_steps}\",\"cpu7_steps\":\"${cpu7_steps}\",\"gpu_steps\":\"${gpu_steps}\"}" > "$WEBUI_STATUS"
}
