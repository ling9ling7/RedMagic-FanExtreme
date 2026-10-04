MODDIR=/data/adb/modules/FanExtreme
CONFIG=$MODDIR/config.txt
STATE=$MODDIR/state.txt
STATUS=$MODDIR/webui_status
L=/sdcard/Download/FanExtreme_debug.log
. "$MODDIR/lib/common.sh"

cfg(){ grep -o "^$1=.*" "$CONFIG" 2>/dev/null | cut -d= -f2 | tr -d '\r\t' | sed 's/ *$//' | tail -1; }
st(){ grep -o "^$1=.*" "$STATE" 2>/dev/null | cut -d= -f2 | tr -d '\r\t' | sed 's/ *$//' | tail -1; }
rd(){ [ -e "$1" ] && cat "$1" 2>/dev/null || echo "N/A"; }
mf(){ [ -f "$1" ] && echo 1 || echo 0; }

n_ok=0; n_fail=0; n_warn=0
sec(){ printf "\n===== %s =====\n" "$1" >> "$L"; }
ok(){ printf "  [OK]   %s\n" "$1" >> "$L"; n_ok=$((n_ok+1)); }
fail(){ printf "  [FAIL] %s\n" "$1" >> "$L"; n_fail=$((n_fail+1)); }
warn(){ printf "  [WARN] %s\n" "$1" >> "$L"; n_warn=$((n_warn+1)); }
info(){ printf "  %s\n" "$1" >> "$L"; }

mkdir -p /sdcard/Download 2>/dev/null
: > "$L" 2>/dev/null || exit 1

sec "基本信息"
info "版本: $(grep -o '^version=.*' $MODDIR/module.prop 2>/dev/null | cut -d= -f2)"
info "时间: $(date '+%F %T')  开机时长: $(cut -d' ' -f1 /proc/uptime 2>/dev/null)s"
info "机型: $(getprop ro.product.model)  系统: Android $(getprop ro.build.version.release) (SDK $(getprop ro.build.version.sdk))"
info "内核: $(uname -r)"

sec "模块服务进程"
SVC_PID=$(cat $MODDIR/.svc_pid 2>/dev/null)
if [ -n "$SVC_PID" ] && [ -d "/proc/$SVC_PID" ]; then
    ok "service.sh 主进程存活 (pid=$SVC_PID)"
else
    fail "service.sh 主进程未运行 (.svc_pid=$SVC_PID)"
fi
NOW=$(date +%s)
MT=$(stat -c %Y "$STATUS" 2>/dev/null)
if [ -n "$MT" ]; then
    AGE=$((NOW - MT))
    if [ "$AGE" -le 10 ]; then ok "webui 主循环心跳正常 (状态文件 ${AGE}s 前更新)"
    else fail "webui 主循环心跳停滞 (状态文件 ${AGE}s 未更新，主循环可能卡死)"; fi
else
    fail "webui_status 不存在，主循环未运行"
fi
ps -A -o pid,ppid,args 2>/dev/null | grep -E "FanExtreme|service\.sh" | grep -v grep | while read -r pline; do info "    $pline"; done

FAN_EN=/sys/kernel/fan/fan_enable
FAN_LVL=/sys/kernel/fan/fan_speed_level
[ -e "$FAN_EN" ] || { FAN_EN=/sys/kernel/fan_enable; FAN_LVL=/sys/kernel/fan_speed_level; }
fe=$(rd "$FAN_EN"); fl=$(rd "$FAN_LVL")

sec "风扇极速"
if [ -f "$MODDIR/auto_fan" ]; then
    if [ -n "$fl" ] && [ "$fl" != "N/A" ]; then ok "挡位锁定生效 (LV.$fl，风扇开关由用户/系统控制)"
    else fail "auto_fan 标记存在但挡位未写入，锁定位失效"; fi
else
    ok "挡位锁定: 关 (待机)"
fi
info "节点: $FAN_EN=$fe  挡位=$fl  节点存在: $(mf "$FAN_EN")"

sec "风扇熄屏保持"
if [ -f "$MODDIR/auto_fan_screen_off" ]; then
    ok "已开启 (熄屏时自动维持风扇转速)"
    [ -f "$MODDIR/.fan_was_on" ] && info ".fan_was_on 存在 (熄屏恢复机制已 armed)"
else
    info "未开启 (正常可选)"
fi

