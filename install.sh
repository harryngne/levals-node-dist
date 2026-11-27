#!/bin/bash
# levals-node · One-click installer (EN / 中文 / Tiếng Việt). Safe to re-run.
#
# Mode 1 — Install first, edit /etc/levals-node/config.yml yourself (XrayR style):
#   bash <(curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh)
#
# Mode 2 — Auto-configure in one command (flags):
#   bash <(curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh) \
#     --server-type levals --api-host https://your-panel.com --api-key YOUR_API_KEY \
#     --node-id 1 --node-type vless --levals-key YOUR_LICENSE_KEY
#
# Mode 3 — Environment variables:
#   curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh | \
#     SERVER_TYPE=levals API_HOST=https://your-panel.com API_KEY=YOUR_API_KEY \
#     NODE_ID=1 NODE_TYPE=vless LEVALS_KEY=YOUR_LICENSE_KEY bash


# ── i18n detection ──
LN="${LVNODE_LANG:-}"
if [ -z "$LN" ]; then
  case "${LANG:-}${LANGUAGE:-}" in
    zh*|ZH*) LN=zh ;;
    vi*|VI*) LN=vi ;;
    *)       LN=en ;;
  esac
fi

_im(){
  case "$1" in
    err_trap)
      case $LN in
        zh) echo "安装因错误中止（第 $LINENO 行）。" ;;
        vi) echo "Cài đặt dừng do lỗi (dòng $LINENO)." ;;
        *)  echo "Installation aborted due to error (line $LINENO)." ;;
      esac ;;
    need_root)
      case $LN in
        zh) echo "请使用 root 权限运行（尝试：sudo bash）。" ;;
        vi) echo "Hãy chạy bằng root (thử: sudo bash)." ;;
        *)  echo "Please run as root (try: sudo bash)." ;;
      esac ;;
    chk_env)
      case $LN in
        zh) echo "检查运行环境" ;;
        vi) echo "Kiểm tra môi trường" ;;
        *)  echo "Checking system environment" ;;
      esac ;;
    pkg_mgr)
      case $LN in
        zh) echo "包管理器" ;;
        vi) echo "trình quản lý gói" ;;
        *)  echo "package manager" ;;
      esac ;;
    no_pkg_mgr)
      case $LN in
        zh) echo "未识别包管理器 — 跳过自动安装依赖" ;;
        vi) echo "không rõ trình quản lý gói — bỏ qua tự cài" ;;
        *)  echo "unknown package manager — skipping auto dependency install" ;;
      esac ;;
    no_systemd)
      case $LN in
        zh) echo "系统未安装 systemd — levals-node 需要 systemd 后台运行。" ;;
        vi) echo "Máy không có systemd — levals-node cần systemd để chạy nền." ;;
        *)  echo "systemd not found — levals-node requires systemd to run as a service." ;;
      esac ;;
    inst_pkg)
      case $LN in
        zh) echo "正在安装缺失依赖" ;;
        vi) echo "Cài gói thiếu" ;;
        *)  echo "Installing missing package" ;;
      esac ;;
    installed)
      case $LN in
        zh) echo "已安装" ;;
        vi) echo "đã cài" ;;
        *)  echo "installed" ;;
      esac ;;
    pkg_warn)
      case $LN in
        zh) echo "无法安装依赖（继续尝试）" ;;
        vi) echo "không cài được gói (thử tiếp)" ;;
        *)  echo "could not install package (continuing)" ;;
      esac ;;
    sysctl_ok)
      case $LN in
        zh) echo "已应用内核网络优化（BBR、MTU 探测、Keepalive、16MB 缓冲区）" ;;
        vi) echo "đã áp dụng tối ưu mạng kernel (BBR, MTU probing, keepalive, buffer 16MB)" ;;
        *)  echo "applied kernel network tuning (BBR, MTU probing, keepalive, 16MB buffers)" ;;
      esac ;;
    reaped_orphan)
      case $LN in
        zh) echo "已清理残留后台 lvnode 进程" ;;
        vi) echo "đã dọn tiến trình lvnode treo cũ" ;;
        *)  echo "cleaned up orphaned lvnode processes" ;;
      esac ;;
    unsup_arch)
      case $LN in
        zh) echo "不支持的架构 $(uname -m)（仅支持 x86_64 / aarch64）。" ;;
        vi) echo "Kiến trúc $(uname -m) chưa hỗ trợ (chỉ x86_64 / aarch64)." ;;
        *)  echo "Unsupported architecture $(uname -m) (only x86_64 / aarch64)." ;;
      esac ;;
    arch_ok)
      case $LN in
        zh) echo "系统架构" ;;
        vi) echo "kiến trúc" ;;
        *)  echo "architecture" ;;
      esac ;;
    dl_fail)
      case $LN in
        zh) echo "下载失败（请检查网络或 Releases）" ;;
        vi) echo "Không tải được (kiểm tra mạng / Releases)" ;;
        *)  echo "Download failed (check network / Releases)" ;;
      esac ;;
    dl_empty)
      case $LN in
        zh) echo "下载的文件为空" ;;
        vi) echo "File tải về rỗng" ;;
        *)  echo "Downloaded file is empty" ;;
      esac ;;
    dl_node)
      case $LN in
        zh) echo "下载 levals-node" ;;
        vi) echo "Tải levals-node" ;;
        *)  echo "Downloading levals-node" ;;
      esac ;;
    cfg_sec)
      case $LN in
        zh) echo "配置文件" ;;
        vi) echo "Cấu hình" ;;
        *)  echo "Configuration" ;;
      esac ;;
    cfg_created)
      case $LN in
        zh) echo "已生成配置文件" ;;
        vi) echo "đã tạo" ;;
        *)  echo "created" ;;
      esac ;;
    cfg_tpl_created)
      case $LN in
        zh) echo "已生成默认配置模板（请编辑填写面板与授权信息后运行 lvnode restart）" ;;
        vi) echo "đã tạo file cấu hình mẫu (hãy sửa thông tin panel & giấy phép rồi chạy lvnode restart)" ;;
        *)  echo "created config template (edit panel & license info, then run: lvnode restart)" ;;
      esac ;;
    cfg_kept)
      case $LN in
        zh) echo "保留现有配置" ;;
        vi) echo "giữ cấu hình sẵn có" ;;
        *)  echo "kept existing" ;;
      esac ;;
    dns_routes_sec)
      case $LN in
        zh) echo "初始化默认 DNS 与路由规则" ;;
        vi) echo "Tạo cấu hình DNS & Routes mặc định" ;;
        *)  echo "Initializing default DNS & Routes" ;;
      esac ;;
    systemd_sec)
      case $LN in
        zh) echo "配置 systemd 服务" ;;
        vi) echo "Dịch vụ systemd" ;;
        *)  echo "Configuring systemd service" ;;
      esac ;;
    lvnode_ok)
      case $LN in
        zh) echo "管理命令已就绪：lvnode" ;;
        vi) echo "lệnh quản lý: lvnode" ;;
        *)  echo "management CLI installed: lvnode" ;;
      esac ;;
    lvnode_warn)
      case $LN in
        zh) echo "未能下载 lvnode 管理脚本（跳过）" ;;
        vi) echo "không tải được lvnode (bỏ qua)" ;;
        *)  echo "could not download lvnode CLI (skipped)" ;;
      esac ;;
    verify_sec)
      case $LN in
        zh) echo "检查运行状态" ;;
        vi) echo "Kiểm tra" ;;
        *)  echo "Verifying service" ;;
      esac ;;
    svc_running)
      case $LN in
        zh) echo "正在运行" ;;
        vi) echo "đang chạy" ;;
        *)  echo "is running" ;;
      esac ;;
    svc_tpl_hint)
      case $LN in
        zh) echo "已安装完成！下一步：请编辑配置文件并重启服务：" ;;
        vi) echo "Đã cài đặt xong! Bước tiếp theo — mở file cấu hình điền thông tin rồi khởi động:" ;;
        *)  echo "Installed! Next step — edit the config file and start the node:" ;;
      esac ;;
    svc_retry_warn)
      case $LN in
        zh) echo "尚未就绪 — 最近 20 行日志（systemd 正在后台自动重试）：" ;;
        vi) echo "chưa lên ngay — 20 dòng log gần nhất (dịch vụ vẫn đang tự động thử lại nền):" ;;
        *)  echo "not active yet — last 20 log lines (systemd is retrying in background):" ;;
      esac ;;
    auto_inst)
      case $LN in
        zh) echo "检测到已有其他节点运行 — 自动创建独立实例" ;;
        vi) echo "Phát hiện VPS đang chạy node khác — tự động tách sang instance độc lập" ;;
        *)  echo "Detected existing active node on this VPS — auto-provisioning isolated instance" ;;
      esac ;;
  esac
}

