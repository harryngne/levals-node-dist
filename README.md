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
| 🎮 UDP FullCone NAT | True RFC 3489 FullCone NAT across **all 13 protocols** (native UDP, XUDP, UoT v1/v2, QUIC datagrams) |
| ⚡ Fixed + Dynamic Speed | Per-user Mbps limit + sliding-window dynamic speed throttling (`traffic_mb` / `periodic_sec` → `limit_mbps`) |
| 🌐 Global Redis Limits | Local & cluster-wide **TCP connection limit**, **IP limit**, and **Device limit** powered by Redis |
| 🛡️ Audit & Whitelist | Local & remote block/audit rules (`domain`, `keyword`, `regexp:`, CIDR) + highest-priority **Whitelist** bypass |
| 🔍 Traffic Sniffing | TLS SNI, HTTP Host, QUIC Initial SNI, BitTorrent DPI & Fake-IP resolution |
| 🔒 Auto TLS Hot-Reload | Zero-downtime ACME HTTP-01 / DNS-01 apply & auto-renew across both TCP/TLS and QUIC listeners |
| 🧭 Anti-Leak DNS | Per-node isolated DNS router, remote DNS over outbound proxy, IP pinning & GeoDNS |
| ⚖️ Outbound Load Balancer | Remotely configurable `balancer` (`least-ping`, `round-robin`, `failover`, `random`, `ip-hash`) |
| 📡 Single-Process Multi-Node | Run multiple `nodes:` / `panels:` / `machine_id` inside **one single OS process** |
| 🔀 Multi-IP & PROXY Proto | `auto_out_ip` (`inbound_ip` → `outbound_ip`), `send_through`, and PROXY Protocol v1/v2 real client IP |
| 🛡️ AEAD `O(1)` & Tarpit | `O(1)` EIH/MRU multi-user lookup + anti-wrong-password tarpit & auto-ban for SS AEAD, SS2022 & VMess AEAD |

## Supported Protocols

| Protocol | Description |
|----------|-------------|
| **Trojan** | TLS / WS / gRPC / HTTPUpgrade / XHTTP + UDP FullCone NAT |
| **VLESS** | UUID auth, REALITY (X25519 + X25519MLKEM768 PQ), XTLS Vision, XUDP & UoT FullCone NAT |
| **VMess** | `O(1)` VMessAEAD + anti-probing tarpit + XUDP & UoT FullCone NAT |
| **Shadowsocks** | Classic AEAD + SIP022 2022-blake3 (`O(1)` EIH, AES-GCM & XChaCha20-Poly1305) + UDP & UoT FullCone NAT |
| **SOCKS5** | `CONNECT` + `UDP ASSOCIATE` + UoT FullCone NAT |
| **HTTP** | `HTTP CONNECT` + UoT FullCone NAT |
| **NaiveProxy** | HTTP/2 & HTTP/1.1 `CONNECT` over TLS with padding + UoT FullCone NAT |
| **TUIC** | v5 over QUIC (native datagrams + uni-stream + fragmentation FullCone NAT) |
| **Hysteria2** | QUIC + Salamander obfuscation + UDP fragmentation FullCone NAT |
| **AnyTLS** | v1/v2, TLS/REALITY/WS/HTTPUpgrade/XHTTP, dynamic padding, UoT v1/v2 FullCone NAT |
| **Mieru** | v3, TCP/UDP PacketUnderlay, XChaCha20-Poly1305, Low-Entropy traffic + FullCone NAT |

## Supported Transports

| Transport | Notes |
|-----------|-------|
| **TCP** | Raw TCP (+ optional PROXY Protocol v1/v2) |
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

**Option 2 — Zero-touch one-line install (CLI flags):**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh) \
  --server-type levals \
  --api-host https://your-panel.com \
  --api-key YOUR_API_KEY \
  --node-id 1 \
  --node-type vless \
  --levals-key YOUR_LICENSE_KEY
```

*(For Xboard / V2Board, set `--server-type xboard` or `--server-type v2board` and your protocol in `--node-type`)*

**Option 3 — Environment variables:**

```bash
curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh | \
  SERVER_TYPE=levals \
  API_HOST=https://your-panel.com \
  API_KEY=YOUR_API_KEY \
  NODE_ID=1 \
  NODE_TYPE=vless \
  LEVALS_KEY=YOUR_LICENSE_KEY bash
