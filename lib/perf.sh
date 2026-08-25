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
