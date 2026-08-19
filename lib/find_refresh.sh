echo '=== 常用刷新率节点 ==='
for f in /sys/class/drm/*/mode /sys/class/drm/*/modes /sys/class/drm/msm*/mode /sys/class/drm/*/refresh_rate /sys/class/drm/*/max_refresh_rate /sys/class/graphics/fb0/refresh* /sys/class/graphics/fb0/fps* /sys/class/graphics/fb0/mode; do
  [ -e " \
