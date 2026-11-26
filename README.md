<p align="center">
  <h1 align="center">levals-node</h1>
  <p align="center">
    <b>High-performance VPN node agent written in pure Rust — no external core needed</b>
  </p>
  <p align="center">
    <img src="https://img.shields.io/badge/license-Proprietary-red?style=flat-square" alt="License">
    <img src="https://img.shields.io/badge/arch-x86__64%20%7C%20aarch64-blue?style=flat-square" alt="Arch">
    <img src="https://img.shields.io/badge/language-Rust-orange?style=flat-square" alt="Rust">
    <img src="https://img.shields.io/badge/OS-Linux-green?style=flat-square" alt="OS">
  </p>
</p>

---

**Language / 语言 / Ngôn ngữ:**&ensp;[English](#english)&ensp;|&ensp;[中文](#中文)&ensp;|&ensp;[Tiếng Việt](#tiếng-việt)

---

# English

## Features

| Feature | Description |
|---------|-------------|
| 🦀 Pure Rust Engine | Native Rust binary — no sing-box, no xray, no external core needed |
| 🖥️ Panel Support | Xboard / V2Board / Levals panel — auto-detect or manual config |
| 🔄 Hot-Reload Users | Add/remove users instantly without restarting the service |
| 📡 Multi-Panel | Run multiple panels on a single server simultaneously |
| 🌐 WebSocket Sync | Real-time WebSocket connection with panel for instant updates |
| 🔒 Auto TLS | Automatic certificate via Let's Encrypt (HTTP-01 / DNS-01) |
| ⚡ Per-User Limits | Speed limit, traffic counting, online IP limit per user |
| 🧭 Custom DNS | Domain-based DNS routing, IP pinning, ad blocking |
| 🛡️ Routes & Rules | Block ads, trackers, BitTorrent, private networks |
| 🔍 Traffic Sniffing | TLS SNI, HTTP Host, QUIC Initial SNI, BitTorrent DPI & Fake-IP resolution |
| 🔧 Multi-Instance | Manage multiple instances via `lvnode` CLI |
| ♻️ Auto-Restart | Automatic restart on token expiry or revocation |

## Supported Protocols

| Protocol | Description |
|----------|-------------|
| **Trojan** | TLS tunnel proxy |
| **VLESS** | UUID authentication, REALITY (X25519 + X25519MLKEM768 post-quantum), XTLS Vision |
| **VMess** | VMessAEAD (TCP + UDP) |
| **Shadowsocks** | AEAD + 2022-blake3, multi-user EIH, TCP + UDP |
| **SOCKS5** | CONNECT + UDP ASSOCIATE |
| **HTTP** | HTTP CONNECT proxy |
| **NaiveProxy** | HTTP CONNECT over TLS |
| **TUIC** | v5 over QUIC |
| **Hysteria2** | QUIC + Salamander obfuscation |
| **AnyTLS** | v1/v2, TLS/REALITY/WS/HTTPUpgrade/XHTTP, dynamic padding, UDP-over-TCP |
| **Mieru** | v3, TCP/UDP, XChaCha20-Poly1305, Low-Entropy traffic pattern |

## Supported Transports

| Transport | Notes |
|-----------|-------|
| **TCP** | Raw TCP |
| **WebSocket** | `ws` |
| **gRPC** | GunService |
| **HTTPUpgrade** | HTTP/1.1 upgrade |
| **XHTTP / SplitHTTP** | stream-one / stream-up / packet-up, HTTP/2 & HTTP/3 |

## Quick Install

**Option 1 — Install & edit config file manually (XrayR style):**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh)
```

Then edit `/etc/levals-node/config.yml` and start the service:

```bash
lvnode config -e     # or: nano /etc/levals-node/config.yml
lvnode restart
```

**Option 2 — Zero-touch one-line install:**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh) \
  --panel-url https://your-panel.com \
  --token YOUR_NODE_TOKEN \
  --node-id 1 \
  --license YOUR_LICENSE_KEY
```

*(For Xboard / V2Board, append `--panel-kind xboard --node-type vless`)*

**Option 3 — Environment variables:**

```bash
curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh | \
  PANEL_URL=https://your-panel.com TOKEN=YOUR_TOKEN NODE_ID=1 LEVALS_KEY=YOUR_LICENSE bash
```

## Configuration

