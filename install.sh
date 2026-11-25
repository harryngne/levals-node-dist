#!/bin/bash
# levals-node · cài đặt (chạy bằng root). Chạy lại nhiều lần được.
#
#   curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh | \
#     PANEL_URL=https://dash.levals.org TOKEN=xxxx NODE_ID=1 bash
#
# Biến: PANEL_URL, TOKEN, NODE_ID, ACME_STAGING=1 (test Let's Encrypt staging), BASE,
#       PANEL_KIND=levals|xboard|v2board (mặc định levals — nhận dạng loại panel),
#       NODE_TYPE=shadowsocks|vmess|trojan|vless|hysteria|tuic|anytls|mieru (cần cho xboard/v2board),
#       LEVALS_KEY=<giấy phép phần mềm levals-node> (BẮT BUỘC; khác TOKEN của panel).
# Engine native thuần Rust là mặc định và duy nhất (không cần lõi ngoài).
set -eo pipefail

RED='\033[31m'; GRN='\033[32m'; YEL='\033[33m'; BLU='\033[36m'; NC='\033[0m'
info(){ echo -e "\n${BLU}==${NC} $*"; }
ok(){   echo -e "${GRN}  ✓${NC} $*"; }
warn(){ echo -e "${YEL}  ! $*${NC}"; }
err(){  echo -e "${RED}  ✗ $*${NC}" >&2; exit 1; }
trap 'err "Cài đặt dừng do lỗi (dòng $LINENO)."' ERR

[ "$(id -u)" = 0 ] || err "Hãy chạy bằng root (thử: sudo bash)."

API_PORT=${API_PORT:-10085}
LIB=/usr/local/lib/levals-node
GEO="$LIB/geo"
if [ -n "${INSTANCE:-}" ] && [ "${INSTANCE}" != "default" ] && [ "${INSTANCE}" != "levals-node" ]; then
  CFG="/etc/levals-node-${INSTANCE#levals-node-}"
else
  CFG=/etc/levals-node
fi
BASE=${BASE:-https://github.com/harryngne/levals-node-dist/releases/latest/download}

# ── Trình quản lý gói + cài phụ thuộc ──
PKG=""
for p in apt-get dnf yum apk; do command -v "$p" >/dev/null 2>&1 && { PKG=$p; break; }; done
pkg_install(){
  case "$PKG" in
    apt-get) apt-get update -qq >/dev/null 2>&1; DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$@" >/dev/null 2>&1 ;;
    dnf|yum) "$PKG" install -y -q "$@" >/dev/null 2>&1 ;;
    apk)     apk add --quiet "$@" >/dev/null 2>&1 ;;
    *) return 1 ;;
  esac
}
ensure(){ command -v "$1" >/dev/null 2>&1 && return 0; info "Cài gói thiếu: $2"; pkg_install "$2" && ok "đã cài $2" || warn "không cài được $2 (thử tiếp)"; }

info "Kiểm tra môi trường"
[ -n "$PKG" ] && ok "trình quản lý gói: $PKG" || warn "không rõ trình quản lý gói — bỏ qua tự cài"
command -v systemctl >/dev/null 2>&1 || err "Máy không có systemd — levals-node cần systemd để chạy nền."
ensure curl curl
pkg_install ca-certificates >/dev/null 2>&1 || true
ensure nano nano || true   # cho 'lvnode config'

case "$(uname -m)" in
  x86_64|amd64)  NARCH=x86_64 ;;
  aarch64|arm64) NARCH=aarch64 ;;
  *) err "Kiến trúc $(uname -m) chưa hỗ trợ (chỉ x86_64 / aarch64)." ;;
esac
ok "kiến trúc: $NARCH"

# ── Tải (file tạm → mv; tránh 'Text file busy' khi ghi đè binary đang chạy) ──
dl(){
  curl -fL --retry 3 -o "$2.new" "$1" || err "Không tải được: $1 (kiểm tra mạng / Releases)."
  [ -s "$2.new" ] || err "File tải về rỗng: $1"
  mv -f "$2.new" "$2"
}