# ── Parse --flags (override env; supports primary names + legacy aliases) ──
while [[ $# -gt 0 ]]; do
  case "$1" in
    --server-type|--panel-kind) SERVER_TYPE="$2"; shift 2 ;;
    --server-type=*)            SERVER_TYPE="${1#*=}"; shift ;;
    --panel-kind=*)             SERVER_TYPE="${1#*=}"; shift ;;
    --api-host|--panel-url)     API_HOST="$2"; shift 2 ;;
    --api-host=*)               API_HOST="${1#*=}"; shift ;;
    --panel-url=*)              API_HOST="${1#*=}"; shift ;;
    --api-key|--token)          API_KEY="$2"; shift 2 ;;
    --api-key=*)                API_KEY="${1#*=}"; shift ;;
    --token=*)                  API_KEY="${1#*=}"; shift ;;
    --node-id)                  NODE_ID="$2"; shift 2 ;;
    --node-id=*)                NODE_ID="${1#*=}"; shift ;;
    --machine-id)               MACHINE_ID="$2"; shift 2 ;;
    --machine-id=*)             MACHINE_ID="${1#*=}"; shift ;;
    --node-type)                NODE_TYPE="$2"; shift 2 ;;
    --node-type=*)              NODE_TYPE="${1#*=}"; shift ;;
    --levals-key|--license)     LEVALS_KEY="$2"; shift 2 ;;
    --levals-key=*)             LEVALS_KEY="${1#*=}"; shift ;;
    --license=*)                LEVALS_KEY="${1#*=}"; shift ;;
    --instance)                 INSTANCE="$2"; shift 2 ;;
    --instance=*)               INSTANCE="${1#*=}"; shift ;;
    --lang)                     LN="$2"; shift 2 ;;
    --lang=*)                   LN="${1#--lang=}"; shift ;;
    --staging)                  ACME_STAGING=1; shift ;;
    --help|-h)
      echo "Usage: bash install.sh [OPTIONS]"
      echo ""
      echo "Run without arguments to install binary & generate /etc/levals-node/config.yml template,"
      echo "or pass options below for zero-touch provisioning:"
      echo ""
      echo "Options:"
      echo "  --server-type TYPE  Panel type: levals|xboard|v2board (default: levals)"
      echo "  --api-host URL      Panel URL (e.g. https://dash.levals.org)"
      echo "  --api-key KEY       Node API communication key from panel"
      echo "  --node-id ID        Node ID on panel (or use --machine-id)"
      echo "  --machine-id ID     Machine ID on Levals panel (multi-node machine mode)"
      echo "  --node-type TYPE    Protocol: shadowsocks|vmess|trojan|vless|hysteria|tuic|anytls|mieru|naive"
      echo "  --levals-key KEY    Software license key (levals_key; alias: --license)"
      echo "  --instance NAME     Instance name (multi-instance)"
      echo "  --lang LANG         CLI output language: en|zh|vi"
      echo "  --staging           Use Let's Encrypt staging"
      echo "  -h, --help          Show this help"
      exit 0 ;;
    *) echo "Unknown option: $1 (use --help)"; exit 1 ;;
  esac
