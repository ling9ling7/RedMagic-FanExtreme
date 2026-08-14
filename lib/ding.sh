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
