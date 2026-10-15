#!/system/bin/sh
MODDIR=${0%/*}
case "$MODDIR" in
  /*) ;;
  *) MODDIR=/data/adb/modules/FanExtreme ;;
esac
case "$MODDIR" in
  */FanExtreme) ;;
  *) exit 1 ;;
esac
for p in $(ps -A -o pid,args 2>/dev/null | grep -E '[s]ervice\.sh|/tmp/fex\.[0-9]+|[.]perf_kill_daemon' | awk '{print $1}'); do
  [ "$p" != "$$" ] && kill -9 "$p" 2>/dev/null
done
for f in /sys/kernel/fan/fan_speed_level /sys/kernel/fan_speed_level /proc/driver/micropump/speed /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq /sys/class/kgsl/kgsl-3d0/pwrscale /sys/class/kgsl/kgsl-3d0/default_pwrlevel /sys/class/kgsl/kgsl-3d0/max_pwrlevel /sys/class/kgsl/kgsl-3d0/min_pwrlevel /sys/class/kgsl/kgsl-3d0/max_clock_mhz /sys/class/kgsl/kgsl-3d0/min_clock_mhz /sys/class/kgsl/kgsl-3d0/devfreq/max_freq /sys/class/kgsl/kgsl-3d0/devfreq/min_freq /sys/kernel/msm_performance/parameters/cpu_max_freq; do
  [ -e "$f" ] && chmod 644 "$f" 2>/dev/null
done
sleep 2
getprop 2>/dev/null | grep 'init\.svc\.' | while read -r line; do
  name=$(echo "$line" | sed 's/^\[init\.svc\.//; s/\]:.*//')
  state=$(echo "$line" | sed 's/.*\]: \[//; s/\]$//')
  case "$name" in
    *thermal*|*perf*|*mpdecision*|*zperfcube*|*thermald*|*limit*)
      [ "$state" != "running" ] && [ "$state" != "restarting" ] && setprop ctl.restart "$name" 2>/dev/null
      ;;
  esac
done
for f in "$MODDIR"/* "$MODDIR"/.*; do
  case "${f##*/}" in
    .|..|config.txt|.licensed) continue ;;
  esac
  [ -e "$f" ] && rm -rf "$f" 2>/dev/null
done
exit 0
