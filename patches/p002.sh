# PATCH p002
MOD=/data/adb/modules/FanExtreme
mkdir -p $MOD/.backup/p002
cp $MOD/service.sh $MOD/.backup/p002/service.sh 2>/dev/null
cat > /data/local/tmp/fe_pr_block.sh <<'FE_PR'
patch_restart() {
  nohup sh "$MODDIR/service.sh" >/dev/null 2>&1 &
  local np=$! bt=0
  sleep 2
  bt=$(awk '{print $22}' /proc/$np/stat 2>/dev/null)
  [ -z "$bt" ] && bt=0
  for p in $(ps -A -o pid,args 2>/dev/null | grep '[s]ervice.sh' | awk '{print $1}'); do
    [ "$p" = "$np" ] && continue
    pt=$(awk '{print $22}' /proc/$p/stat 2>/dev/null)
    [ -n "$pt" ] && [ "$pt" -lt "$bt" ] && kill -9 "$p" 2>/dev/null
  done
}
FE_PR
sed -i '/^patch_restart() {/,/^}/d' $MOD/service.sh
sed -i '/^patch_check() {/r /data/local/tmp/fe_pr_block.sh' $MOD/service.sh
rm -f /data/local/tmp/fe_pr_block.sh
grep -q 'bt=\$(awk' $MOD/service.sh || exit 1
echo "p002-ok" > $MOD/.p002_marker
