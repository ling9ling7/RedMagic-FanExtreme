patch_fetch_any() {
  local rel="$1" id="$2" p=""
  for dir in "$PATCH_RAW_DIR" "$PATCH_PROXY_DIR"; do
    p=$(curl -s --max-time 12 "$dir/$rel" 2>/dev/null)
    [ -n "$p" ] && ! echo "$p" | grep -q '^404: Not Found' && { printf '%s' "$p"; return 0; }
    p=""
  done
  return 1
}
patch_restart() {
  nohup sh "$MODDIR/service.sh" >/dev/null 2>&1 &
}
patch_check() {
  local m="" id="" rel="" desc="" p="" tmp="" flag="$MODDIR/.patch_applied"
  [ -f "$CHECK_NOW" ] && rm -f "$CHECK_NOW"
  rm -f "$flag"
  m=$(patch_fetch_any "manifest.txt") || return 1
  if [ ! -f "$APPLIED_FILE" ]; then
    : > "$APPLIED_FILE"
    echo "$m" | grep '^[^#]' | while IFS='|' read -r id rel desc; do
      [ -n "$id" ] && echo "$id" >> "$APPLIED_FILE"
    done
    echo "[$(date +%F_%T)] fresh install, synced manifest" >> "$PATCH_LOG"
    return 0
  fi
  echo "$m" | grep '^[^#]' | while IFS='|' read -r id rel desc; do
    [ -z "$id" ] && continue
    grep -qx "$id" "$APPLIED_FILE" 2>/dev/null && continue
    for dir in "$PATCH_RAW_DIR" "$PATCH_PROXY_DIR"; do
      p=$(curl -s --max-time 12 "$dir/$rel" 2>/dev/null)
      [ -n "$p" ] && echo "$p" | grep -q "^# PATCH $id" && break
      p=""
    done
    if [ -z "$p" ]; then
      echo "[$(date +%F_%T)] $id fetch/verify failed all sources, skip" >> "$PATCH_LOG"
      continue
    fi
    tmp="/data/local/tmp/fe_patch_$id.sh"
    printf '%s' "$p" > "$tmp"
    if sh "$tmp"; then
      echo "$id" >> "$APPLIED_FILE"
      echo "[$(date +%F_%T)] applied $id" >> "$PATCH_LOG"
      echo "$id" > "$flag"
    else
      echo "[$(date +%F_%T)] $id FAILED, rollback" >> "$PATCH_LOG"
      if [ -d "$MODDIR/.backup/$id" ]; then
        ( cd "$MODDIR/.backup/$id" 2>/dev/null && find . -type f 2>/dev/null | while read -r bf; do
            cp "$bf" "$MODDIR/${bf#./}" 2>/dev/null
          done )
      fi
    fi
    rm -f "$tmp"
  done
  if [ -f "$flag" ]; then
    rm -f "$flag"
    patch_restart
    exit 0
  fi
  return 0
}