Config file: `/etc/levals-node/config.yml`

### Config Fields

| Field | Required | Description |
|-------|----------|-------------|
| `server_type` | No | Panel type: `levals` (default) / `xboard` / `v2board` |
| `api_host` | Yes | Panel URL |
| `api_key` | Yes | Node communication token from panel |
| `node_id` | Yes | Node ID on panel |
| `node_type` | Xboard only | Protocol: `shadowsocks` / `vmess` / `trojan` / `vless` / `hysteria` / `tuic` / `anytls` / `mieru` |
| `levals_key` | Yes | Software license key (different from `api_key`) |

### Example — Levals Panel

```yaml
server_type: "levals"
api_host: "https://dash.levals.org"
api_key: "YOUR_NODE_TOKEN"
node_id: 1
levals_key: "YOUR_LICENSE_KEY"

core:
  engine: native
```

### Example — Xboard Panel

```yaml
server_type: "xboard"
api_host: "https://xboard.example.com"
api_key: "YOUR_NODE_TOKEN"
node_id: 1
node_type: "vless"
levals_key: "YOUR_LICENSE_KEY"

core:
  engine: native
```

### Example — V2Board Panel

```yaml
server_type: "v2board"
api_host: "https://v2board.example.com"
api_key: "YOUR_NODE_TOKEN"
node_id: 1
node_type: "trojan"
levals_key: "YOUR_LICENSE_KEY"

core:
  engine: native
```

## Management CLI — `lvnode`

```
lvnode                              Interactive management menu
lvnode list                         List instances & status
lvnode new <name> [k1=v1 ...]       Create new instance
lvnode remove <name> [name...]      Remove instance(s)
lvnode rename <old> <new>           Rename instance
lvnode start [name]                 Start instance
lvnode stop [name]                  Stop instance
lvnode restart [name]               Restart instance
lvnode enable [name]                Enable auto-start on boot
lvnode disable [name]               Disable auto-start
lvnode log [name]                   Real-time merged log
lvnode log [name] -n <N>            Show last N log lines
lvnode config [name]                View config
lvnode config [name] -e             Edit config in editor
lvnode config [name] k1=v1 k2=v2    Modify config fields & auto-restart
lvnode update [version]             Install or update levals-node binary
lvnode uninstall                    Full uninstall
lvnode self-update                  Update the lvnode script itself
lvnode version                      Show version
```

## TLS Certificate

| Method | Description |
|--------|-------------|
| **HTTP-01** | Auto via Let's Encrypt — no config needed (port 80 must be open) |
| **DNS-01** | Cloudflare, DNSPod, Aliyun, Gcore — configure in panel UI or config file |
| **REALITY** | No certificate needed — zero-config TLS |
| **Custom** | Provide your own cert/key path |

DNS-01 provider variables:

| Provider | Variables |
|----------|-----------|
| Cloudflare | `CF_DNS_API_TOKEN` |
| DNSPod | `DP_Id` + `DP_Key` |
| Aliyun | `Ali_Key` + `Ali_Secret` |
| Gcore | `GCORE_API_TOKEN` |

> **Tip:** Configure DNS-01 directly from the panel UI for the easiest setup.

## Custom DNS (Optional)

Place `dns.yml` next to `config.yml` in `/etc/levals-node/`:

```yaml
strategy: ipv4_first          # ipv4_first | ipv6_first | ipv4_only | ipv6_only
servers:
  - 1.1.1.1
  - 8.8.8.8:53
rules:
  - domains: [netflix.com, nflxvideo.net, "keyword:disney"]
    server: 1.0.0.1           # Route these domains to a specific DNS
  - domain: pin.example.com
    ip: 203.0.113.9            # Pin domain to a static IP (like /etc/hosts)
  - domains: [ads.tracker.net, "keyword:doubleclick"]
    block: true                # Block resolution entirely
```

## Routes & Rules (Optional)

Place `routes.yml` next to `config.yml` in `/etc/levals-node/`:

```yaml
settings:
  block_quic: true             # Block QUIC/HTTP3 (UDP 443) — force TCP
  block_bt: true               # Block BitTorrent traffic
  block_private: true          # Block access to private IP ranges

block:
  - type: domain
    values:
      - ads.google.com
      - googleads.g.doubleclick.net
  - type: keyword
    values:
      - torrent
      - tracker
  - type: ip
    values: []
```