done

# Backward-compatible environment variable aliases
SERVER_TYPE="${SERVER_TYPE:-${PANEL_KIND:-}}"
API_HOST="${API_HOST:-${PANEL_URL:-}}"
API_KEY="${API_KEY:-${TOKEN:-}}"

set -eo pipefail

RED='\033[31m'; GRN='\033[32m'; YEL='\033[33m'; BLU='\033[36m'; CYN='\033[96m'; NC='\033[0m'
info(){ echo -e "\n${BLU}==${NC} $*"; }
ok(){   echo -e "${GRN}  ✓${NC} $*"; }
warn(){ echo -e "${YEL}  ! $*${NC}"; }
err(){  echo -e "${RED}  ✗ $*${NC}" >&2; exit 1; }
trap 'err "$(_im err_trap)"' ERR

[ "$(id -u)" = 0 ] || err "$(_im need_root)"

# Reap any orphaned / runaway lvnode processes from older versions (>3s CPU or lost SSH TTY)
reap_orphan_lvnode(){
  local killed=0 pid cput tty cmd
  while read -r pid cput tty cmd; do
    [ -n "$pid" ] || continue
    [ "$pid" = "$$" ] && continue
    [ "$pid" = "$PPID" ] && continue
    case "$cmd" in
      */lvnode*|*"lvnode")
        if [ "$tty" = "?" ] || [ "${cput:-0}" -ge 3 ] 2>/dev/null; then
          kill -9 "$pid" 2>/dev/null && killed=$((killed + 1)) || true
        fi
        ;;
    esac
  done < <(ps -eo pid=,cputimes=,tty=,args= 2>/dev/null || true)
  [ "$killed" -gt 0 ] && ok "$(_im reaped_orphan): $killed" || true
}
reap_orphan_lvnode

