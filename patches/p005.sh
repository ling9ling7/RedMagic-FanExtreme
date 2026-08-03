# PATCH p005
MOD=/data/adb/modules/FanExtreme
echo "p005-ok" > $MOD/.p005_marker
grep -q "p005-ok" $MOD/.p005_marker || exit 1