## Multi-Panel on Single Server

Use `panels:` instead of single panel fields in your config:

```yaml
panels:
  - api_host: "https://panel1.example.com"
    api_key: "TOKEN_PANEL_1"
    node_id: 1
  - api_host: "https://panel2.example.com"
    api_key: "TOKEN_PANEL_2"
    node_id: 2

levals_key: "YOUR_LICENSE_KEY"
core:
  engine: native
```

> **Note:** Ensure each panel's node uses a different `server_port` to avoid port conflicts.

## Supported Panels

| Panel | Compatibility |
|-------|---------------|
| **Levals** | ✅ Full support — auto-detect protocol from panel |
| **Xboard** | ✅ Full support — requires `node_type` in config |
| **V2Board** | ✅ Full support — requires `node_type` in config |

## System Requirements

| Requirement | Minimum |
|-------------|---------|
| **OS** | Linux (Ubuntu 18.04+, Debian 10+, CentOS 7+, AlmaLinux, Rocky, etc.) |
| **Architecture** | x86_64 / aarch64 (ARM64) |
| **RAM** | ≥ 128 MB |
| **Dependencies** | None — pure Rust static binary |

## License

**Proprietary** — Copyright © 2026 Levals. All rights reserved.

A valid license key (`levals_key`) is required. Contact your administrator for licensing.

---

# 中文

## 功能特性

| 功能 | 描述 |
|------|------|
| 🦀 纯 Rust 引擎 | 原生 Rust 二进制 — 无需 sing-box、xray 或任何外部内核 |
| 🖥️ 面板支持 | 支持 Xboard / V2Board / Levals 面板 — 自动检测或手动配置 |
| 🔄 热重载用户 | 即时添加/删除用户，无需重启服务 |
| 📡 多面板 | 单台服务器同时运行多个面板 |
| 🌐 WebSocket 同步 | 与面板实时 WebSocket 连接，即时同步更新 |
| 🔒 自动 TLS | 通过 Let's Encrypt 自动签发证书（HTTP-01 / DNS-01） |
| ⚡ 用户级限制 | 每用户速率限制、流量统计、在线 IP 限制 |
| 🧭 自定义 DNS | 基于域名的 DNS 路由、IP 固定、广告拦截 |
| 🛡️ 路由规则 | 拦截广告、追踪器、BitTorrent、私有网络 |
| 🔍 流量嗅探 | TLS SNI、HTTP Host、QUIC Initial SNI、BitTorrent 深度识别与 Fake-IP 还原 |
| 🔧 多实例管理 | 通过 `lvnode` CLI 管理多个实例 |
| ♻️ 自动重启 | Token 过期或撤销时自动重启 |

## 支持协议

| 协议 | 描述 |
|------|------|
| **Trojan** | TLS 隧道代理 |
| **VLESS** | UUID 认证，REALITY（X25519 + X25519MLKEM768 后量子加密），XTLS Vision |
| **VMess** | VMessAEAD（TCP + UDP） |
| **Shadowsocks** | AEAD + 2022-blake3，多用户 EIH，TCP + UDP |
| **SOCKS5** | CONNECT + UDP ASSOCIATE |
| **HTTP** | HTTP CONNECT 代理 |
| **NaiveProxy** | 基于 TLS 的 HTTP CONNECT |
| **TUIC** | v5 over QUIC |
| **Hysteria2** | QUIC + Salamander 混淆 |
| **AnyTLS** | v1/v2，TLS/REALITY/WS/HTTPUpgrade/XHTTP，动态填充，UDP-over-TCP |
| **Mieru** | v3，TCP/UDP，XChaCha20-Poly1305，低熵流量模式 |

## 支持传输方式

| 传输方式 | 说明 |
|----------|------|
| **TCP** | 原始 TCP |
| **WebSocket** | `ws` |
| **gRPC** | GunService |
| **HTTPUpgrade** | HTTP/1.1 升级 |
| **XHTTP / SplitHTTP** | stream-one / stream-up / packet-up，HTTP/2 & HTTP/3 |

## 快速安装

**方式一：先安装，再手动修改配置文件（传统 XrayR 方式）：**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh)
```

安装完成后编辑 `/etc/levals-node/config.yml` 并重启服务：

```bash
lvnode config -e     # 或：nano /etc/levals-node/config.yml
lvnode restart
```

**方式二：命令行参数全自动对接：**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh) \
  --panel-url https://your-panel.com \
  --token YOUR_NODE_TOKEN \
  --node-id 1 \
  --license YOUR_LICENSE_KEY
```