info "Tải levals-node"
mkdir -p "$LIB" "$GEO" "$CFG"
dl "$BASE/levals-node-linux-$NARCH" /usr/local/bin/levals-node
chmod +x /usr/local/bin/levals-node
ok "levals-node $(/usr/local/bin/levals-node --version 2>/dev/null | awk '{print $2}')"

# Engine native thuần Rust — không cần lõi ngoài.

# ── Cấu hình ──
info "Cấu hình"
if [ ! -f "$CFG/config.yml" ]; then
  [ -n "${PANEL_URL:-}" ] || err "Thiếu PANEL_URL (vd PANEL_URL=https://dash.levals.org)."
  [ -n "${TOKEN:-}" ]     || err "Thiếu TOKEN (token node / giấy phép / token máy)."
  [ -n "${NODE_ID:-}" ] || err "Thiếu NODE_ID."
  [ -n "${LEVALS_KEY:-}" ] || err "Thiếu LEVALS_KEY (giấy phép phần mềm levals-node — BẮT BUỘC; khác TOKEN của panel)."
  KIND="${PANEL_KIND:-levals}"
  # node_type cần cho panel xboard/v2board (shadowsocks|vmess|trojan|vless|hysteria|tuic|anytls|mieru).
  NTLINE=""
  [ -n "${NODE_TYPE:-}" ] && NTLINE="
node_type: \"$NODE_TYPE\""
  # Cấu trúc config kiểu soga (phẳng); vẫn hỗ trợ khối panel: kiểu cũ.
  # levals_key BẮT BUỘC — thiếu thì node không chạy (KHÁC api_key của panel).
  cat > "$CFG/config.yml" <<YML
server_type: "$KIND"
api_host: "$PANEL_URL"
api_key: "$TOKEN"
node_id: $NODE_ID$NTLINE
levals_key: "$LEVALS_KEY"
core:
  engine: native
config_dir: "$CFG"
log:
  level: "info"
YML
  ok "đã tạo $CFG/config.yml"
else
  ok "giữ $CFG/config.yml sẵn có"
fi

# ── DNS & Routes mặc định (blocklist kiểu soga) ──
info "Tạo cấu hình DNS & Routes mặc định"
if [ ! -f "$CFG/dns.yml" ]; then
  cat > "$CFG/dns.yml" <<'DNS'
strategy: ipv4_first
servers:
  - 1.1.1.1
  - 8.8.8.8
rules:
  - domains: ["keyword:doubleclick", "keyword:adsserver", "keyword:adservice", "keyword:pagead", "keyword:googleads", "keyword:googlesyndication"]
    block: true
  - domains: [ads.google.com, ads.yahoo.com, ads.facebook.com, an.facebook.com, analytics.google.com, pixel.facebook.com, ads-api.twitter.com, tracking.mixpanel.com]
    block: true
DNS
  ok "đã tạo $CFG/dns.yml (blocklist mặc định)"
else
  ok "giữ $CFG/dns.yml sẵn có"
fi

if [ ! -f "$CFG/routes.yml" ]; then
  cat > "$CFG/routes.yml" <<'ROUTES'
# routes.yml — Danh sách chặn mặc định cho levals-node.
# Chặn quảng cáo, tracker, BitTorrent, truy cập mạng nội bộ.

settings:
  block_quic: true
  block_bt: true
  block_private: true

block:
  - type: domain
    values:
      - ads.google.com
      - pagead2.googlesyndication.com
      - googleads.g.doubleclick.net
      - ad.doubleclick.net
      - adservice.google.com
      - adservice.google.com.vn
      - ads.yahoo.com
      - ads.facebook.com
      - an.facebook.com
      - pixel.facebook.com
      - analytics.google.com
      - click.googleanalytics.com
      - ads.pubmatic.com
      - adsserver.yadro.ru
      - tracking.mixpanel.com
      - ads-api.twitter.com
      - crashlogs.whatsapp.net
      - static.ads-twitter.com
      - adtago.s3.amazonaws.com
      - analyticsengine.s3.amazonaws.com
      - r.srvtrck.com
      - random.mean.world
      - piwik.pro
  - type: keyword
    values:
      - torrent
      - tracker
      - announce
      - peer-exchange
      - seed-peer
  - type: ip
    values: []