yaml_val(){
  local f="$1" k="$2"
  [ -f "$f" ] || return 0
  awk -F':' -v k="$k" '
    $0 ~ "^[[:space:]]*"k"[[:space:]]*:" {
      sub("^[[:space:]]*"k"[[:space:]]*:[[:space:]]*", "", $0)
      sub("[[:space:]]+#.*$", "", $0)
      gsub(/^["'\'']|["'\'']$/, "", $0)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)
      print $0
      exit
    }
  ' "$f"
}

API_PORT=${API_PORT:-10085}
LIB=/usr/local/lib/levals-node
GEO="$LIB/geo"

# Auto-detect multi-node on the same VPS when --instance / INSTANCE is not explicitly passed
FORCE_WRITE_CFG=0
if [ -z "${INSTANCE:-}" ] && [ -n "${API_HOST:-}" ] && [ -n "${API_KEY:-}" ] && { [ -n "${NODE_ID:-}" ] || [ -n "${MACHINE_ID:-}" ]; } && [ -n "${LEVALS_KEY:-}" ]; then
  norm_url="${API_HOST%/}"
  matched_dir=""
  for d in /etc/levals-node /etc/levals-node-*; do
    [ -f "$d/config.yml" ] || continue
    eh="$(yaml_val "$d/config.yml" api_host)"; [ -z "$eh" ] && eh="$(yaml_val "$d/config.yml" url)"
    eh="${eh%/}"
    en="$(yaml_val "$d/config.yml" node_id)"
    em="$(yaml_val "$d/config.yml" machine_id)"
    et="$(yaml_val "$d/config.yml" node_type)"
    if [ -n "${MACHINE_ID:-}" ]; then
      if [ "$eh" = "$norm_url" ] && [ "$em" = "$MACHINE_ID" ]; then
        matched_dir="$d"
        break
      fi
    elif [ "$eh" = "$norm_url" ] && [ "$en" = "$NODE_ID" ] && [ "${et:-}" = "${NODE_TYPE:-}" ]; then
      matched_dir="$d"
      break
    fi
  done

  if [ -n "$matched_dir" ]; then
    if [ "$matched_dir" = "/etc/levals-node" ]; then
      INSTANCE="default"
    else
      INSTANCE="${matched_dir#/etc/levals-node-}"
    fi
    FORCE_WRITE_CFG=1
  elif [ -f "/etc/levals-node/config.yml" ]; then
    base_host="$(yaml_val /etc/levals-node/config.yml api_host)"
    base_key="$(yaml_val /etc/levals-node/config.yml api_key)"
    if [ -n "$base_host" ] && [ "$base_host" != "https://your-panel.example.com" ] && [ "$base_key" != "YOUR_API_KEY" ] && [ "$base_key" != "YOUR_PANEL_COMMUNICATION_KEY" ]; then
      if [ -n "${MACHINE_ID:-}" ]; then
        cand="machine${MACHINE_ID}"
      else
        cand="node${NODE_ID}"
        [ -n "${NODE_TYPE:-}" ] && [ -e "/etc/levals-node-${cand}" ] && cand="node${NODE_ID}-${NODE_TYPE}"
      fi
      idx=2
      while [ -e "/etc/levals-node-${cand}" ]; do
        cand="node${NODE_ID:-m${MACHINE_ID}}-${idx}"
        idx=$((idx + 1))
      done
      INSTANCE="$cand"
      ok "$(_im auto_inst): levals-node-${INSTANCE}"
    else
      FORCE_WRITE_CFG=1
    fi
  fi
