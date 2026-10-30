charge_monitor_loop() {
    while true; do
      if [ -f "$AUTO_CHARGE_FILE" ]; then
        threshold=$(cat "$THRESHOLD_FILE" 2>/dev/null)
        [ -z "$threshold" ] && threshold=$(cfg "充电分离阈值")
        case "$threshold" in ''|*[!0-9]*) threshold=100;; esac
        local_info=$(dumpsys battery 2>/dev/null)
        [ -z "$local_info" ] && sleep 3 && continue
        level=$(echo "$local_info" | grep 'level:' | head -1 | tr -d ' ' | cut -d: -f2)
        case "$level" in ''|*[!0-9]*) sleep 3; continue;; esac
        ac=$(echo "$local_info" | grep 'AC powered:' | head -1 | awk '{print $3}')
        usb=$(echo "$local_info" | grep 'USB powered:' | head -1 | awk '{print $3}')
        wireless=$(echo "$local_info" | grep 'Wireless powered:' | head -1 | awk '{print $3}')
        current=$(settings get global charge_separation_switch 2>/dev/null)
        if [ "$current" != "1" ]; then
          rm -f "$AUTO_SEPARATION_FILE"
        fi
        if { [ "$ac" = "true" ] || [ "$usb" = "true" ] || [ "$wireless" = "true" ]; }; then
          if [ "$level" -ge "$threshold" ]; then
            if [ "$current" != "1" ]; then
              settings put global charge_separation_switch 1
              touch "$AUTO_SEPARATION_FILE"
            fi
          elif [ "$level" -le "$((threshold - 3))" ]; then
            if [ "$current" = "1" ] && [ -f "$AUTO_SEPARATION_FILE" ]; then
              settings put global charge_separation_switch 0
              rm -f "$AUTO_SEPARATION_FILE"
            fi
          fi
        fi
        sleep 3
      else
        sleep 3
      fi
    done
}
charge_monitor_start() {
    local _mp _lt _now _cmd
    _mp=$(cat "$MODDIR/.charge_mon_pid" 2>/dev/null)
    if [ -n "$_mp" ] && [ -d "/proc/$_mp" ]; then
      _cmd=$(tr '\0' ' ' < "/proc/$_mp/cmdline" 2>/dev/null)
      case "$_cmd" in *service.sh*) return 0;; esac
    fi
    _now=$(date +%s 2>/dev/null)
    _lt=$(stat -c %Y "$MODDIR/.charge_mon_lock" 2>/dev/null)
    if [ -n "$_lt" ] && [ -n "$_now" ] && [ $((_now - _lt)) -gt 60 ]; then
      rmdir "$MODDIR/.charge_mon_lock" 2>/dev/null
    fi
    if mkdir "$MODDIR/.charge_mon_lock" 2>/dev/null; then
      charge_monitor_loop &
      echo $! > "$MODDIR/.charge_mon_pid" 2>/dev/null
      rmdir "$MODDIR/.charge_mon_lock" 2>/dev/null
    fi
}
touch_keepalive_start() {
    local _tp _lt _now _cmd
    _tp=$(cat "$MODDIR/.touch_keep_pid" 2>/dev/null)
    if [ -n "$_tp" ] && [ -d "/proc/$_tp" ]; then
      _cmd=$(tr '\0' ' ' < "/proc/$_tp/cmdline" 2>/dev/null)
      case "$_cmd" in *service.sh*) return 0;; esac
    fi
    _now=$(date +%s 2>/dev/null)
    _lt=$(stat -c %Y "$MODDIR/.touch_keep_lock" 2>/dev/null)
    if [ -n "$_lt" ] && [ -n "$_now" ] && [ $((_now - _lt)) -gt 60 ]; then
      rmdir "$MODDIR/.touch_keep_lock" 2>/dev/null
    fi
    if mkdir "$MODDIR/.touch_keep_lock" 2>/dev/null; then
      (
        while true; do
          sleep 60
          [ -f "$AUTO_TOUCH_FILE" ] && { [ ! -f "$TOUCH_MODE_FILE" ] || [ "$(cat "$TOUCH_MODE_FILE" 2>/dev/null)" != "perapp" ]; } && touch_boost
        done
      ) &
      echo $! > "$MODDIR/.touch_keep_pid" 2>/dev/null
      rmdir "$MODDIR/.touch_keep_lock" 2>/dev/null
      if [ -e /sys/class/backlight/panel0-backlight/brightness ]; then
        if ! ps -A -o args 2>/dev/null | grep -q '[i]notifyd.*panel0-backlight'; then
          inotifyd - /sys/class/backlight/panel0-backlight/brightness:c | while read -r f; do
            [ -f "$AUTO_TOUCH_FILE" ] && { [ ! -f "$TOUCH_MODE_FILE" ] || [ "$(cat "$TOUCH_MODE_FILE" 2>/dev/null)" != "perapp" ]; } && touch_boost
          done &
        fi
      fi
    fi
}
pump_apply_last() {
    local _sp
    [ -e /proc/driver/micropump/enable ] || return 0
    _sp=$(cat /proc/driver/micropump/speed 2>/dev/null)
    case "$_sp" in 40|60|80|90) ;; *) _sp=90;; esac
    su system -c "chmod 644 /proc/driver/micropump/enable /proc/driver/micropump/freq /proc/driver/micropump/speed 2>/dev/null; echo 1 > /proc/driver/micropump/enable; echo 4 > /proc/driver/micropump/freq; echo $_sp > /proc/driver/micropump/speed; chmod 444 /proc/driver/micropump/speed" 2>/dev/null
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
              cfg_set '风扇极速' 1
              su system -c "chmod 644 $FAN_LEVEL $FAN_ENABLE 2>/dev/null; echo 1 > $FAN_ENABLE; echo 5 > $FAN_LEVEL; chmod 444 $FAN_LEVEL" 2>/dev/null
            else
              rm -f "$AUTO_FAN_FILE"
              cfg_set '风扇极速' 0
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
          pump_temp_control)
            if [ "$value" = "off" ]; then
              rm -f "$PUMP_TEMP_CTRL_FILE" "$PUMP_TEMP_CTRL_MODE_FILE" "$PUMP_TEMP_CTRL_THRESHOLD_FILE"
              echo 0 > /proc/driver/micropump/enable 2>/dev/null
            elif [ "$value" = "auto" ]; then
              touch "$PUMP_TEMP_CTRL_FILE"
              echo "auto" > "$PUMP_TEMP_CTRL_MODE_FILE"
            else
              tc_mode=$(echo "$value" | cut -d'|' -f1)
              tc_thr=$(echo "$value" | cut -d'|' -f2)
              if [ "$tc_mode" = "custom" ] && [ -n "$tc_thr" ]; then
                touch "$PUMP_TEMP_CTRL_FILE"
                echo "custom" > "$PUMP_TEMP_CTRL_MODE_FILE"
                echo "$tc_thr" > "$PUMP_TEMP_CTRL_THRESHOLD_FILE"
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
              cfg_set '充电分离' 1
              charge_monitor_start
            else
              rm -f "$AUTO_CHARGE_FILE"
              rm -f "$AUTO_SEPARATION_FILE"
              cfg_set '充电分离' 0
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
              cfg_set '触控模式' perapp
              [ -e /proc/touchscreen/tp_report_rate ] && { echo 1 > /proc/touchscreen/tp_report_rate; echo 0 > /proc/touchscreen/play_game; echo 1 > /proc/touchscreen/follow_hand_level; }
              settings delete system touch_sampling_rate 2>/dev/null
              rm -f "$MODDIR/.touch_active"
            else
              rm -f "$TOUCH_MODE_FILE"
              cfg_set '触控模式' global
              [ -f "$AUTO_TOUCH_FILE" ] && touch_boost
              rm -f "$MODDIR/.touch_active"
            fi
            ;;
          touch_apps)
            echo "$value" | tr "," "\n" | sed "s/^ *//;s/ *$//" > "$TOUCH_APPS_FILE"
            cfg_set '触控应用列表' "$value"
            ;;
          touch_boost)
            if [ "$value" = "on" ]; then
              touch "$AUTO_TOUCH_FILE"
              cfg_set '触控优化' 1
              local TP=/proc/touchscreen
              [ -e "$TP/tp_report_rate" ] && { echo 4 > $TP/tp_report_rate; echo 1 > $TP/play_game; echo 4 > $TP/follow_hand_level; }
              settings put system touch_sampling_rate 960 2>/dev/null
              [ ! -f "$TOUCH_MODE_FILE" ] || [ "$(cat "$TOUCH_MODE_FILE" 2>/dev/null)" != "perapp" ] && touch_keepalive_start
            else
              rm -f "$AUTO_TOUCH_FILE"
              cfg_set '触控优化' 0
              [ -e /proc/touchscreen/tp_report_rate ] && { echo 1 > /proc/touchscreen/tp_report_rate; echo 0 > /proc/touchscreen/play_game; echo 1 > /proc/touchscreen/follow_hand_level; }
              settings delete system touch_sampling_rate 2>/dev/null
            fi
            ;;
          vibe_boost)
            if [ "$value" = "on" ]; then
              touch "$MODDIR/auto_vibe"
              cfg_set '振动增强' 1
              vibe_boost
            else
              rm -f "$MODDIR/auto_vibe"
              cfg_set '振动增强' 0
              vibe_stock_restore
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
            vibe_apply "$cur_gain" "$cur_dur" "$cur_vmax"
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
            vibe_apply "$cur_gain" "$cur_dur" "$cur_vmax"
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
            vibe_apply "$cur_gain" "$cur_dur" "$cur_vmax"
            ;;
          auto_pump)
            if [ "$value" = "on" ]; then
              touch "$MODDIR/auto_pump"
              cfg_set '水冷控制' 1
              pump_apply_last
            else
              rm -f "$MODDIR/auto_pump"
              cfg_set '水冷控制' 0
              echo 0 > /proc/driver/micropump/enable 2>/dev/null
            fi
            ;;
          auto_pump_screen_off)
            if [ "$value" = "on" ]; then
              touch "$PUMP_SCREEN_OFF_FILE"
            else
              rm -f "$PUMP_SCREEN_OFF_FILE"
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
    if [ -f "$PUMP_SCREEN_OFF_FILE" ] && [ -e /proc/driver/micropump/enable ]; then
      if dumpsys power 2>/dev/null | grep -q 'mWakefulness=Awake'; then
        pe=$(cat /proc/driver/micropump/enable 2>/dev/null)
        if [ "$pe" = "1" ]; then
          touch "$PUMP_WAS_ON_FILE" 2>/dev/null
        else
          rm -f "$PUMP_WAS_ON_FILE" 2>/dev/null
        fi
      else
        if [ -f "$PUMP_WAS_ON_FILE" ]; then
          pe=$(cat /proc/driver/micropump/enable 2>/dev/null)
          if [ "$pe" != "1" ]; then
            pump_sp=$(cat /proc/driver/micropump/speed 2>/dev/null)
            case "$pump_sp" in
              40) pump_lvl=1;; 60) pump_lvl=2;; 80) pump_lvl=3;; 90) pump_lvl=4;;
              *) pump_lvl=4;;
            esac
            case "$pump_lvl" in
              1) pump_sp_val=40;; 2) pump_sp_val=60;; 3) pump_sp_val=80;; 4) pump_sp_val=90;;
            esac
            su system -c "chmod 644 /proc/driver/micropump/enable /proc/driver/micropump/freq /proc/driver/micropump/speed 2>/dev/null; echo 1 > /proc/driver/micropump/enable; echo 4 > /proc/driver/micropump/freq; echo $pump_sp_val > /proc/driver/micropump/speed; chmod 444 /proc/driver/micropump/speed" 2>/dev/null
          fi
        fi
      fi
    fi
    TC_COUNT=$((TC_COUNT + 1))
    if [ $((TC_COUNT % 10)) -eq 0 ] && [ -f "$AUTO_CHARGE_FILE" ]; then
      charge_monitor_start
    fi
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
          if [ "$fe" = "1" ]; then
            su system -c "chmod 644 $FAN_ENABLE 2>/dev/null; echo 0 > $FAN_ENABLE" 2>/dev/null
          fi
        fi
      fi
    fi
    if [ $((TC_COUNT % 5)) -eq 0 ] && [ -f "$PUMP_TEMP_CTRL_FILE" ] && [ -e /proc/driver/micropump/speed ]; then
      temp_raw=$(cat /sys/class/power_supply/battery/temp 2>/dev/null)
      if [ -n "$temp_raw" ]; then
        current_temp=$(awk "BEGIN{printf \"%d\", $temp_raw/10}")
        pump_ctrl_mode="auto"
        [ -f "$PUMP_TEMP_CTRL_MODE_FILE" ] && pump_ctrl_mode=$(cat "$PUMP_TEMP_CTRL_MODE_FILE")
        target_pump=0
        if [ "$pump_ctrl_mode" = "auto" ]; then
          if [ "$current_temp" -ge 40 ]; then target_pump=4
          elif [ "$current_temp" -ge 35 ]; then target_pump=3
          elif [ "$current_temp" -ge 30 ]; then target_pump=2
          fi
        else
          pump_thr=40
          [ -f "$PUMP_TEMP_CTRL_THRESHOLD_FILE" ] && pump_thr=$(cat "$PUMP_TEMP_CTRL_THRESHOLD_FILE")
          if [ "$current_temp" -ge "$pump_thr" ]; then target_pump=4; fi
        fi
        if [ "$target_pump" -gt 0 ]; then
          case "$target_pump" in
            1) pump_sp=40;; 2) pump_sp=60;; 3) pump_sp=80;; 4) pump_sp=90;;
          esac
          pe=$(cat /proc/driver/micropump/enable 2>/dev/null)
          ps=$(cat /proc/driver/micropump/speed 2>/dev/null)
          if [ "$pe" != "1" ] || [ "$ps" != "$pump_sp" ]; then
            su system -c "chmod 644 /proc/driver/micropump/enable /proc/driver/micropump/freq /proc/driver/micropump/speed 2>/dev/null; echo 1 > /proc/driver/micropump/enable; echo 4 > /proc/driver/micropump/freq; echo $pump_sp > /proc/driver/micropump/speed; chmod 444 /proc/driver/micropump/speed" 2>/dev/null
          fi
        else
          if [ ! -f "$AUTO_PUMP_FILE" ] && [ "$(cat /proc/driver/micropump/enable 2>/dev/null)" = "1" ]; then
            su system -c "chmod 644 /proc/driver/micropump/enable 2>/dev/null; echo 0 > /proc/driver/micropump/enable" 2>/dev/null
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