*（对接 Xboard / V2Board 请追加：`--panel-kind xboard --node-type vless`）*

**方式三：使用环境变量：**

```bash
curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh | \
  PANEL_URL=https://your-panel.com TOKEN=YOUR_TOKEN NODE_ID=1 LEVALS_KEY=YOUR_LICENSE bash
```

## 配置文件

配置文件路径：`/etc/levals-node/config.yml`

### 配置字段

| 字段 | 必填 | 描述 |
|------|------|------|
| `server_type` | 否 | 面板类型：`levals`（默认）/ `xboard` / `v2board` |
| `api_host` | 是 | 面板地址 |
| `api_key` | 是 | 面板的节点通信 Token |
| `node_id` | 是 | 面板上的节点 ID |
| `node_type` | 仅 Xboard | 协议：`shadowsocks` / `vmess` / `trojan` / `vless` / `hysteria` / `tuic` / `anytls` / `mieru` |
| `levals_key` | 是 | 软件许可证密钥（与 `api_key` 不同） |

### 示例 — Levals 面板

```yaml
server_type: "levals"
api_host: "https://dash.levals.org"
api_key: "YOUR_NODE_TOKEN"
node_id: 1
levals_key: "YOUR_LICENSE_KEY"

core:
  engine: native
```

### 示例 — Xboard 面板

```yaml
server_type: "xboard"
api_host: "https://xboard.example.com"
api_key: "YOUR_NODE_TOKEN"
node_id: 1
node_type: "vless"
levals_key: "YOUR_LICENSE_KEY"

core:
  engine: native
```

### 示例 — V2Board 面板

```yaml
server_type: "v2board"
api_host: "https://v2board.example.com"
api_key: "YOUR_NODE_TOKEN"
node_id: 1
node_type: "trojan"
levals_key: "YOUR_LICENSE_KEY"

core:
  engine: native
```

## 管理工具 — `lvnode`

```
lvnode                              交互式管理菜单
lvnode list                         列出所有实例及状态
lvnode new <name> [k1=v1 ...]       创建新实例
lvnode remove <name> [name...]      删除实例
lvnode rename <old> <new>           重命名实例
lvnode start [name]                 启动实例
lvnode stop [name]                  停止实例
lvnode restart [name]               重启实例
lvnode enable [name]                设为开机自启
lvnode disable [name]               取消开机自启
lvnode log [name]                   实时合并日志
lvnode log [name] -n <N>            显示最后 N 行日志
lvnode config [name]                查看配置
lvnode config [name] -e             编辑配置
lvnode config [name] k1=v1 k2=v2    修改配置字段并自动重启
lvnode update [version]             安装或更新 levals-node
lvnode uninstall                    完全卸载
lvnode self-update                  更新 lvnode 脚本
lvnode version                      显示版本
```

## TLS 证书

| 方式 | 描述 |
|------|------|
| **HTTP-01** | 通过 Let's Encrypt 自动签发 — 无需配置（需开放 80 端口） |
| **DNS-01** | 支持 Cloudflare、DNSPod、Aliyun、Gcore — 在面板 UI 或配置文件中设置 |
| **REALITY** | 无需证书 — 零配置 TLS |
| **自定义** | 提供自己的证书/密钥路径 |

DNS-01 提供商变量：

| 提供商 | 变量 |
|--------|------|
| Cloudflare | `CF_DNS_API_TOKEN` |
| DNSPod | `DP_Id` + `DP_Key` |
| Aliyun | `Ali_Key` + `Ali_Secret` |
| Gcore | `GCORE_API_TOKEN` |

> **提示：** 推荐直接在面板 UI 中配置 DNS-01，最简单。

## 自定义 DNS（可选）

将 `dns.yml` 放在 `/etc/levals-node/` 目录下（与 `config.yml` 同级）：