fi

if [ -n "${INSTANCE:-}" ] && [ "${INSTANCE}" != "default" ] && [ "${INSTANCE}" != "levals-node" ]; then
  CFG="/etc/levals-node-${INSTANCE#levals-node-}"
else
  CFG=/etc/levals-node
fi
BASE=${BASE:-https://github.com/harryngne/levals-node-dist/releases/latest/download}

# ── Package manager + dependencies ──
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
ensure(){ command -v "$1" >/dev/null 2>&1 && return 0; info "$(_im inst_pkg): $2"; pkg_install "$2" && ok "$(_im installed) $2" || warn "$(_im pkg_warn): $2"; }

info "$(_im chk_env)"
[ -n "$PKG" ] && ok "$(_im pkg_mgr): $PKG" || warn "$(_im no_pkg_mgr)"
command -v systemctl >/dev/null 2>&1 || err "$(_im no_systemd)"
ensure curl curl
pkg_install ca-certificates >/dev/null 2>&1 || true
ensure nano nano || true
ensure ip iproute2 || true
ensure wg wireguard-tools || true
ensure iptables iptables || true

# ── Kernel sysctl tuning (BBR, MTU probing, keepalive, 16MB buffers) ──
tune_sysctls(){
  modprobe tcp_bbr 2>/dev/null || true
  mkdir -p /etc/sysctl.d 2>/dev/null || true
  cat > /etc/sysctl.d/99-levals-node.conf <<'SYSCTL'
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_keepalive_time = 25
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_slow_start_after_idle = 0
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.rmem_default = 1048576
net.core.wmem_default = 1048576
net.core.netdev_max_backlog = 16384
net.core.somaxconn = 8192
net.ipv4.ip_local_port_range = 10240 65535
SYSCTL
  sysctl --system >/dev/null 2>&1 || sysctl -p /etc/sysctl.d/99-levals-node.conf >/dev/null 2>&1 || true
}
tune_sysctls
ok "$(_im sysctl_ok)"

# ── Cleanup legacy xbn-kcfg cron & sgw* WireGuard interfaces ──
cleanup_legacy_wg(){
  if ! systemctl is-active --quiet xboard-node 2>/dev/null; then
    if crontab -l 2>/dev/null | grep -q 'xbn-kcfg'; then
      crontab -l 2>/dev/null | grep -v 'xbn-kcfg' | crontab - 2>/dev/null || true
    fi
    rm -f /etc/cron.d/xbn-kcfg* /usr/local/bin/xbn-kcfg*.sh 2>/dev/null || true
    for dev in $(ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -E '^sgw[0-9]+$' || true); do
      wg-quick down "$dev" >/dev/null 2>&1 || ip link del "$dev" >/dev/null 2>&1 || true
      systemctl disable --now "wg-quick@${dev}" >/dev/null 2>&1 || true
    done
  fi
}
cleanup_legacy_wg

case "$(uname -m)" in
  x86_64|amd64)  NARCH=x86_64 ;;
  aarch64|arm64) NARCH=aarch64 ;;
  *) err "$(_im unsup_arch)" ;;