ROUTES
  ok "đã tạo $CFG/routes.yml (blocklist mặc định)"
else
  ok "giữ $CFG/routes.yml sẵn có"
fi

# ── systemd (tự restart khi token hết hạn / bị ngắt / bị xoá để tự phục hồi ngay khi được cấp lại) ──
info "Dịch vụ systemd"
SVC_NAME="levals-node"
if [ -n "${INSTANCE:-}" ] && [ "${INSTANCE}" != "default" ] && [ "${INSTANCE}" != "levals-node" ]; then
  SVC_NAME="levals-node-${INSTANCE#levals-node-}"
fi
cat > "/etc/systemd/system/${SVC_NAME}.service" <<UNIT
[Unit]
Description=${SVC_NAME}
After=network-online.target
Wants=network-online.target
StartLimitIntervalSec=0

[Service]
ExecStart=/usr/local/bin/levals-node -c $CFG/config.yml
${ACME_STAGING:+Environment=LEVALS_ACME_STAGING=1}
Restart=always
RestartSec=5
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
UNIT

# Gỡ RestartPreventExitStatus=2 trên các instance cũ (nếu có) để mọi instance đều tự restart khi token được bật lại
for u in /etc/systemd/system/levals-node*.service; do
  [ -f "$u" ] || continue
  sed -i '/^RestartPreventExitStatus=/d' "$u" 2>/dev/null || true
  grep -q '^StartLimitIntervalSec=' "$u" 2>/dev/null || sed -i '/^\[Unit\]/a StartLimitIntervalSec=0' "$u" 2>/dev/null || true
done

systemctl daemon-reload
systemctl enable -q --now "$SVC_NAME" 2>/dev/null || systemctl enable -q "$SVC_NAME" 2>/dev/null || true
systemctl restart "$SVC_NAME"

# ── lvnode (lệnh quản lý đa instance phong cách soga) ──
dl "https://raw.githubusercontent.com/harryngne/levals-node-dist/main/lvnode?$(date +%s)" /usr/local/bin/lvnode 2>/dev/null \
  && chmod +x /usr/local/bin/lvnode && ok "lệnh quản lý: lvnode" || warn "không tải được lvnode (bỏ qua)"

# ── Kiểm tra sau khi chạy ──
info "Kiểm tra"
sleep 2
if systemctl is-active --quiet "$SVC_NAME"; then
  ok "$SVC_NAME đang chạy"
  echo -e ""
  echo "Cách sử dụng script quản lý lvnode:"
  echo "--------------------------------------------------------------------"
  echo "lvnode                              - Hiển thị menu quản lý"
  echo "lvnode list                         - Liệt kê các instance & trạng thái"
  echo "lvnode new <name> [k1=v1 ...]       - Tạo instance mới"
  echo "lvnode remove <name> [name...]      - Xoá instance"
  echo "lvnode rename <old_name> <new_name> - Đổi tên instance"
  echo "lvnode start [name]                 - Khởi động instance"
  echo "lvnode stop [name]                  - Dừng instance"
  echo "lvnode restart [name]               - Khởi động lại instance"
  echo "lvnode enable [name]                - Bật tự chạy khi khởi động máy"
  echo "lvnode disable [name]               - Tắt tự chạy khi khởi động máy"
  echo "lvnode log [name]                   - Xem log realtime hợp nhất (agent + client)"
  echo "lvnode config [name]                - Xem file cấu hình"
  echo "lvnode config [name] k1=v1 k2=v2    - Sửa hoặc thêm cấu hình & tự restart"
  echo "lvnode update [version]             - Cài đặt / cập nhật levals-node"
  echo "lvnode uninstall                    - Gỡ cài đặt hoàn toàn levals-node"
  echo "lvnode self-update                  - Cập nhật script quản lý lvnode"
  echo "lvnode version                      - Xem phiên bản"
  echo "--------------------------------------------------------------------"
else
  warn "$SVC_NAME chưa lên ngay — 20 dòng log gần nhất (dịch vụ vẫn đang tự động thử lại nền):"
  journalctl -u "$SVC_NAME" -n 20 --no-pager 2>/dev/null || true
fi