sec "风扇温度联动"
if [ -f "$MODDIR/auto_temp_control" ]; then
    m=$(rd "$MODDIR/temp_control_mode"); t=$(rd "$MODDIR/temp_control_threshold")
    temp=$(cat /sys/class/power_supply/battery/temp 2>/dev/null); temp=${temp:-0}; temp=$((temp/10))
    exp=0
    if [ "$m" = "custom" ]; then
        [ "$temp" -ge "${t:-40}" ] && exp=5
        info "模式: 自定义 ≥${t:-40}°C (当前 ${temp}°C)"
    else
        [ "$temp" -ge 40 ] && exp=5
        [ "$exp" -eq 0 ] && [ "$temp" -ge 35 ] && exp=4
        [ "$exp" -eq 0 ] && [ "$temp" -ge 30 ] && exp=3
        info "模式: 自动 (当前 ${temp}°C)"
    fi
    if [ "$exp" -gt 0 ]; then
        if [ "$fe" = "1" ] && [ "$fl" = "$exp" ]; then ok "温度联动生效中 (LV.$fl)"
        else warn "按规则期望 LV.$exp，实际 enable=$fe level=$fl (等待下个巡检周期属正常)"; fi
    else
        ok "温度低于触发线，联动待命"
    fi
else
    info "未开启 (正常可选)"
fi

sec "充电分离"
cs=$(settings get global charge_separation_switch 2>/dev/null)
thr=$(rd "$MODDIR/threshold" 2>/dev/null)
rc=$(rd /sys/class/qcom-battery/restrict_cur 2>/dev/null)
rg=$(rd /sys/class/qcom-battery/restrict_chg 2>/dev/null)
chg=$(rd /sys/class/qcom-battery/charging_enabled 2>/dev/null)
if [ -f "$MODDIR/auto_charge" ]; then
    info "开关: 开 | 阈值: ${thr:-100}% | $(dumpsys battery 2>/dev/null | grep -m1 'level' | tr -d ' ')"
    if [ "$cs" = "1" ]; then ok "系统已进入分离供电模式"
    else warn "系统分离开关未置 1 (未插电或电量未达阈值时属正常)"; fi
else
    if [ "$cs" = "1" ]; then warn "auto_charge 标记不存在但系统分离开关=1"
    else ok "已关闭 (待机)"; fi
fi
info "节点: restrict_cur=$rc  restrict_chg=$rg  charging_enabled=$chg"

sec "充电加速"
if [ "$(cfg 充电加速)" = "1" ]; then
    if [ "$chg" = "1" ] && [ "$rc" = "0" ]; then ok "充电电流限制已解除 (charging=1, restrict_cur=0)"
    else warn "节点状态: charging=$chg restrict_cur=$rc (未在充电时属正常)"; fi
else
    info "未启用 (config.txt)"
fi

sec "云控屏蔽"
if [ "$(cfg 云控屏蔽)" = "1" ]; then
    locked=1
    for d in /data/system/cube /data/system/cubeusercfg; do
        if [ -d "$d" ]; then
            touch "$d/.fex_t" 2>/dev/null
            if [ -e "$d/.fex_t" ]; then rm -f "$d/.fex_t" 2>/dev/null; locked=0; fi
        fi
    done
    if [ "$locked" = "1" ]; then ok "云控目录已清空并锁定 (写入测试被拒绝)"
    else warn "云控目录仍可写入，屏蔽未完全生效"; fi
else
    info "未启用 (config.txt)"
fi

sec "温控移除"
if [ "$(cfg 温控移除)" = "1" ]; then
    if mount 2>/dev/null | grep -q "thermal-engine.conf"; then ok "thermal-engine.conf 已 bind 覆盖 /vendor"
    elif [ -f "$MODDIR/vendor/etc/thermal-engine.conf" ]; then warn "conf 文件存在但未检测到 bind (post-fs-data 未执行或已被解除)"
    else fail "vendor/etc/thermal-engine.conf 缺失"; fi
else
    info "未启用 (config.txt)"
fi

