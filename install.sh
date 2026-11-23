#!/bin/bash
# levals-node · cài đặt (chạy bằng root). Chạy lại nhiều lần được.
#
#   curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh | \
#     PANEL_URL=https://dash.levals.org TOKEN=xxxx NODE_ID=1 bash
#
# Biến: PANEL_URL, TOKEN, NODE_ID, ACME_STAGING=1 (test Let's Encrypt staging), BASE,
#       PANEL_KIND=levals|xboard|v2board (mặc định levals — nhận dạng loại panel),
#       NODE_TYPE=shadowsocks|vmess|trojan|vless|hysteria|tuic (cần cho xboard/v2board),
#       LEVALS_KEY=<giấy phép phần mềm levals-node> (khác api_key của panel).
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
CFG=/etc/levals-node
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
  KIND="${PANEL_KIND:-levals}"
  # node_type cần cho panel xboard/v2board (shadowsocks|vmess|trojan|vless|hysteria|tuic).
  NTLINE=""
  [ -n "${NODE_TYPE:-}" ] && NTLINE="
node_type: \"$NODE_TYPE\""
  # Giấy phép phần mềm levals-node (KHÁC api_key của panel).
  LKLINE=""
  [ -n "${LEVALS_KEY:-}" ] && LKLINE="
levals_key: \"$LEVALS_KEY\""
  # Cấu trúc config kiểu soga (phẳng); vẫn hỗ trợ khối panel: kiểu cũ.
  cat > "$CFG/config.yml" <<YML
server_type: "$KIND"
api_host: "$PANEL_URL"
api_key: "$TOKEN"
node_id: $NODE_ID$NTLINE$LKLINE
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

# ── systemd ──
info "Dịch vụ systemd"
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
systemctl enable -q --now levals-node 2>/dev/null || systemctl enable -q levals-node 2>/dev/null || true
systemctl restart levals-node

# ── lvnode (lệnh quản lý) ──
dl "https://raw.githubusercontent.com/harryngne/levals-node-dist/main/lvnode" /usr/local/bin/lvnode 2>/dev/null \
  && chmod +x /usr/local/bin/lvnode && ok "lệnh quản lý: lvnode" || warn "không tải được lvnode (bỏ qua)"

# ── Kiểm tra sau khi chạy ──
info "Kiểm tra"
sleep 2
if systemctl is-active --quiet levals-node; then
  ok "levals-node đang chạy"
  echo -e "\n${GRN}Xong.${NC} Quản lý: ${BLU}lvnode${NC}   ·   Log: ${BLU}lvnode log${NC}"
else
  warn "levals-node chưa chạy — 20 dòng log gần nhất:"
  journalctl -u levals-node -n 20 --no-pager 2>/dev/null || true
  err "Dịch vụ chưa lên. Thường do: token sai/hết hạn, sai PANEL_URL, hoặc cổng 443/80 bị chiếm."
fi