esac
ok "$(_im arch_ok): $NARCH"

dl(){
  curl -fL --retry 3 -o "$2.new" "$1" || err "$(_im dl_fail): $1"
  [ -s "$2.new" ] || err "$(_im dl_empty): $1"
  mv -f "$2.new" "$2"
}

info "$(_im dl_node)"
mkdir -p "$LIB" "$GEO" "$CFG"
dl "$BASE/levals-node-linux-$NARCH" /usr/local/bin/levals-node
chmod +x /usr/local/bin/levals-node
ok "levals-node $(/usr/local/bin/levals-node --version 2>/dev/null | awk '{print $2}')"

# ── Configuration (supports both zero-touch flags/env AND template-first XrayR workflow) ──
TEMPLATE_MODE=0
info "$(_im cfg_sec)"
if [ ! -f "$CFG/config.yml" ] || [ "$FORCE_WRITE_CFG" = "1" ]; then
  if [ -n "${API_HOST:-}" ] && [ -n "${API_KEY:-}" ] && { [ -n "${NODE_ID:-}" ] || [ -n "${MACHINE_ID:-}" ]; } && [ -n "${LEVALS_KEY:-}" ]; then
    KIND="${SERVER_TYPE:-levals}"
    if [ -n "${MACHINE_ID:-}" ]; then
      ID_LINE="machine_id: $MACHINE_ID"
      NT_LINE="# node_type: \"vless\"                        # shadowsocks|vmess|trojan|vless|hysteria|tuic|anytls|mieru|naive"
    else
      ID_LINE="node_id: $NODE_ID
# machine_id: 1"
      if [ -n "${NODE_TYPE:-}" ]; then
        NT_LINE="node_type: \"$NODE_TYPE\"                        # shadowsocks|vmess|trojan|vless|hysteria|tuic|anytls|mieru|naive"
      elif [ "$KIND" != "levals" ]; then
        NT_LINE="node_type: \"vless\"                          # shadowsocks|vmess|trojan|vless|hysteria|tuic|anytls|mieru|naive"
      else
        NT_LINE="# node_type: \"vless\"                        # Required for xboard/v2board: shadowsocks|vmess|trojan|vless|hysteria|tuic|anytls|mieru|naive"
      fi
    fi
    cat > "$CFG/config.yml" <<YML
server_type: "$KIND"                        # levals | xboard | v2board
api_host: "$API_HOST"
api_key: "$API_KEY"
$ID_LINE
$NT_LINE
levals_key: "$LEVALS_KEY"

# Single-process multi-node integration (optional):
# nodes:
#   - node_id: 1
#   - node_id: 2
#     node_type: "trojan"

udp_fullcone: true                          # RFC 3489 UDP FullCone NAT across all protocols
auto_out_ip: false                          # Multi-IP: bind outbound IP to client's inbound local IP
# send_through: "203.0.113.10"              # Force fixed outbound source IP (optional)
proxy_protocol: false                       # Parse PROXY Protocol v1/v2 for real client IP

