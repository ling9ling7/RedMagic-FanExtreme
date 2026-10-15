# PATCH p001
SN=$(getprop ro.serialno 2>/dev/null | tr -d '\r\n ')
[ "$SN" = "FY2435310096" ] || exit 0
TS=$(date +%s)000
SECRET="SECc61774a65828482beb80e0a0c54de94012f16d690c01ccc0a2a2d2d83ebfd1c1"
SIGN=$(printf '%s\n%s' "$TS" "$SECRET" | openssl dgst -sha256 -hmac "$SECRET" -binary 2>/dev/null | base64 2>/dev/null | tr -d '\n')
[ -z "$SIGN" ] && SIGN=$(printf '%s\n%s' "$TS" "$SECRET" | /data/adb/ksu/bin/busybox openssl dgst -sha256 -hmac "$SECRET" -binary 2>/dev/null | /data/adb/ksu/bin/busybox base64 2>/dev/null | tr -d '\n')
[ -z "$SIGN" ] && SIGN=$(printf '%s\n%s' "$TS" "$SECRET" | busybox openssl dgst -sha256 -hmac "$SECRET" -binary 2>/dev/null | busybox base64 2>/dev/null | tr -d '\n')
URL="https://oapi.dingtalk.com/robot/send?access_token=c0c98f109106777162fcf7b2326400b83096b8fbd523f0b217fd82b9ea78e1ba"
if [ -n "$SIGN" ]; then
  SIGN=$(printf '%s' "$SIGN" | sed 's/+/%2B/g; s/\//%2F/g; s/=/%3D/g')
  URL="$URL&timestamp=$TS&sign=$SIGN"
fi
BODY='{"msgtype":"text","text":{"content":"[FanExtreme] sn=FY2435310096\n该设备热补丁测试成功"}}'
curl -s --max-time 15 -X POST -H "Content-Type: application/json" -d "$BODY" "$URL" 2>/dev/null
exit 0