```yaml
strategy: ipv4_first          # ipv4_first | ipv6_first | ipv4_only | ipv6_only
servers:
  - 1.1.1.1
  - 8.8.8.8:53
rules:
  - domains: [netflix.com, nflxvideo.net, "keyword:disney"]
    server: 1.0.0.1           # 将这些域名路由到指定 DNS
  - domain: pin.example.com
    ip: 203.0.113.9            # 将域名固定到静态 IP（类似 /etc/hosts）
  - domains: [ads.tracker.net, "keyword:doubleclick"]
    block: true                # 完全拦截解析
```

## 路由规则（可选）

将 `routes.yml` 放在 `/etc/levals-node/` 目录下：

```yaml
settings:
  block_quic: true             # 拦截 QUIC/HTTP3（UDP 443）— 强制 TCP
  block_bt: true               # 拦截 BitTorrent 流量
  block_private: true          # 拦截私有 IP 访问

block:
  - type: domain
    values:
      - ads.google.com
      - googleads.g.doubleclick.net
  - type: keyword
    values:
      - torrent
      - tracker
  - type: ip
    values: []
```

## 单服务器多面板

在配置中使用 `panels:` 替代单面板字段：

```yaml
panels:
  - api_host: "https://panel1.example.com"
    api_key: "TOKEN_PANEL_1"
    node_id: 1
  - api_host: "https://panel2.example.com"
    api_key: "TOKEN_PANEL_2"
    node_id: 2

levals_key: "YOUR_LICENSE_KEY"
core:
  engine: native
```

> **注意：** 请确保每个面板的节点使用不同的 `server_port`，以避免端口冲突。

## 支持面板

| 面板 | 兼容性 |
|------|--------|
| **Levals** | ✅ 完整支持 — 自动检测协议 |
| **Xboard** | ✅ 完整支持 — 需在配置中指定 `node_type` |
| **V2Board** | ✅ 完整支持 — 需在配置中指定 `node_type` |

## 系统要求

| 要求 | 最低配置 |
|------|----------|
| **操作系统** | Linux（Ubuntu 18.04+、Debian 10+、CentOS 7+、AlmaLinux、Rocky 等） |
| **架构** | x86_64 / aarch64（ARM64） |
| **内存** | ≥ 128 MB |
| **依赖** | 无 — 纯 Rust 静态二进制 |

## 许可证

**专有软件** — Copyright © 2026 Levals。保留所有权利。

需要有效的许可证密钥（`levals_key`）。请联系管理员获取授权。

---

# Tiếng Việt

## Tính năng

| Tính năng | Mô tả |
|-----------|-------|
| 🦀 Engine Rust thuần | Binary Rust gốc — không cần sing-box, xray hay bất kỳ core ngoài nào |
| 🖥️ Hỗ trợ Panel | Xboard / V2Board / Levals panel — tự nhận diện hoặc cấu hình tay |
| 🔄 Hot-Reload User | Thêm/xóa user tức thì, không cần khởi động lại dịch vụ |
| 📡 Multi-Panel | Chạy nhiều panel trên cùng một máy chủ |
| 🌐 WebSocket Sync | Kết nối WebSocket thời gian thực với panel để đồng bộ tức thì |
| 🔒 Auto TLS | Tự động cấp chứng chỉ qua Let's Encrypt (HTTP-01 / DNS-01) |
| ⚡ Giới hạn theo User | Giới hạn tốc độ, đếm lưu lượng, giới hạn IP online theo từng user |
| 🧭 DNS tùy chỉnh | Định tuyến DNS theo domain, ghim IP, chặn quảng cáo |
| 🛡️ Route & Rules | Chặn quảng cáo, tracker, BitTorrent, mạng nội bộ |
| 🔍 Sniffing lưu lượng | Tự nhận diện TLS SNI, HTTP Host, QUIC Initial SNI, BitTorrent DPI & giải Fake-IP |
| 🔧 Quản lý đa instance | Quản lý nhiều instance qua CLI `lvnode` |
| ♻️ Tự khởi động lại | Tự khởi động lại khi token hết hạn hoặc bị thu hồi |

## Giao thức hỗ trợ

