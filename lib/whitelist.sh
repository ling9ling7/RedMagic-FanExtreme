whitelist_check() {
  local sn="$1" hit=0 ok=0 r="" rc=""
  for url in "$WHITELIST_RAW" "$WHITELIST_PROXY"; do
    r=$(curl -s --max-time 12 "$url" 2>/dev/null)
    rc=$?
    if [ "$rc" -eq 0 ]; then
      ok=$((ok + 1))
      if [ -n "$r" ] && echo "$r" | tr -d '\r' | grep -qx "$sn"; then hit=1; fi
    fi
  done
  [ "$hit" = "1" ] && return 0
  [ "$ok" -eq 2 ] && return 1
  return 2
}
