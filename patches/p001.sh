# PATCH p001
MOD=/data/adb/modules/FanExtreme
mkdir -p $MOD/.backup/p001
cp $MOD/service.sh $MOD/.backup/p001/service.sh 2>/dev/null
sed -i "s/echo \"\$r\" | grep -qx \"\$sn\"; then hit=1; fi/echo \"\$r\" | tr -d '\\\\r' | grep -qx \"\$sn\"; then hit=1; fi/" $MOD/service.sh
grep -q "tr -d '\\\\r' | grep -qx" $MOD/service.sh || exit 1
echo "p001-ok" > $MOD/.p001_marker