sec "振动增强"
VB=/sys/class/leds/vibrator
[ -e /sys/class/leds/zte_vibrator/gain ] && VB=/sys/class/leds/zte_vibrator
if [ -f "$MODDIR/auto_vibe" ]; then
    ok "开关: 开"
    info "模块参数: gain=$(rd $MODDIR/vibe_gain) duration=$(rd $MODDIR/vibe_duration) vmax=$(rd $MODDIR/vibe_vmax)"
    info "内核参数: gain=$(rd $VB/gain) duration=$(rd $VB/duration) duration_aw=$(rd $VB/duration_aw) vmax=$(rd $VB/vmax)"
    [ "$VB" = /sys/class/leds/zte_vibrator ] && info "驱动=zte" || info "驱动=aw"
    if [ -e "$VB/gain" ]; then
        _g0=$(rd "$VB/gain")
        _g0x=$(printf '%s' "$_g0" | grep -o '0x[0-9a-fA-F]*' | tail -1)
        echo 0xc8 > "$VB/gain" 2>/dev/null
        _g1=$(rd "$VB/gain")
        [ -n "$_g0x" ] && echo "$_g0x" > "$VB/gain" 2>/dev/null
        info "gain写测: 原[$_g0] 写0xc8 读[$_g1] (读回含0xc8=写入生效,否则被系统忽略或覆盖)"
    else
        warn "内核振动节点不可用，增强未落盘"
    fi
else
    info "开关: 关 (待机)"
fi
info "默认参数: gain=$(cfg 振动增益) duration=$(cfg 振动时长) vmax=$(cfg 振动上限)"

sec "触控优化"
TP=/proc/touchscreen
rate=$(rd "$TP/tp_report_rate" 2>/dev/null)
pg=$(rd "$TP/play_game" 2>/dev/null)
fhl=$(rd "$TP/follow_hand_level" 2>/dev/null)
tsr=$(settings get system touch_sampling_rate 2>/dev/null)
if [ -f "$MODDIR/touch_mode" ]; then mode=$(rd "$MODDIR/touch_mode"); else mode=global; fi
apps=$(cat "$MODDIR/touch_apps" 2>/dev/null | tr '\n' ',')
info "运行模式: $mode | 名单: ${apps:-空}"
if [ -f "$MODDIR/auto_touch" ]; then
    if [ "$mode" = "perapp" ]; then
        if [ -f "$MODDIR/.touch_active" ]; then ok "指定应用模式生效中 (当前应用已命中名单)"
        else
            cur=$(dumpsys activity activities 2>/dev/null | grep -m1 "topResumedActivity" | grep -o "[a-z][a-z0-9_.]*/" | head -1 | tr -d "/")
            ok "指定应用模式待命 (当前应用 ${cur:-未知} 不在名单)"
        fi
    else
        if [ "$rate" = "4" ]; then ok "全局模式生效中 (report_rate=4 → 960Hz)"
        else fail "全局模式但 tp_report_rate=$rate (期望 4)，未生效"; fi
    fi
else
    if [ "$rate" = "4" ]; then warn "无 auto_touch 标记但触点仍为高采样 (rate=4)"
    else ok "开关: 关 (待机)"; fi
fi
info "内核: report_rate=$rate play_game=$pg follow_hand=$fhl | settings.touch_sampling_rate=${tsr:-未设置}"

sec "液冷控制"
MP=/proc/driver/micropump
model=$(getprop ro.product.model)
avail=0
[ -e "$MP/speed" ] && avail=1
case "$model" in NX[89]*) avail=1;; esac
if [ "$avail" = "1" ]; then
    pe=$(rd "$MP/enable" 2>/dev/null); pf=$(rd "$MP/freq" 2>/dev/null); psp=$(rd "$MP/speed" 2>/dev/null)
    plv="?"
    case "$psp" in 40) plv=1;; 60) plv=2;; 80) plv=3;; 90) plv=4;; esac
    if [ -f "$MODDIR/auto_pump" ]; then
        ok "开关: 开 (LV.$plv | enable=$pe freq=$pf speed=$psp)"
    else
        pc=$(st '水冷控制'); [ -z "$pc" ] && pc=$(cfg '水冷控制')
        if [ "$pe" = "1" ] && [ "$pc" != "0" ]; then warn "无 auto_pump 标记但液冷泵 enable=1"
        else ok "开关: 关"; fi
        info "节点: enable=$pe freq=$pf speed=$psp (LV.$plv)"
    fi
    if [ -f "$MODDIR/auto_pump_temp_control" ]; then
        info "液冷温度联动: $(rd $MODDIR/pump_temp_control_mode) (阈值 $(rd $MODDIR/pump_temp_control_threshold)°C)"
    else
        info "液冷温度联动: 未开启"
    fi
    [ -f "$MODDIR/auto_pump_screen_off" ] && info "液冷熄屏保持: 已开启"
