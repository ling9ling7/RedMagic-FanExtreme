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
    perf_msm_apply "$h_cpu0" "$h_cpu4" "$h_cpu7"
    perf_therm_hold
    gpu_pwrlevel_hold
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
PERF_KILL_DAEMON="$MODDIR/.perf_kill_daemon"
perf_start_kill() {
    perf_stop_kill
    cat > "$PERF_KILL_DAEMON" <<'FEEOF'
while true; do
  ps -A -o pid,comm 2>/dev/null | grep -E 'thermal-engine|thermal-hal|thermal-service|perfservice|perf2-hal|limits@|mpdecision|msm_perf|zperfcube' | awk '{print $1}' | while read p; do kill -9 $p 2>/dev/null; done
  ps -A -o pid,name 2>/dev/null | grep -E 'thermald|thermalbridge|android.hardware.thermal' | awk '{print $1}' | while read p; do kill -9 $p 2>/dev/null; done
  sleep 5
done
FEEOF
    chmod 755 "$PERF_KILL_DAEMON" 2>/dev/null
    sh "$PERF_KILL_DAEMON" >/dev/null 2>&1 </dev/null &
    PERF_KILL_PID=$!
}
perf_stop_kill() {
    [ -n "$PERF_KILL_PID" ] && kill -9 "$PERF_KILL_PID" 2>/dev/null
    PERF_KILL_PID=""
    for p in $(ps -A -o pid,args 2>/dev/null | grep '[.]perf_kill_daemon' | awk '{print $1}'); do
        kill -9 "$p" 2>/dev/null
    done
    rm -f "$PERF_KILL_DAEMON" 2>/dev/null
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
PERF_GPU_PWR_BACKUP="$MODDIR/perf_gpu_pwr_backup"
gpu_pwrlevel_level() {
    local K=/sys/class/kgsl/kgsl-3d0
    local v="$1" lvl=0
    [ -n "$v" ] || { echo 0; return; }
    local want=$((v / 1000000)) tab idx=0 best=0 f
    tab=$(cat "$K/freq_table_mhz" 2>/dev/null)
    [ -n "$tab" ] && for f in $tab; do
        [ "$f" -le "$want" ] && [ "$f" -ge "$best" ] && { best=$f; lvl=$idx; }
        idx=$((idx+1))
    done
    echo "$lvl"
}
gpu_pwrlevel_pin() {
    local K=/sys/class/kgsl/kgsl-3d0
    [ -e "$K/pwrscale" ] && [ -e "$K/default_pwrlevel" ] || { gpu_pwrlevel_pin_legacy "$1"; return; }
    local lvl=$(gpu_pwrlevel_level "$1")
    if [ ! -f "$PERF_GPU_PWR_BACKUP" ]; then
        echo "$(cat $K/pwrscale 2>/dev/null) $(cat $K/default_pwrlevel 2>/dev/null) $(cat $K/max_pwrlevel 2>/dev/null) $(cat $K/min_pwrlevel 2>/dev/null)" > "$PERF_GPU_PWR_BACKUP"
    fi
    chmod 644 $K/pwrscale $K/default_pwrlevel $K/max_pwrlevel $K/min_pwrlevel 2>/dev/null
    echo "$lvl" > "$K/default_pwrlevel" 2>/dev/null
    echo "$lvl" > "$K/max_pwrlevel" 2>/dev/null
    echo "$lvl" > "$K/min_pwrlevel" 2>/dev/null
    echo 0 > "$K/pwrscale" 2>/dev/null
    chmod 444 $K/pwrscale $K/default_pwrlevel $K/max_pwrlevel $K/min_pwrlevel 2>/dev/null
}
gpu_pwrlevel_pin_legacy() {
    local K=/sys/class/kgsl/kgsl-3d0
    [ -e "$K/max_pwrlevel" ] || return
    [ -e "$K/min_pwrlevel" ] || return
    local lvl=$(gpu_pwrlevel_level "$1")
    if [ ! -f "$PERF_GPU_PWR_BACKUP" ]; then
        echo "$(cat $K/max_pwrlevel 2>/dev/null) $(cat $K/min_pwrlevel 2>/dev/null)" > "$PERF_GPU_PWR_BACKUP"
    fi
    chmod 644 "$K/max_pwrlevel" "$K/min_pwrlevel" 2>/dev/null
    echo "$lvl" > "$K/max_pwrlevel" 2>/dev/null
    echo "$lvl" > "$K/min_pwrlevel" 2>/dev/null
    chmod 444 "$K/max_pwrlevel" "$K/min_pwrlevel" 2>/dev/null
}
gpu_pwrlevel_free() {
    local K=/sys/class/kgsl/kgsl-3d0
    [ -e "$K/pwrscale" ] || return
    chmod 644 $K/pwrscale $K/default_pwrlevel $K/max_pwrlevel $K/min_pwrlevel 2>/dev/null
    echo 0 > "$K/max_pwrlevel" 2>/dev/null
    echo $(( $(cat "$K/num_pwrlevels" 2>/dev/null) - 1 )) > "$K/min_pwrlevel" 2>/dev/null
    echo $(( $(cat "$K/num_pwrlevels" 2>/dev/null) - 1 )) > "$K/default_pwrlevel" 2>/dev/null
    echo 1 > "$K/pwrscale" 2>/dev/null
}
gpu_pwrlevel_hold() {
    [ -f "$PERF_GPU_PWR_BACKUP" ] || return
    local K=/sys/class/kgsl/kgsl-3d0
    local tgt=$(gpu_pwrlevel_level "$(cat "$PERF_TARGET" 2>/dev/null | cut -d'|' -f4)")
    chmod 644 $K/pwrscale $K/default_pwrlevel $K/max_pwrlevel $K/min_pwrlevel 2>/dev/null
    echo "$tgt" > "$K/default_pwrlevel" 2>/dev/null
    echo "$tgt" > "$K/max_pwrlevel" 2>/dev/null
    echo "$tgt" > "$K/min_pwrlevel" 2>/dev/null
    echo 0 > "$K/pwrscale" 2>/dev/null
    chmod 444 $K/pwrscale $K/default_pwrlevel $K/max_pwrlevel $K/min_pwrlevel 2>/dev/null
}
gpu_pwrlevel_restore() {
    [ -f "$PERF_GPU_PWR_BACKUP" ] || return
    local K=/sys/class/kgsl/kgsl-3d0
    local ps=$(awk '{print $1}' "$PERF_GPU_PWR_BACKUP" 2>/dev/null)
    local dl=$(awk '{print $2}' "$PERF_GPU_PWR_BACKUP" 2>/dev/null)
    local om=$(awk '{print $3}' "$PERF_GPU_PWR_BACKUP" 2>/dev/null)
    local on=$(awk '{print $4}' "$PERF_GPU_PWR_BACKUP" 2>/dev/null)
    chmod 644 $K/pwrscale $K/default_pwrlevel $K/max_pwrlevel $K/min_pwrlevel 2>/dev/null
    [ -n "$dl" ] && echo "$dl" > "$K/default_pwrlevel" 2>/dev/null
    [ -n "$om" ] && echo "$om" > "$K/max_pwrlevel" 2>/dev/null
    [ -n "$on" ] && echo "$on" > "$K/min_pwrlevel" 2>/dev/null
    [ -n "$ps" ] && echo "$ps" > "$K/pwrscale" 2>/dev/null
    rm -f "$PERF_GPU_PWR_BACKUP"
}
PERF_MSM_BACKUP="$MODDIR/perf_msm_backup"
perf_msm_apply() {
    local c0="$1" c4="$2" c7="$3"
    local P=/sys/kernel/msm_performance/parameters
    [ -f "$P/cpu_max_freq" ] || return
    [ -z "$c0" ] && c0=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null)
    [ -z "$c4" ] && c4=$(cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 2>/dev/null)
    [ -z "$c7" ] && c7=$(cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq 2>/dev/null)
    [ -n "$c0" ] && [ -n "$c4" ] && [ -n "$c7" ] || return
    [ -f "$PERF_MSM_BACKUP" ] || cat "$P/cpu_max_freq" > "$PERF_MSM_BACKUP" 2>/dev/null
    chmod 644 "$P/cpu_max_freq" 2>/dev/null
    echo "0:$c0 1:$c0 2:$c4 3:$c4 4:$c4 5:$c4 6:$c4 7:$c7" > "$P/cpu_max_freq" 2>/dev/null
    chmod 444 "$P/cpu_max_freq" 2>/dev/null
}
perf_msm_restore() {
    local P=/sys/kernel/msm_performance/parameters
    chmod 644 "$P/cpu_max_freq" 2>/dev/null
    if [ -f "$PERF_MSM_BACKUP" ] && [ -f "$P/cpu_max_freq" ]; then
        cat "$PERF_MSM_BACKUP" > "$P/cpu_max_freq" 2>/dev/null
    fi
    rm -f "$PERF_MSM_BACKUP" 2>/dev/null
}
PERF_THERM_BACKUP="$MODDIR/perf_therm_backup"
PERF_THERM_TYPES="pm8550-bcl-lvl0 pm8550-bcl-lvl1 pm8550-bcl-lvl2 pm8550b-bcl-lvl0 pm8550b-bcl-lvl1 pm8550b-bcl-lvl2 socd pm8550vs_d_tz"
perf_therm_apply() {
    for z in /sys/class/thermal/thermal_zone*; do
        [ -d "$z" ] || continue
        t=$(cat "$z/type" 2>/dev/null)
        case " $PERF_THERM_TYPES " in
            *" $t "*) ;;
            *) continue ;;
        esac
        n=${z##*thermal_zone}
        if [ "$(cat "$z/mode" 2>/dev/null)" != "disabled" ]; then
            echo disabled > "$z/mode" 2>/dev/null
            echo "$n" >> "$PERF_THERM_BACKUP"
        fi
    done
    sort -u "$PERF_THERM_BACKUP" -o "$PERF_THERM_BACKUP" 2>/dev/null
}
perf_therm_hold() {
    [ -f "$PERF_THERM_BACKUP" ] || return
    while read -r n; do
        [ -n "$n" ] && echo disabled > /sys/class/thermal/thermal_zone$n/mode 2>/dev/null
    done < "$PERF_THERM_BACKUP"
}
perf_therm_restore() {
    [ -f "$PERF_THERM_BACKUP" ] || return
    while read -r n; do
        [ -n "$n" ] && echo enabled > /sys/class/thermal/thermal_zone$n/mode 2>/dev/null
    done < "$PERF_THERM_BACKUP"
    rm -f "$PERF_THERM_BACKUP"
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
      gpu_pwrlevel_pin "$gpu"
    fi
    if [ -n "$gov" ]; then
        for c in /sys/devices/system/cpu/cpu*/cpufreq; do
            echo "$gov" > "$c/scaling_governor" 2>/dev/null
        done
    fi
    echo "$cpu0|$cpu4|$cpu7|$gpu|$gov" > "$PERF_TARGET"
    perf_msm_apply "$cpu0" "$cpu4" "$cpu7"
    perf_therm_apply
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
    perf_msm_restore
    perf_therm_restore
    gpu_pwrlevel_restore
    rm -f "$PERF_PENDING" "$PERF_BACKUP" "$PERF_TARGET"
}
perf_reset_now() {
    perf_stop_kill
    local K=/sys/class/kgsl/kgsl-3d0
    for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq $K/devfreq/max_freq $K/devfreq/min_freq $K/max_clock_mhz $K/min_clock_mhz "$GPU_MAX_CLOCK" "$GPU_MIN_CLOCK"; do
        chmod 644 "$f" 2>/dev/null
    done
    local h0=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null); [ -z "$h0" ] && h0=2265600
    local h4=$(cat /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_max_freq 2>/dev/null); [ -z "$h4" ] && h4=3148800
    local h7=$(cat /sys/devices/system/cpu/cpu7/cpufreq/cpuinfo_max_freq 2>/dev/null); [ -z "$h7" ] && h7=3302400
    echo "$h0" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null
    echo "$h4" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 2>/dev/null
    echo "$h7" > /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq 2>/dev/null
    for c in /sys/devices/system/cpu/cpu*/cpufreq; do
        echo walt > "$c/scaling_governor" 2>/dev/null
    done
    gpu_write_max 903000000
    gpu_write_min 231000000
    gpu_pwrlevel_free
    local P=/sys/kernel/msm_performance/parameters
    if [ -f "$P/cpu_max_freq" ]; then
        chmod 644 "$P/cpu_max_freq" 2>/dev/null
        echo "0:$h0 1:$h0 2:$h4 3:$h4 4:$h4 5:$h4 6:$h4 7:$h7" > "$P/cpu_max_freq" 2>/dev/null
    fi
    perf_therm_restore
    rm -f "$PERF_BACKUP" "$PERF_MSM_BACKUP" "$PERF_PENDING" "$PERF_TARGET" "$AUTO_PERF_FILE" "$PERF_GPU_PWR_BACKUP" "$PERF_THERM_BACKUP"
}