```

## Configuration

Config file: `/etc/levals-node/config.yml`

### Config Fields

| Field | Required | Description |
|-------|----------|-------------|
| `server_type` | No | Panel type: `levals` (default) / `xboard` / `v2board` |
| `api_host` | Yes | Panel URL |
| `api_key` | Yes | Node API communication key from panel |
| `node_id` | Yes | Node ID on panel (or use `machine_id` / `nodes:`) |
| `machine_id` | No | Machine ID on Levals panel (auto-runs all nodes assigned to this machine) |
| `node_type` | Xboard/V2Board | Protocol: `shadowsocks` / `vmess` / `trojan` / `vless` / `hysteria` / `tuic` / `anytls` / `mieru` / `naive` |
| `levals_key` | Yes | Software license key (different from `api_key`) |
| `nodes` | No | Run multiple nodes/panels concurrently inside one single OS process |
| `udp_fullcone` | No | Enable RFC 3489 UDP FullCone NAT across all protocols (default: `true`) |
| `auto_out_ip` | No | Multi-IP server: bind outbound IP to the inbound local IP the client connected to |
| `send_through` | No | Force a fixed outbound source IP address |
| `proxy_protocol` | No | Parse PROXY Protocol v1/v2 header on TCP listeners for real client IP |
| `limit` | No | Fixed + dynamic speed limits (`dynamic_speed`), per-user TCP, IP & device limits |
| `redis` | No | Global Redis sync (`enable`, `addr`, `username`, `password`, `db`, `tls`, `key_prefix`, `expiry_sec`) |
| `sniffing` | No | Traffic sniffing (`enabled`, `route_only`, `dest_override`, `domains_excluded`) — also toggleable on Web Panel |
| `core` | No | Native Rust engine (`engine: native`) |
| `config_dir` | No | State & certificate cache directory (default: `/etc/levals-node`) |
| `log` | No | Log `level` (`trace`\|`debug`\|`info`\|`warn`\|`error`) and optional `access` log path |
| `acme` | No | Optional local DNS-01 ACME credentials (`dns_provider`, `cf_token`) |

### Full `config.yml` Example — Levals Panel

```yaml
server_type: "levals"
api_host: "https://dash.levals.org"
api_key: "YOUR_API_KEY"
node_id: 1
# machine_id: 1
# node_type: "vless"
levals_key: "YOUR_LICENSE_KEY"

udp_fullcone: true
auto_out_ip: false
# send_through: "203.0.113.10"
proxy_protocol: false

limit:
  speed_limit: 0
  user_tcp_limit: 0
  user_ip_limit: 0
  user_device_limit: 0
  dynamic_speed:
    enable: false
    traffic_mb: 500
    periodic_sec: 60
    limit_mbps: 20
    expire_sec: 300

redis:
  enable: false
  addr: "127.0.0.1:6379"
  username: ""
  password: ""
  db: 0
  tls: false
  key_prefix: "lvnode"
  expiry_sec: 60

sniffing:
  enabled: true
  route_only: false
  dest_override: ["tls", "http", "quic", "fakedns"]
  domains_excluded:
    - "courier.push.apple.com"

core:
  engine: native

config_dir: "/etc/levals-node"

log:
  level: "info"
  # access: "/etc/levals-node/access.log"
```

### Example — Xboard / V2Board Panel

```yaml
server_type: "xboard"                       # or "v2board"
api_host: "https://xboard.example.com"
api_key: "YOUR_API_KEY"
node_id: 1
node_type: "vless"                          # shadowsocks|vmess|trojan|vless|hysteria|tuic|anytls|mieru|naive
levals_key: "YOUR_LICENSE_KEY"

udp_fullcone: true
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

## Routes, Whitelist & Audit Rules (Optional)

Place `routes.yml` next to `config.yml` in `/etc/levals-node/` (or configure remotely on the Levals Panel):

```yaml
settings:
  block_quic: true             # Block QUIC/HTTP3 (UDP 443) — force TCP
  block_bt: true               # Block BitTorrent traffic
  block_private: true          # Block access to private IP ranges
  sniffing: true               # Inspect TLS SNI / HTTP Host / QUIC SNI / BitTorrent DPI

whitelist:
  - type: domain
    values:
      - dl.google.com

block:
  - type: domain
    values:
      - ads.google.com
      - googleads.g.doubleclick.net
  - type: keyword
    values:
      - torrent
      - tracker
  - type: regex
    values:
      - '(^|\.)(xmrig|minexmr|nanopool)\.'
  - type: ip
    values: []
```

