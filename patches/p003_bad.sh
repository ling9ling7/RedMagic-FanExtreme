# PATCH p003_bad
MOD=/data/adb/modules/FanExtreme
mkdir -p $MOD/.backup/p003_bad
cp $MOD/service.sh $MOD/.backup/p003_bad/service.sh 2>/dev/null
sed -i 's/PC_COUNT=\$((PC_COUNT + 1))/PC_COUNT=BAD/' $MOD/service.sh
grep -q 'PC_COUNT=BAD' $MOD/service.sh || exit 1
exit 1
