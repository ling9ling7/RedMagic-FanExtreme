cfg() {
    grep -o "^$1=.*" "$CONFIG" 2>/dev/null | cut -d= -f2 | tail -1
}
st() {
    grep -o "^$1=.*" "$STATE" 2>/dev/null | cut -d= -f2 | tail -1
}
cfg_set() {
    if [ ! -f "$STATE" ]; then
        [ -f "$CONFIG" ] && cp "$CONFIG" "$STATE" 2>/dev/null
        [ -f "$STATE" ] || return 0
    fi
    if grep -q "^$1=" "$STATE" 2>/dev/null; then
        sed -i "s/^$1=.*/$1=$2/" "$STATE" 2>/dev/null
    else
        [ -n "$(tail -c 1 "$STATE" 2>/dev/null)" ] && echo >> "$STATE" 2>/dev/null
        echo "$1=$2" >> "$STATE" 2>/dev/null
    fi
}
jstr() {
    printf '%s' "$1" | tr -d '\r\n' | sed 's/\\/\\\\/g; s/"/\\"/g'
}
vibe_apply() {
    local g="$1" d="$2" v="$3" EL VB
    EL="${ERRLOG:-/dev/null}"
    VB=/sys/class/leds/vibrator
    [ -e /sys/class/leds/zte_vibrator/gain ] && VB=/sys/class/leds/zte_vibrator
    [ -e "$VB/gain" ] && printf 0x%x "$g" > "$VB/gain" 2>>"$EL"
    [ -e "$VB/duration" ] && echo "$d" > "$VB/duration" 2>>"$EL"
    [ -e "$VB/duration_aw" ] && printf 0x%x "$d" > "$VB/duration_aw" 2>>"$EL"
    [ -e "$VB/vmax" ] && printf 0x%x "$v" > "$VB/vmax" 2>>"$EL"
    [ -e "$VB/cont_brk_time" ] && echo 0x01 > "$VB/cont_brk_time" 2>>"$EL"
    [ -e "$VB/cont_wait_num" ] && echo 0x03 > "$VB/cont_wait_num" 2>>"$EL"
}
gpu_max_hz() {
    local v=""
    [ -e /sys/class/kgsl/kgsl-3d0/devfreq/max_freq ] && v=$(cat /sys/class/kgsl/kgsl-3d0/devfreq/max_freq 2>/dev/null)
    [ -z "$v" ] && [ -e /sys/class/kgsl/kgsl-3d0/max_gpuclk ] && v=$(cat /sys/class/kgsl/kgsl-3d0/max_gpuclk 2>/dev/null)
    if [ -z "$v" ] && [ -e /sys/class/kgsl/kgsl-3d0/max_clock_mhz ]; then
        v=$(cat /sys/class/kgsl/kgsl-3d0/max_clock_mhz 2>/dev/null)
        [ -n "$v" ] && v=$((v * 1000000))
    fi
    if [ -z "$v" ] && [ -e /sys/kernel/gpu/gpu_max_clock ]; then
        v=$(cat /sys/kernel/gpu/gpu_max_clock 2>/dev/null)
        [ -n "$v" ] && v=$((v * 1000000))
    fi
    if [ -z "$v" ] && [ -e /sys/kernel/gpu_max_clock ]; then
        v=$(cat /sys/kernel/gpu_max_clock 2>/dev/null)
        [ -n "$v" ] && v=$((v * 1000000))
    fi
    echo "$v"
}
gpu_cur_hz() {
    local v=""
    [ -e /sys/class/kgsl/kgsl-3d0/devfreq/cur_freq ] && v=$(cat /sys/class/kgsl/kgsl-3d0/devfreq/cur_freq 2>/dev/null)
    [ -z "$v" ] && [ -e /sys/class/kgsl/kgsl-3d0/gpuclk ] && v=$(cat /sys/class/kgsl/kgsl-3d0/gpuclk 2>/dev/null)
    if [ -z "$v" ] && [ -e /sys/class/kgsl/kgsl-3d0/clock_mhz ]; then
        v=$(cat /sys/class/kgsl/kgsl-3d0/clock_mhz 2>/dev/null)
        [ -n "$v" ] && v=$((v * 1000000))
    fi
    if [ -z "$v" ] && [ -e /sys/kernel/gpu/gpu_clock ]; then
        v=$(cat /sys/kernel/gpu/gpu_clock 2>/dev/null)
        [ -n "$v" ] && v=$((v * 1000000))
    fi
    echo "$v"
}