## Single-Process Multi-Node / Multi-Panel

Use `nodes:` (inherits top-level `server_type` / `api_host` / `api_key`, or overrides per entry) to run multiple nodes inside one single `levals-node` process:

```yaml
server_type: "levals"
api_host: "https://panel1.example.com"
api_key: "API_KEY_PANEL_1"
levals_key: "YOUR_LICENSE_KEY"

nodes:
  - node_id: 1
  - node_id: 2
    node_type: "trojan"
  - server_type: "xboard"
    api_host: "https://panel2.example.com"
    api_key: "API_KEY_PANEL_2"
    node_id: 5
    node_type: "vless"

core:
  engine: native
```

> **Note:** Ensure each node uses a different `server_port` to avoid port conflicts.

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
| 🎮 全协议 UDP FullCone | 支持 **全部 13 种协议** 的真 RFC 3489 FullCone NAT（原生 UDP、XUDP、UoT v1/v2、QUIC 数据报） |
| ⚡ 固定 + 动态限速 | 每用户固定 Mbps 限速 + 滑动窗口动态限速（超阈值自动降速，到期自动恢复） |
| 🌐 全局 Redis 限制 | 支持单机与跨节点 Redis 全局 **用户 TCP 连接数限制**、**在线 IP 限制** 与 **设备数限制** |
| 🛡️ 审计与白名单规则 | 本地与面板远程下发审计规则（域名、关键词、`regexp:` 正则、CIDR）+ 最高优先级 **白名单** 放行 |
| 🔍 流量嗅探 | TLS SNI、HTTP Host、QUIC Initial SNI、BitTorrent 深度识别与 Fake-IP 还原 |
| 🔒 自动 TLS 无感热重载 | Let's Encrypt HTTP-01 / DNS-01 自动申请与续期，TCP/TLS 与 QUIC 零中断热重载 |
| 🧭 防泄漏自定义 DNS | 节点级隔离 DNS 路由、远程通过出站代理解析、IP 固定与广告拦截 |
| ⚖️ 出站代理负载均衡 | 支持面板远程配置 `balancer`（`least-ping`、`round-robin`、`failover`、`random`、`ip-hash`） |
| 📡 单实例多节点集成 | 在 **单个进程** 内并发运行多个 `nodes:` / `panels:` / `machine_id` |
| 🔀 多 IP 自动选源与 PROXY | 支持多 IP 机器自动按入站 IP 选择出站 IP（`auto_out_ip`）及 PROXY Protocol v1/v2 真实源 IP 提取 |
| 🛡️ AEAD `O(1)` 与防探测 | 单端口多用户 SS AEAD / SS2022 / VMess AEAD `O(1)` 极速查找 + 错密探测自动封禁与随机延迟 Tarpit |

## 支持协议

| 协议 | 描述 |
|------|------|
| **Trojan** | TLS / WS / gRPC / HTTPUpgrade / XHTTP + UDP FullCone NAT |
| **VLESS** | UUID 认证，REALITY（X25519 + X25519MLKEM768 后量子加密），XTLS Vision，XUDP & UoT FullCone NAT |
| **VMess** | `O(1)` VMessAEAD + 防探测 Tarpit + XUDP & UoT FullCone NAT |
| **Shadowsocks** | 经典 AEAD + 2022-blake3（`O(1)` 多用户 EIH，AES-GCM & XChaCha20-Poly1305）+ UDP & UoT FullCone NAT |
| **SOCKS5** | `CONNECT` + `UDP ASSOCIATE` + UoT FullCone NAT |
| **HTTP** | `HTTP CONNECT` 代理 + UoT FullCone NAT |
| **NaiveProxy** | 基于 TLS 的 HTTP/2 & HTTP/1.1 `CONNECT`（填充混淆）+ UoT FullCone NAT |
| **TUIC** | v5 over QUIC（原生数据报 + 单向流 + 分片重组 FullCone NAT） |
| **Hysteria2** | QUIC + Salamander 混淆 + UDP 分片重组 FullCone NAT |
| **AnyTLS** | v1/v2，TLS/REALITY/WS/HTTPUpgrade/XHTTP，动态填充，UoT v1/v2 FullCone NAT |
| **Mieru** | v3，TCP/UDP PacketUnderlay，XChaCha20-Poly1305，低熵流量模式 + FullCone NAT |

