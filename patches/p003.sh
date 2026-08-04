# PATCH p003
MOD=/data/adb/modules/FanExtreme
mkdir -p $MOD/.backup/p003
cp $MOD/service.sh $MOD/.backup/p003/service.sh 2>/dev/null
sed -i '/^    \[ "\$p" = "\$np" \] && continue$/a\    [ "$p" = "$$" ] && continue' $MOD/service.sh
sed -i 's/^    patch_restart$/    patch_restart\n    exit 0/' $MOD/service.sh
grep -q '\[ "\$p" = "\$\$" \] && continue' $MOD/service.sh || exit 1
echo "p003-ok" > $MOD/.p003_marker