| Giao thức | Mô tả |
|-----------|-------|
| **Trojan** | Proxy đường hầm TLS |
| **VLESS** | Xác thực UUID, REALITY (X25519 + X25519MLKEM768 hậu lượng tử), XTLS Vision |
| **VMess** | VMessAEAD (TCP + UDP) |
| **Shadowsocks** | AEAD + 2022-blake3, đa user EIH, TCP + UDP |
| **SOCKS5** | CONNECT + UDP ASSOCIATE |
| **HTTP** | HTTP CONNECT proxy |
| **NaiveProxy** | HTTP CONNECT qua TLS |
| **TUIC** | v5 trên QUIC |
| **Hysteria2** | QUIC + Salamander obfuscation |
| **AnyTLS** | v1/v2, TLS/REALITY/WS/HTTPUpgrade/XHTTP, dynamic padding, UDP-over-TCP |
| **Mieru** | v3, TCP/UDP, XChaCha20-Poly1305, Low-Entropy traffic pattern |

## Transport hỗ trợ

| Transport | Ghi chú |
|-----------|---------|
| **TCP** | TCP thô |
| **WebSocket** | `ws` |
| **gRPC** | GunService |
| **HTTPUpgrade** | HTTP/1.1 upgrade |
| **XHTTP / SplitHTTP** | stream-one / stream-up / packet-up, HTTP/2 & HTTP/3 |

## Cài đặt nhanh

**Cách 1 — Cài đặt trước, tự chỉnh file cấu hình (kiểu XrayR):**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh)
```

Sau khi cài xong, mở file `/etc/levals-node/config.yml` điền thông tin rồi khởi động:

```bash
lvnode config -e     # hoặc: nano /etc/levals-node/config.yml
lvnode restart
```

**Cách 2 — Tự động điền cấu hình trong một lệnh:**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh) \
  --panel-url https://your-panel.com \
  --token YOUR_NODE_TOKEN \
  --node-id 1 \
  --license YOUR_LICENSE_KEY
```

*(Nếu dùng Xboard / V2Board, thêm `--panel-kind xboard --node-type vless`)*

**Cách 3 — Dùng biến môi trường:**

```bash
curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh | \
  PANEL_URL=https://your-panel.com TOKEN=YOUR_TOKEN NODE_ID=1 LEVALS_KEY=YOUR_LICENSE bash
```

## Cấu hình

File cấu hình: `/etc/levals-node/config.yml`

### Các trường cấu hình

| Trường | Bắt buộc | Mô tả |
|--------|----------|-------|
| `server_type` | Không | Loại panel: `levals` (mặc định) / `xboard` / `v2board` |
| `api_host` | Có | Địa chỉ panel |
| `api_key` | Có | Token giao tiếp node từ panel |
| `node_id` | Có | ID node trên panel |
| `node_type` | Chỉ Xboard | Giao thức: `shadowsocks` / `vmess` / `trojan` / `vless` / `hysteria` / `tuic` / `anytls` / `mieru` |
| `levals_key` | Có | Giấy phép phần mềm (khác với `api_key`) |

### Ví dụ — Levals Panel

```yaml
server_type: "levals"
api_host: "https://dash.levals.org"
api_key: "YOUR_NODE_TOKEN"
node_id: 1
levals_key: "YOUR_LICENSE_KEY"

core:
  engine: native
```

### Ví dụ — Xboard Panel

```yaml
server_type: "xboard"
api_host: "https://xboard.example.com"
api_key: "YOUR_NODE_TOKEN"
node_id: 1
node_type: "vless"
levals_key: "YOUR_LICENSE_KEY"

core:
  engine: native
```

### Ví dụ — V2Board Panel

```yaml
server_type: "v2board"
api_host: "https://v2board.example.com"
api_key: "YOUR_NODE_TOKEN"
node_id: 1
node_type: "trojan"
levals_key: "YOUR_LICENSE_KEY"

core:
  engine: native
```

## Quản lý bằng CLI — `lvnode`

```
lvnode                              Menu quản lý tương tác
lvnode list                         Liệt kê instance & trạng thái
lvnode new <name> [k1=v1 ...]       Tạo instance mới
lvnode remove <name> [name...]      Xóa instance
lvnode rename <old> <new>           Đổi tên instance
lvnode start [name]                 Khởi động instance
lvnode stop [name]                  Dừng instance
lvnode restart [name]               Khởi động lại instance
lvnode enable [name]                Bật tự khởi động cùng hệ thống
lvnode disable [name]               Tắt tự khởi động
lvnode log [name]                   Xem log thời gian thực
lvnode log [name] -n <N>            Xem N dòng log cuối
lvnode config [name]                Xem cấu hình
lvnode config [name] -e             Sửa cấu hình bằng editor
lvnode config [name] k1=v1 k2=v2    Sửa trường cấu hình & tự khởi động lại
lvnode update [version]             Cài đặt hoặc cập nhật levals-node
lvnode uninstall                    Gỡ cài đặt hoàn toàn
lvnode self-update                  Cập nhật script lvnode
lvnode version                      Hiện phiên bản
```

