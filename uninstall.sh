#!/bin/bash
# levals-node · gỡ cài (chạy bằng root).
#   curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/uninstall.sh | bash
# Biến: KEEP_CONFIG=1 để giữ /etc/levals-node (config).
set -e
[ "$(id -u)" = 0 ] || { echo "Chạy bằng root."; exit 1; }

echo "== Dừng dịch vụ"
systemctl stop levals-node 2>/dev/null || true
systemctl disable levals-node 2>/dev/null || true
rm -f /etc/systemd/system/levals-node.service
systemctl daemon-reload 2>/dev/null || true

echo "== Dừng tiến trình còn sót"
pkill -f '/usr/local/bin/levals-node' 2>/dev/null || true
pkill -f '/usr/local/lib/levals-node/lvcore' 2>/dev/null || true

echo "== Xoá tập tin"
rm -f /usr/local/bin/levals-node
rm -rf /usr/local/lib/levals-node
if [ "${KEEP_CONFIG:-0}" = "1" ]; then
  echo "   (giữ /etc/levals-node theo KEEP_CONFIG=1)"
else
  rm -rf /etc/levals-node
fi

echo "== Xong. Đã gỡ levals-node."
