#!/bin/bash
# levals-node · gỡ cài đặt toàn bộ instance (chạy bằng root).
#   curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/uninstall.sh | bash
# Biến: KEEP_CONFIG=1 để giữ /etc/levals-node* (cấu hình).
set -e
[ "$(id -u)" = 0 ] || { echo "Chạy bằng root."; exit 1; }

echo "== Dừng & gỡ toàn bộ dịch vụ levals-node"
for u in /etc/systemd/system/levals-node.service /etc/systemd/system/levals-node-*.service; do
  [ -e "$u" ] || continue
  svc="$(basename "$u" .service)"
  systemctl stop "$svc" 2>/dev/null || true
  systemctl disable "$svc" 2>/dev/null || true
  rm -f "$u"
done
systemctl daemon-reload 2>/dev/null || true

echo "== Dừng tiến trình còn sót"
pkill -f '/usr/local/bin/levals-node' 2>/dev/null || true
pkill -f '/usr/local/lib/levals-node/lvcore' 2>/dev/null || true

echo "== Xoá tập tin thực thi"
rm -f /usr/local/bin/levals-node /usr/local/bin/lvnode
rm -rf /usr/local/lib/levals-node
if [ "${KEEP_CONFIG:-0}" = "1" ]; then
  echo "   (giữ /etc/levals-node* theo KEEP_CONFIG=1)"
else
  rm -rf /etc/levals-node /etc/levals-node-*
fi

echo "== Xong. Đã gỡ hoàn toàn levals-node."
