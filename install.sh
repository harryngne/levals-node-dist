#!/bin/bash
# levals-node · cài đặt (chạy bằng root). Chạy lại nhiều lần được.
#
#   curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh | \
#     PANEL_URL=https://dash.levals.org TOKEN=xxxx NODE_ID=1 bash
#
# Biến: PANEL_URL, TOKEN (token giấy phép), NODE_ID, API_PORT (mặc định 10085),
#       BASE (nguồn tải, mặc định Release của levals-node-dist).
set -e
[ "$(id -u)" = 0 ] || { echo "Chạy bằng root."; exit 1; }

API_PORT=${API_PORT:-10085}
LIB=/usr/local/lib/levals-node
GEO="$LIB/geo"
CFG=/etc/levals-node
BASE=${BASE:-https://github.com/harryngne/levals-node-dist/releases/latest/download}

say(){ echo -e "\n== $*"; }
need(){ command -v "$1" >/dev/null || { apt-get update -qq && apt-get install -y -qq "$2" || yum install -y -q "$2"; }; }
need curl curl
# Tải ra file tạm rồi đổi tên (tránh "Text file busy" khi ghi đè binary đang chạy).
dl(){ curl -fL --retry 3 -o "$2.new" "$1" && mv -f "$2.new" "$2"; }

case "$(uname -m)" in
  x86_64|amd64) NARCH=x86_64 ;;
  aarch64|arm64) NARCH=aarch64 ;;
  *) echo "Kiến trúc $(uname -m) chưa hỗ trợ"; exit 1 ;;
esac

say "Tải levals-node"
mkdir -p "$LIB" "$GEO"
dl "$BASE/levals-node-linux-$NARCH" /usr/local/bin/levals-node
chmod +x /usr/local/bin/levals-node

say "Tải lõi mạng + dữ liệu định tuyến"
dl "$BASE/lvcore-$NARCH" "$LIB/lvcore"
chmod +x "$LIB/lvcore"
dl "$BASE/geoip.dat"   "$GEO/geoip.dat"
dl "$BASE/geosite.dat" "$GEO/geosite.dat"

say "Cấu hình"
mkdir -p "$CFG"
if [ ! -f "$CFG/config.yml" ]; then
  : "${PANEL_URL:?Thiếu PANEL_URL}" "${TOKEN:?Thiếu TOKEN}"
  # Node đơn: NODE_ID. Chế độ machine (một máy nhiều node): MACHINE_ID.
  if [ -n "${MACHINE_ID:-}" ]; then
    IDLINE="  machine_id: $MACHINE_ID"
  elif [ -n "${NODE_ID:-}" ]; then
    IDLINE="  node_id: $NODE_ID"
  else
    echo "Thiếu NODE_ID (node đơn) hoặc MACHINE_ID (chế độ machine)"; exit 1
  fi
  cat > "$CFG/config.yml" <<YML
panel:
  url: "$PANEL_URL"
  token: "$TOKEN"
$IDLINE
core:
  bin: "$LIB/lvcore"
  api_port: $API_PORT
  assets_dir: "$GEO"
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
Description=levals-node
After=network.target

[Service]
ExecStart=/usr/local/bin/levals-node -c $CFG/config.yml
${ACME_STAGING:+Environment=LEVALS_ACME_STAGING=1}
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable -q --now levals-node
systemctl restart levals-node

say "Lệnh quản lý: lvnode"
dl "https://raw.githubusercontent.com/harryngne/levals-node-dist/main/lvnode" /usr/local/bin/lvnode 2>/dev/null \
  && chmod +x /usr/local/bin/lvnode \
  && echo "   Dùng: lvnode status | log | restart | update | config | uninstall" \
  || echo "   (không tải được lvnode, bỏ qua)"

say "Xong. Quản lý bằng: lvnode   ·   Log: lvnode log"
