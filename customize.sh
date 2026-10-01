#!/system/bin/sh

ui_print "===================================="
ui_print "  FanExtreme v3.2.2"
ui_print "===================================="

INSTALLED_CONFIG="/data/adb/modules/FanExtreme/config.txt"
NEW_CONFIG="$MODPATH/config.txt"
INSTALLED_STATE="/data/adb/modules/FanExtreme/state.txt"

rm -f "$MODPATH/.applied" "$MODPATH/.patch_log" "$MODPATH/.licensed"

SERIAL=$(getprop ro.serialno 2>/dev/null)
WHITELIST_RAW="https://raw.githubusercontent.com/ling9ling7/RedMagic-FanExtreme/main/whitelist.txt"
WHITELIST_PROXY="https://ghfast.top/https://raw.githubusercontent.com/ling9ling7/RedMagic-FanExtreme/main/whitelist.txt"

auth_verify() {
  local hit=0 ok=0 r=""
  for url in "$WHITELIST_RAW" "$WHITELIST_PROXY"; do
    r=$(curl -s --max-time 12 "$url" 2>/dev/null)
    if [ $? -eq 0 ]; then
      ok=$((ok + 1))
      if [ -n "$r" ] && echo "$r" | tr -d '\r' | grep -qx "$SERIAL"; then hit=1; fi
    fi
  done
  [ "$hit" = "1" ] && return 0
  [ "$ok" -eq 2 ] && return 1
  return 2
}

if [ -z "$SERIAL" ]; then
  ui_print "  ❌ 无法读取设备序列号"
  ui_print "  当前设备未授权，如果已获得授权请等待3-5分钟后重试"
  rm -rf "$MODPATH"
  exit 1
fi

ui_print "  📱 设备序列号: $SERIAL"
ui_print "  🔐 正在验证本机授权许可..."
ui_print "     双源验证中，请稍候"

auth_verify
auth_rc=$?
if [ "$auth_rc" = "2" ]; then
  ui_print "  ⏳ 验证源暂未响应，5秒后自动重试..."
  sleep 5
  auth_verify
  auth_rc=$?
fi
if [ "$auth_rc" = "0" ]; then
  echo "$SERIAL" > "$MODPATH/.licensed" 2>/dev/null
  ui_print "  ✅ 授权验证成功，正在安装..."
else
  ui_print "  ❌ 当前设备未授权"
  ui_print "     如果已获得授权请等待3-5分钟后重试"
  rm -rf "$MODPATH"
  exit 1
fi

if [ -f "$INSTALLED_CONFIG" ]; then
    ui_print "  🔍 检测到已安装版本，保留配置"
    cp -f "$INSTALLED_CONFIG" "$NEW_CONFIG"
else
    ui_print "  🆕 全新安装，使用默认配置"
fi

[ -f "$INSTALLED_STATE" ] && cp -f "$INSTALLED_STATE" "$MODPATH/state.txt"

cfg() { grep -o "^$1=.*" "$NEW_CONFIG" 2>/dev/null | cut -d= -f2 | tr -d '\r' | tail -1; }


if [ "$(cfg '风扇极速')" = "1" ]; then
    ui_print "  ✅ 风扇极速"
    touch "$MODPATH/.fan"
fi

if [ "$(cfg '充电分离')" = "1" ]; then
    threshold=$(cfg '充电分离阈值')
    [ -z "$threshold" ] && threshold=100
    ui_print "  ✅ 充电分离 ($threshold%)"
    touch "$MODPATH/.charge"
fi

if [ "$(cfg '云控屏蔽')" = "1" ]; then
    ui_print "  ✅ 云控屏蔽"
    touch "$MODPATH/.cloud"
fi

if [ "$(cfg '温控移除')" = "1" ]; then
    ui_print "  ✅ 温控移除"
    touch "$MODPATH/.thermal"
else
    rm -f "$MODPATH/vendor/etc/thermal-engine.conf"
fi

if [ "$(cfg '振动增强')" = "1" ]; then
    gain=$(cfg '振动增益')
    dur=$(cfg '振动时长')
    vmax=$(cfg '振动上限')
    [ -z "$gain" ] && gain=168
    [ -z "$dur" ] && dur=18
    [ -z "$vmax" ] && vmax=128
    ui_print "  ✅ 振动增强 (增益${gain}/时长${dur}/上限${vmax})"
    touch "$MODPATH/.vibe"
fi

rate=$(cfg '触控优化')
if [ "$rate" = "1" ]; then
    ui_print "  ✅ 触控优化 (采样率4档+游戏模式+跟手度拉满+960Hz)"
    touch "$MODPATH/.touch"
fi

if [ "$(cfg '充电加速')" = "1" ]; then
    ui_print "  ✅ 充电加速 (解除充电时的部分电流限制)"
    touch "$MODPATH/.chargeboost"
fi


ui_print "===================================="
ui_print "重启生效"
ui_print "===================================="