## 支持传输方式

| 传输方式 | 说明 |
|----------|------|
| **TCP** | 原始 TCP（可选开启 PROXY Protocol v1/v2） |
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
  --server-type levals \
  --api-host https://your-panel.com \
  --api-key YOUR_API_KEY \
  --node-id 1 \
  --node-type vless \
  --levals-key YOUR_LICENSE_KEY
```

*（对接 Xboard / V2Board 请将 `--server-type` 设为 `xboard` 或 `v2board`，并在 `--node-type` 中指定协议）*

**方式三：使用环境变量：**

```bash
curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh | \
  SERVER_TYPE=levals \
  API_HOST=https://your-panel.com \
  API_KEY=YOUR_API_KEY \
  NODE_ID=1 \
  NODE_TYPE=vless \
  LEVALS_KEY=YOUR_LICENSE_KEY bash
```

## 配置文件

配置文件路径：`/etc/levals-node/config.yml`

### 配置字段

| 字段 | 必填 | 描述 |
|------|------|------|
| `server_type` | 否 | 面板类型：`levals`（默认）/ `xboard` / `v2board` |
| `api_host` | 是 | 面板地址 |
| `api_key` | 是 | 面板的节点 API 通信密钥 |
| `node_id` | 是 | 面板上的节点 ID（或使用 `machine_id` / `nodes:`） |
| `machine_id` | 否 | Levals 面板机器 ID（自动接管并运行绑定到该机器的所有节点） |
| `node_type` | Xboard/V2Board | 协议：`shadowsocks` / `vmess` / `trojan` / `vless` / `hysteria` / `tuic` / `anytls` / `mieru` / `naive` |
| `levals_key` | 是 | 软件许可证密钥（与 `api_key` 不同） |
| `nodes` | 否 | 单进程内并发集成运行多个节点或多个面板 |
| `udp_fullcone` | 否 | 开启全协议 RFC 3489 UDP FullCone NAT（默认 `true`） |
| `auto_out_ip` | 否 | 多 IP 服务器：自动按客户端入站本地 IP 绑定出站源 IP |
| `send_through` | 否 | 强制固定出站源 IP 地址 |
| `proxy_protocol` | 否 | 解析 TCP 监听器的 PROXY Protocol v1/v2 头以获取真实用户 IP |
| `limit` | 否 | 固定 + 动态限速（`dynamic_speed`）、每用户 TCP 连接限制、IP 限制与设备限制 |
| `redis` | 否 | 全局 Redis 集群同步（`enable`、`addr`、`username`、`password`、`db`、`tls`、`key_prefix`、`expiry_sec`） |
| `sniffing` | 否 | 流量嗅探配置（`enabled`、`route_only`、`dest_override`、`domains_excluded`，支持面板远程开关） |
| `core` | 否 | 纯 Rust 原生引擎（`engine: native`） |
| `config_dir` | 否 | 状态与证书缓存目录（默认 `/etc/levals-node`） |
| `log` | 否 | 日志级别 `level`（`trace`\|`debug`\|`info`\|`warn`\|`error`）与可选 `access` 访问日志路径 |
| `acme` | 否 | 本地 DNS-01 ACME 凭据（`dns_provider`、`cf_token`） |

### 完整 `config.yml` 示例 — Levals 面板

```yaml
server_type: "levals"
api_host: "https://dash.levals.org"
api_key: "YOUR_API_KEY"
node_id: 1
# machine_id: 1
# node_type: "vless"
levals_key: "YOUR_LICENSE_KEY"

udp_fullcone: true
auto_out_ip: false
# send_through: "203.0.113.10"
proxy_protocol: false

limit:
  speed_limit: 0
  user_tcp_limit: 0
  user_ip_limit: 0
  user_device_limit: 0
  dynamic_speed:
    enable: false
    traffic_mb: 500
    periodic_sec: 60
    limit_mbps: 20
    expire_sec: 300

redis:
  enable: false
  addr: "127.0.0.1:6379"
  username: ""
  password: ""
  db: 0
  tls: false
  key_prefix: "lvnode"
  expiry_sec: 60

sniffing:
  enabled: true
  route_only: false
  dest_override: ["tls", "http", "quic", "fakedns"]
  domains_excluded:
    - "courier.push.apple.com"

core:
  engine: native

config_dir: "/etc/levals-node"

log:
  level: "info"
  # access: "/etc/levals-node/access.log"