else
    info "本机型无液冷泵节点 (micropump 不存在, 机型 $model)，卡片禁用属正常"
fi

sec "频率控制"
if [ -f "$MODDIR/perf_enabled" ]; then
    if [ -f "$MODDIR/perf_backup" ]; then
        ok "性能模式运行中 (原始频率已备份)"
        info "备份: $(cat $MODDIR/perf_backup 2>/dev/null)"
    else
        warn "性能开关开启但无备份文件 (刚开启或写入中断)"
    fi
    [ -f "$MODDIR/perf_pending" ] && info "待冷静期确认: $(cat $MODDIR/perf_pending 2>/dev/null)"
else
    ok "开关: 关 (系统默认调度)"
fi
info "当前: cpu0_max=$(rd /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq) cpu7_max=$(rd /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq) gpu_max=$(gpu_max_hz) gpu_cur=$(gpu_cur_hz) gov=$(rd /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"

sec "模块状态文件"
info "标记: auto_fan=$(mf $MODDIR/auto_fan) auto_fan_screen_off=$(mf $MODDIR/auto_fan_screen_off) auto_charge=$(mf $MODDIR/auto_charge) auto_touch=$(mf $MODDIR/auto_touch) auto_vibe=$(mf $MODDIR/auto_vibe) auto_pump=$(mf $MODDIR/auto_pump) auto_pump_screen_off=$(mf $MODDIR/auto_pump_screen_off) auto_temp_control=$(mf $MODDIR/auto_temp_control) auto_pump_temp_control=$(mf $MODDIR/auto_pump_temp_control) perf_enabled=$(mf $MODDIR/perf_enabled)"
info "触控: touch_mode=$(rd $MODDIR/touch_mode 2>/dev/null || echo '全局(无文件)') touch_apps=$( [ -s $MODDIR/touch_apps ] && echo 已写入 || echo 空 ) .touch_active=$(mf $MODDIR/.touch_active)"
info "state.txt: $(tr '\n' ' ' < $STATE 2>/dev/null)"

sec "模块错误日志"
le=$(cat "$MODDIR/.last_error" 2>/dev/null)
if [ -n "$le" ]; then warn ".last_error 有内容: $le"; else ok "无错误记录"; fi

sec "热补丁状态"
info "已应用补丁: $(tr '\n' ' ' < $MODDIR/.applied 2>/dev/null)"
tail -n 5 "$MODDIR/.patch_log" 2>/dev/null | while read -r pline; do info "    $pline"; done

sec "设备信息"
info "序列号: $(getprop ro.serialno)"
pkg=$(pm list packages 2>/dev/null | grep -iE "sukisu|resukisu|kernelsu" | head -1 | sed "s/package://")
ksud=$(getprop init.svc.ksud); kv=$(getprop ro.ksu.version)
if [ "$ksud" = "running" ] || { [ -d /data/adb/ksu ] && [ "$kv" != "APatch" ]; }; then
    case "$pkg" in
        *ultra*) rm=SuKeMiSu_Ultra;;
        *sukisu*) rm=SuKeMiSu;;
        *resukisu*) rm=ReSuKiSu;;
        *next*) rm=KernelSU_Next;;
        *) rm=KernelSU;;
    esac
    kver=$(/data/adb/ksud --version 2>/dev/null | head -1 | awk '{print $2}' | cut -d- -f1)
    [ -n "$kver" ] && rm="$rm v$kver"
elif [ -d /data/adb/ap ]; then rm=APatch
elif [ -d /data/adb/magisk ]; then rm="Magisk v$(getprop ro.magisk.version)"
else rm=unknown; fi
info "Root管理器: $rm"

sec "webui_status 原始数据"
cat "$STATUS" 2>/dev/null >> "$L"

sec "诊断结论"
total=$((n_ok + n_fail + n_warn))
info "共判定 $total 项: 正常 $n_ok / 异常 $n_fail / 警告 $n_warn"
if [ "$n_fail" -gt 0 ]; then
    info "结论: 检测到异常项，请将本日志完整反馈给作者"
elif [ "$n_warn" -gt 0 ]; then
    info "结论: 基本正常，警告项多为等待生效/未插电等正常场景"
else
    info "结论: 所有已开启功能运行正常"
fi