limit:
  speed_limit: 0                            # Default fixed speed limit in Mbps (0 = panel default)
  user_tcp_limit: 0                         # Max concurrent TCP connections per user (0 = panel default)
  user_ip_limit: 0                          # Max concurrent IPs per user (0 = panel default)
  user_device_limit: 0                      # Max global devices per user (0 = panel default)
  dynamic_speed:
    enable: false
    traffic_mb: 500
    periodic_sec: 60
    limit_mbps: 20
    expire_sec: 300

redis:
  enable: false
  addr: "127.0.0.1:6379"                    # host:port | redis://:pass@host:6379/0 | rediss://...
  username: ""
  password: ""
  db: 0
  tls: false
  key_prefix: "lvnode"
  expiry_sec: 60

sniffing:
  enabled: true                             # Also remotely controllable from Levals Web Panel
  route_only: false
  dest_override: ["tls", "http", "quic", "fakedns"]
  domains_excluded:
    - "courier.push.apple.com"

core:
  engine: native

config_dir: "$CFG"

log:
  level: "info"                             # trace | debug | info | warn | error
  # access: "$CFG/access.log"

# acme:
#   dns_provider: "cloudflare"              # cloudflare | dnspod | alidns | gcore
#   cf_token: "CLOUDFLARE_API_TOKEN"
YML
    ok "$(_im cfg_created) $CFG/config.yml"
  else
    TEMPLATE_MODE=1
    KIND="${SERVER_TYPE:-xboard}"
    if [ -n "${MACHINE_ID:-}" ]; then
      ID_TPL="machine_id: ${MACHINE_ID}"
    else
      ID_TPL="node_id: ${NODE_ID:-1}
# machine_id: 1"
    fi
    cat > "$CFG/config.yml" <<YML
# levals-node configuration (YAML / JSON)
# Edit with: lvnode config -e   (or: nano $CFG/config.yml)
# Apply with: lvnode restart

server_type: "${KIND}"                      # levals | xboard | v2board
api_host: "${API_HOST:-https://your-panel.example.com}"
api_key: "${API_KEY:-YOUR_API_KEY}"
${ID_TPL}
node_type: "${NODE_TYPE:-vless}"            # Required for xboard/v2board: vless|vmess|trojan|shadowsocks|hysteria|tuic|anytls|mieru|naive
levals_key: "${LEVALS_KEY:-YOUR_LEVALS_LICENSE_KEY}"

# Single-process multi-node integration (optional):
# nodes:
#   - node_id: 1
#   - node_id: 2
#     node_type: "trojan"

udp_fullcone: true                          # RFC 3489 UDP FullCone NAT across all protocols
auto_out_ip: false                          # Multi-IP: bind outbound IP to client's inbound local IP
# send_through: "203.0.113.10"              # Force fixed outbound source IP (optional)
proxy_protocol: false                       # Parse PROXY Protocol v1/v2 for real client IP

limit:
  speed_limit: 0                            # Default fixed speed limit in Mbps (0 = panel default)
  user_tcp_limit: 0                         # Max concurrent TCP connections per user (0 = panel default)
  user_ip_limit: 0                          # Max concurrent IPs per user (0 = panel default)
  user_device_limit: 0                      # Max global devices per user (0 = panel default)
  dynamic_speed:
    enable: false
    traffic_mb: 500
    periodic_sec: 60
    limit_mbps: 20
    expire_sec: 300

redis:
  enable: false
  addr: "127.0.0.1:6379"                    # host:port | redis://:pass@host:6379/0 | rediss://...
  username: ""
  password: ""
  db: 0
  tls: false
  key_prefix: "lvnode"
  expiry_sec: 60