```

### 示例 — Xboard / V2Board 面板

```yaml
server_type: "xboard"                       # 或 "v2board"
api_host: "https://xboard.example.com"
api_key: "YOUR_API_KEY"
node_id: 1
node_type: "vless"                          # shadowsocks|vmess|trojan|vless|hysteria|tuic|anytls|mieru|naive
levals_key: "YOUR_LICENSE_KEY"

udp_fullcone: true
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

## 审计与白名单规则（可选）

将 `routes.yml` 放在 `/etc/levals-node/` 目录下（或直接在 Levals 面板远程配置）：

```yaml
settings:
  block_quic: true             # 拦截 QUIC/HTTP3（UDP 443）— 强制 TCP
  block_bt: true               # 拦截 BitTorrent 流量
  block_private: true          # 拦截私有 IP 访问
  sniffing: true               # 深度识别 TLS SNI / HTTP Host / QUIC SNI / BitTorrent

whitelist:
  - type: domain
    values:
      - dl.google.com

block:
  - type: domain
    values:
      - ads.google.com
      - googleads.g.doubleclick.net
  - type: keyword
    values:
      - torrent
      - tracker
  - type: regex
    values:
      - '(^|\.)(xmrig|minexmr|nanopool)\.'
  - type: ip
    values: []
```

## 单进程多节点 / 多面板集成

在配置中使用 `nodes:`（自动继承顶层 `server_type` / `api_host` / `api_key`，也可按节点单独覆盖），在单个进程内并发运行多个节点：

```yaml
server_type: "levals"
api_host: "https://panel1.example.com"
api_key: "API_KEY_PANEL_1"
levals_key: "YOUR_LICENSE_KEY"

nodes:
  - node_id: 1
  - node_id: 2
    node_type: "trojan"
  - server_type: "xboard"
    api_host: "https://panel2.example.com"
    api_key: "API_KEY_PANEL_2"
    node_id: 5
    node_type: "vless"

core:
  engine: native
```

> **注意：** 请确保每个节点使用不同的 `server_port`，以避免端口冲突。

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
| 🎮 UDP FullCone NAT | Chuẩn RFC 3489 FullCone NAT trên **tất cả 13 giao thức** (UDP gốc, XUDP, UoT v1/v2, QUIC datagram) |
| ⚡ Giới hạn tốc độ cố định + động | Giới hạn Mbps cố định + cửa sổ trượt giảm tốc động (`traffic_mb` / `periodic_sec` → `limit_mbps`) |
| 🌐 Giới hạn toàn cầu với Redis | Đồng bộ **giới hạn kết nối TCP**, **giới hạn IP** & **giới hạn thiết bị** xuyên cụm máy chủ qua Redis |
| 🛡️ Kiểm toán & Danh sách trắng | Quy tắc chặn/kiểm toán từ xa & cục bộ (`domain`, `keyword`, `regexp:`, CIDR) + **Whitelist** ưu tiên cao nhất |
| 🔍 Sniffing lưu lượng | Tự nhận diện TLS SNI, HTTP Host, QUIC Initial SNI, BitTorrent DPI & giải Fake-IP |
| 🔒 Auto TLS nạp nóng | Tự động cấp & gia hạn Let's Encrypt HTTP-01 / DNS-01, nạp nóng không rớt kết nối cho cả TCP/TLS & QUIC |
| 🧭 DNS chống rò rỉ | Router DNS cách ly từng nút, phân giải DNS qua outbound proxy từ xa, ghim IP & chặn quảng cáo |
| ⚖️ Cân bằng tải Outbound | Cấu hình từ xa `balancer` (`least-ping`, `round-robin`, `failover`, `random`, `ip-hash`) |
| 📡 Đa nút trên 1 tiến trình | Tích hợp chạy đồng thời nhiều `nodes:` / `panels:` / `machine_id` trong **một tiến trình duy nhất** |
| 🔀 Máy nhiều IP & PROXY Proto | Tự động chọn IP đầu ra theo IP đầu vào (`auto_out_ip`) và nhận diện IP thật qua PROXY Protocol v1/v2 |
| 🛡️ Tối ưu AEAD `O(1)` & Tarpit | Tra cứu `O(1)` EIH/MRU + tự động khóa & giam kết nối (tarpit) chống tấn công dò sai mật khẩu SS/SS2022/VMess |

## Giao thức hỗ trợ

