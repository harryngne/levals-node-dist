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

echo "== Dọn interface WireGuard lvwg* & sysctl"
for dev in $(ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -E '^lvwg[0-9]+$' || true); do
  ip link del "$dev" >/dev/null 2>&1 || true
done
rm -f /etc/sysctl.d/99-levals-node.conf 2>/dev/null || true

echo "== Xoá tập tin thực thi"
rm -f /usr/local/bin/levals-node /usr/local/bin/lvnode
rm -rf /usr/local/lib/levals-node
if [ "${KEEP_CONFIG:-0}" = "1" ]; then
  echo "   (giữ /etc/levals-node* theo KEEP_CONFIG=1)"
else
  rm -rf /etc/levals-node /etc/levals-node-*
fi

echo "== Xong. Đã gỡ hoàn toàn levals-node."