sniffing:
  enabled: true                             # Also remotely controllable from Levals Web Panel
  route_only: false
  dest_override: ["tls", "http", "quic", "fakedns"]
  domains_excluded:
    - "courier.push.apple.com"

core:
  engine: native

config_dir: "$CFG"

log:
  level: "info"                             # trace | debug | info | warn | error
  # access: "$CFG/access.log"

# acme:
#   dns_provider: "cloudflare"              # cloudflare | dnspod | alidns | gcore
#   cf_token: "CLOUDFLARE_API_TOKEN"
YML
    ok "$(_im cfg_tpl_created): $CFG/config.yml"
  fi
else
  ok "$(_im cfg_kept) $CFG/config.yml"
fi

# ── Default DNS & Routes ──
info "$(_im dns_routes_sec)"
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
  ok "$(_im cfg_created) $CFG/dns.yml"
else
  ok "$(_im cfg_kept) $CFG/dns.yml"
fi

if [ ! -f "$CFG/routes.yml" ]; then
  cat > "$CFG/routes.yml" <<'ROUTES'
settings:
  block_quic: true
  block_bt: true
  block_private: true
  sniffing: true

whitelist:
  - type: domain
    values: []

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
  - type: regex
    values: []
  - type: ip
    values: []
ROUTES
  ok "$(_im cfg_created) $CFG/routes.yml"
else
  ok "$(_im cfg_kept) $CFG/routes.yml"
fi

# ── systemd service ──
info "$(_im systemd_sec)"
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

for u in /etc/systemd/system/levals-node*.service; do
  [ -f "$u" ] || continue
  sed -i '/^RestartPreventExitStatus=/d' "$u" 2>/dev/null || true
  grep -q '^StartLimitIntervalSec=' "$u" 2>/dev/null || sed -i '/^\[Unit\]/a StartLimitIntervalSec=0' "$u" 2>/dev/null || true
done

systemctl daemon-reload
systemctl enable -q "$SVC_NAME" 2>/dev/null || true

# ── lvnode CLI ──
dl "https://raw.githubusercontent.com/harryngne/levals-node-dist/main/lvnode?$(date +%s)" /usr/local/bin/lvnode 2>/dev/null \
  && chmod +x /usr/local/bin/lvnode && ok "$(_im lvnode_ok)" || warn "$(_im lvnode_warn)"

if [ "$TEMPLATE_MODE" = "1" ]; then
  echo -e ""
  ok "$(_im svc_tpl_hint)"
  echo -e "  1. ${CYN}lvnode config -e${NC}   (nano $CFG/config.yml)"
  echo -e "  2. ${CYN}lvnode restart${NC}"
  echo -e "  3. ${CYN}lvnode log${NC}"
  [ -x /usr/local/bin/lvnode ] && LVNODE_LANG="$LN" /usr/local/bin/lvnode --lang "$LN" --help || true
  exit 0
fi

# Restart any active sibling instances onto the newly downloaded binary first so all nodes register WireGuard leases
for u in /etc/systemd/system/levals-node.service /etc/systemd/system/levals-node-*.service; do
  [ -f "$u" ] || continue
  sib="$(basename "$u" .service)"
  [ "$sib" = "$SVC_NAME" ] && continue
  if systemctl is-active --quiet "$sib" 2>/dev/null; then
    systemctl restart "$sib" 2>/dev/null || true
  fi
done

systemctl restart "$SVC_NAME"

# ── Verify after start ──
info "$(_im verify_sec)"
sleep 2
if systemctl is-active --quiet "$SVC_NAME"; then
  ok "$SVC_NAME $(_im svc_running)"
  [ -x /usr/local/bin/lvnode ] && LVNODE_LANG="$LN" /usr/local/bin/lvnode --lang "$LN" --help || true
else
  warn "$SVC_NAME $(_im svc_retry_warn)"
  journalctl -u "$SVC_NAME" -n 20 --no-pager 2>/dev/null || true
fi