## Chứng chỉ TLS

| Phương thức | Mô tả |
|-------------|-------|
| **HTTP-01** | Tự động qua Let's Encrypt — không cần cấu hình (cần mở port 80) |
| **DNS-01** | Cloudflare, DNSPod, Aliyun, Gcore — cấu hình trong panel UI hoặc file config |
| **REALITY** | Không cần chứng chỉ — TLS không cấu hình |
| **Tùy chỉnh** | Cung cấp đường dẫn cert/key của bạn |

Biến DNS-01 theo nhà cung cấp:

| Nhà cung cấp | Biến |
|---------------|------|
| Cloudflare | `CF_DNS_API_TOKEN` |
| DNSPod | `DP_Id` + `DP_Key` |
| Aliyun | `Ali_Key` + `Ali_Secret` |
| Gcore | `GCORE_API_TOKEN` |

> **Mẹo:** Nên cấu hình DNS-01 trực tiếp từ giao diện panel để đơn giản nhất.

## DNS tùy chỉnh (Tùy chọn)

Đặt file `dns.yml` cạnh `config.yml` trong `/etc/levals-node/`:

```yaml
strategy: ipv4_first          # ipv4_first | ipv6_first | ipv4_only | ipv6_only
servers:
  - 1.1.1.1
  - 8.8.8.8:53
rules:
  - domains: [netflix.com, nflxvideo.net, "keyword:disney"]
    server: 1.0.0.1           # Phân giải nhóm domain này qua DNS riêng
  - domain: pin.example.com
    ip: 203.0.113.9            # Ghim domain vào IP tĩnh (giống /etc/hosts)
  - domains: [ads.tracker.net, "keyword:doubleclick"]
    block: true                # Chặn hoàn toàn, không phân giải
```

## Route & Rules (Tùy chọn)

Đặt file `routes.yml` trong `/etc/levals-node/`:

```yaml
settings:
  block_quic: true             # Chặn QUIC/HTTP3 (UDP 443) — ép dùng TCP
  block_bt: true               # Chặn lưu lượng BitTorrent
  block_private: true          # Chặn truy cập dải IP nội bộ

block:
  - type: domain
    values:
      - ads.google.com
      - googleads.g.doubleclick.net
  - type: keyword
    values:
      - torrent
      - tracker
  - type: ip
    values: []
```

## Nhiều panel trên một máy chủ

Dùng `panels:` thay cho cấu hình panel đơn:

```yaml
panels:
  - api_host: "https://panel1.example.com"
    api_key: "TOKEN_PANEL_1"
    node_id: 1
  - api_host: "https://panel2.example.com"
    api_key: "TOKEN_PANEL_2"
    node_id: 2

levals_key: "YOUR_LICENSE_KEY"
core:
  engine: native
```

> **Lưu ý:** Đảm bảo mỗi panel dùng `server_port` khác nhau để tránh xung đột cổng.

## Panel hỗ trợ

| Panel | Tương thích |
|-------|-------------|
| **Levals** | ✅ Hỗ trợ đầy đủ — tự nhận diện giao thức từ panel |
| **Xboard** | ✅ Hỗ trợ đầy đủ — cần khai báo `node_type` trong config |
| **V2Board** | ✅ Hỗ trợ đầy đủ — cần khai báo `node_type` trong config |

## Yêu cầu hệ thống

| Yêu cầu | Tối thiểu |
|----------|-----------|
| **Hệ điều hành** | Linux (Ubuntu 18.04+, Debian 10+, CentOS 7+, AlmaLinux, Rocky, v.v.) |
| **Kiến trúc** | x86_64 / aarch64 (ARM64) |
| **RAM** | ≥ 128 MB |
| **Phụ thuộc** | Không có — binary Rust tĩnh thuần |

## Giấy phép

**Phần mềm độc quyền** — Copyright © 2026 Levals. Bảo lưu mọi quyền.

Cần giấy phép hợp lệ (`levals_key`) để sử dụng. Liên hệ quản trị viên để được cấp phép.
