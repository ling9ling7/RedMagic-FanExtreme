# PATCH p006
MOD=/data/adb/modules/FanExtreme
echo "p006-ok" > $MOD/.p006_marker
grep -q "p006-ok" $MOD/.p006_marker || exit 1