| Giao thức | Mô tả |
|-----------|-------|
| **Trojan** | TLS / WS / gRPC / HTTPUpgrade / XHTTP + UDP FullCone NAT |
| **VLESS** | Xác thực UUID, REALITY (X25519 + X25519MLKEM768 hậu lượng tử), XTLS Vision, XUDP & UoT FullCone NAT |
| **VMess** | `O(1)` VMessAEAD + chống dò mật khẩu Tarpit + XUDP & UoT FullCone NAT |
| **Shadowsocks** | AEAD cổ điển + SIP022 2022-blake3 (`O(1)` đa user EIH, AES-GCM & XChaCha20-Poly1305) + UDP & UoT FullCone NAT |
| **SOCKS5** | `CONNECT` + `UDP ASSOCIATE` + UoT FullCone NAT |
| **HTTP** | `HTTP CONNECT` proxy + UoT FullCone NAT |
| **NaiveProxy** | HTTP/2 & HTTP/1.1 `CONNECT` qua TLS kèm padding chống DPI + UoT FullCone NAT |
| **TUIC** | v5 trên QUIC (datagram gốc + luồng đơn hướng + phân mảnh FullCone NAT) |
| **Hysteria2** | QUIC + Salamander obfuscation + phân mảnh UDP FullCone NAT |
| **AnyTLS** | v1/v2, TLS/REALITY/WS/HTTPUpgrade/XHTTP, dynamic padding, UoT v1/v2 FullCone NAT |
| **Mieru** | v3, TCP/UDP PacketUnderlay, XChaCha20-Poly1305, Low-Entropy traffic + FullCone NAT |

## Transport hỗ trợ

| Transport | Ghi chú |
|-----------|---------|
| **TCP** | TCP thô (tùy chọn bật PROXY Protocol v1/v2) |
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

**Cách 2 — Tự động điền cấu hình trong một lệnh (cờ dòng lệnh):**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh) \
  --server-type levals \
  --api-host https://your-panel.com \
  --api-key YOUR_API_KEY \
  --node-id 1 \
  --node-type vless \
  --levals-key YOUR_LICENSE_KEY
```

*(Nếu dùng Xboard / V2Board, đổi `--server-type xboard` hoặc `--server-type v2board` và chọn đúng giao thức ở `--node-type`)*

**Cách 3 — Dùng biến môi trường:**

```bash
curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh | \
  SERVER_TYPE=levals \
  API_HOST=https://your-panel.com \
  API_KEY=YOUR_API_KEY \
  NODE_ID=1 \
  NODE_TYPE=vless \
  LEVALS_KEY=YOUR_LICENSE_KEY bash
```

## Cấu hình

File cấu hình: `/etc/levals-node/config.yml`

### Các trường cấu hình

| Trường | Bắt buộc | Mô tả |
|--------|----------|-------|
| `server_type` | Không | Loại panel: `levals` (mặc định) / `xboard` / `v2board` |
| `api_host` | Có | Địa chỉ panel |
| `api_key` | Có | Khoá giao tiếp API node từ panel |
| `node_id` | Có | ID node trên panel (hoặc dùng `machine_id` / mảng `nodes:`) |
| `machine_id` | Không | ID máy chế độ Machine trên Levals panel (tự nhận và chạy mọi node gắn vào máy) |
| `node_type` | Xboard/V2Board | Giao thức: `shadowsocks` / `vmess` / `trojan` / `vless` / `hysteria` / `tuic` / `anytls` / `mieru` / `naive` |
| `levals_key` | Có | Giấy phép phần mềm (khác với `api_key`) |
| `nodes` | Không | Chạy tích hợp nhiều nút / nhiều panel đồng thời trong 1 tiến trình duy nhất |
| `udp_fullcone` | Không | Bật UDP FullCone NAT chuẩn RFC 3489 cho mọi giao thức (mặc định: `true`) |
| `auto_out_ip` | Không | Máy nhiều IP: tự động chọn IP đầu ra trùng với IP đầu vào mà khách kết nối tới |
| `send_through` | Không | Ép cố định địa chỉ IP nguồn đi ra Internet |
| `proxy_protocol` | Không | Giải mã PROXY Protocol v1/v2 trên cổng TCP để lấy IP thực của người dùng |
| `limit` | Không | Giới hạn tốc độ cố định + động (`dynamic_speed`), giới hạn kết nối TCP, IP & thiết bị mỗi user |
| `redis` | Không | Đồng bộ giới hạn IP, TCP & thiết bị toàn cầu qua Redis (`enable`, `addr`, `username`, `password`, `db`, `tls`, `key_prefix`, `expiry_sec`) |
| `sniffing` | Không | Nhận diện lưu lượng (`enabled`, `route_only`, `dest_override`, `domains_excluded`) — bật/tắt trực tiếp trên Web Panel |
| `core` | Không | Nhân mạng Rust thuần (`engine: native`) |
| `config_dir` | Không | Thư mục lưu đệm trạng thái & chứng chỉ (mặc định `/etc/levals-node`) |
| `log` | Không | Mức log `level` (`trace`\|`debug`\|`info`\|`warn`\|`error`) và đường dẫn `access` log tuỳ chọn |
| `acme` | Không | Thông tin xác thực ACME DNS-01 cục bộ (`dns_provider`, `cf_token`) |

### Ví dụ `config.yml` đầy đủ — Levals Panel

```yaml
server_type: "levals"
api_host: "https://dash.levals.org"
api_key: "YOUR_API_KEY"
node_id: 1
# machine_id: 1
# node_type: "vless"
levals_key: "YOUR_LICENSE_KEY"

