#!/system/bin/sh
# PATCH p001
MOD=/data/adb/modules/FanExtreme
mkdir -p $MOD/.backup/p001
echo "p001-test" > $MOD/.p001_marker
grep -q "p001-test" $MOD/.p001_marker || exit 1
