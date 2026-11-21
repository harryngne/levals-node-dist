#!/bin/bash
# levals-node · cài đặt (chạy bằng root). Chạy lại nhiều lần được.
#
#   curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node/public/install.sh | \
#     PANEL_URL=https://dash.levals.org TOKEN=xxxx NODE_ID=1 bash
#
# Biến: PANEL_URL, TOKEN (token giấy phép), NODE_ID, API_PORT (mặc định 10085),
#       BIN_URL (nguồn tải binary levals-node), XRAY_VER (mặc định latest).
set -e
[ "$(id -u)" = 0 ] || { echo "Chạy bằng root."; exit 1; }

API_PORT=${API_PORT:-10085}
ASSETS=/usr/local/share/xray
CFG=/etc/levals-node
BIN_URL=${BIN_URL:-https://github.com/harryngne/levals-node-dist/releases/latest/download}

say(){ echo -e "\n== $*"; }
need(){ command -v "$1" >/dev/null || { apt-get update -qq && apt-get install -y -qq "$2" || yum install -y -q "$2"; }; }
need curl curl; need unzip unzip

case "$(uname -m)" in
  x86_64|amd64) XARCH=64; NARCH=x86_64 ;;
  aarch64|arm64) XARCH=arm64-v8a; NARCH=aarch64 ;;
  *) echo "Kiến trúc $(uname -m) chưa hỗ trợ"; exit 1 ;;
esac

say "Tải xray-core gốc (XTLS/Xray-core)"
mkdir -p "$ASSETS" /tmp/lx
XURL="https://github.com/XTLS/Xray-core/releases/${XRAY_VER:+download/$XRAY_VER}${XRAY_VER:-latest/download}/Xray-linux-$XARCH.zip"
curl -fL --retry 3 -o /tmp/lx/xray.zip "$XURL"
unzip -o -q /tmp/lx/xray.zip -d /tmp/lx
install -m 0755 /tmp/lx/xray /usr/local/bin/xray
[ -f /tmp/lx/geoip.dat ] && cp -f /tmp/lx/geoip.dat "$ASSETS/"
[ -f /tmp/lx/geosite.dat ] && cp -f /tmp/lx/geosite.dat "$ASSETS/"
rm -rf /tmp/lx

say "Tải levals-node"
curl -fL --retry 3 -o /usr/local/bin/levals-node "$BIN_URL/levals-node-linux-$NARCH"
chmod +x /usr/local/bin/levals-node

say "Cấu hình"
mkdir -p "$CFG"
if [ ! -f "$CFG/config.yml" ]; then
  : "${PANEL_URL:?Thiếu PANEL_URL}" "${TOKEN:?Thiếu TOKEN}" "${NODE_ID:?Thiếu NODE_ID}"
  cat > "$CFG/config.yml" <<YML
panel:
  url: "$PANEL_URL"
  token: "$TOKEN"
  node_id: $NODE_ID
xray:
  bin: "/usr/local/bin/xray"
  api_port: $API_PORT
  assets_dir: "$ASSETS"
config_dir: "$CFG"
log:
  level: "info"
YML
  echo "Đã tạo $CFG/config.yml"
else
  echo "Giữ $CFG/config.yml sẵn có"
fi

say "Dịch vụ systemd"
cat > /etc/systemd/system/levals-node.service <<UNIT
[Unit]
Description=levals-node (xray)
After=network.target

[Service]
ExecStart=/usr/local/bin/levals-node -c $CFG/config.yml
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable -q --now levals-node
systemctl restart levals-node

say "Xong. Xem log: journalctl -u levals-node -f"