udp_fullcone: true
auto_out_ip: false
# send_through: "203.0.113.10"
proxy_protocol: false

limit:
  speed_limit: 0
  user_tcp_limit: 0
  user_ip_limit: 0
  user_device_limit: 0
  dynamic_speed:
    enable: false
    traffic_mb: 500
    periodic_sec: 60
    limit_mbps: 20
    expire_sec: 300

redis:
  enable: false
  addr: "127.0.0.1:6379"
  username: ""
  password: ""
  db: 0
  tls: false
  key_prefix: "lvnode"
  expiry_sec: 60

sniffing:
  enabled: true
  route_only: false
  dest_override: ["tls", "http", "quic", "fakedns"]
  domains_excluded:
    - "courier.push.apple.com"

core:
  engine: native

config_dir: "/etc/levals-node"

log:
  level: "info"
  # access: "/etc/levals-node/access.log"
```

### Ví dụ — Xboard / V2Board Panel

```yaml
server_type: "xboard"                       # hoặc "v2board"
api_host: "https://xboard.example.com"
api_key: "YOUR_API_KEY"
node_id: 1
node_type: "vless"                          # shadowsocks|vmess|trojan|vless|hysteria|tuic|anytls|mieru|naive
levals_key: "YOUR_LICENSE_KEY"

udp_fullcone: true
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

## Quy tắc Kiểm toán & Danh sách trắng (Tùy chọn)

Đặt file `routes.yml` trong `/etc/levals-node/` (hoặc cấu hình trực tiếp từ xa trên Levals Panel):

```yaml
settings:
  block_quic: true             # Chặn QUIC/HTTP3 (UDP 443) — ép dùng TCP
  block_bt: true               # Chặn lưu lượng BitTorrent
  block_private: true          # Chặn truy cập dải IP nội bộ
  sniffing: true               # Nhận diện TLS SNI / HTTP Host / QUIC SNI / BitTorrent DPI

whitelist:
  - type: domain
    values:
      - dl.google.com

block:
  - type: domain
    values:
      - ads.google.com
      - googleads.g.doubleclick.net
  - type: keyword
    values:
      - torrent
      - tracker
  - type: regex
    values:
      - '(^|\.)(xmrig|minexmr|nanopool)\.'
  - type: ip
    values: []
```

## Đa nút / Nhiều panel trên 1 tiến trình duy nhất

Dùng `nodes:` (tự động kế thừa `server_type` / `api_host` / `api_key` cấp gốc, hoặc khai báo riêng từng mục) để chạy nhiều nút đồng thời trong cùng 1 tiến trình `levals-node`:

```yaml
server_type: "levals"
api_host: "https://panel1.example.com"
api_key: "API_KEY_PANEL_1"
levals_key: "YOUR_LICENSE_KEY"

nodes:
  - node_id: 1
  - node_id: 2
    node_type: "trojan"
  - server_type: "xboard"
    api_host: "https://panel2.example.com"
    api_key: "API_KEY_PANEL_2"
    node_id: 5
    node_type: "vless"

core:
  engine: native
```

> **Lưu ý:** Đảm bảo mỗi nút dùng `server_port` khác nhau để tránh xung đột cổng.

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
