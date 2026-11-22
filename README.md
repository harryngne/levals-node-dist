# levals-node (bản cài)

Trình cài **levals-node** — node agent cho panel levals. Repo này chỉ chứa trình cài
và binary dựng sẵn (ở **Releases**); **mã nguồn không công khai**.

## Cài
```bash
curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh | \
  PANEL_URL=https://dash.levals.org TOKEN=<token-giấy-phép> NODE_ID=1 bash
```
- `TOKEN`: token giấy phép do quản trị levals cấp (có thời hạn). Hết hạn → node tự dừng.
- Script tự tải xray-core gốc + geodata, cài levals-node, tạo `/etc/levals-node/config.yml`,
  dựng dịch vụ systemd. Hỗ trợ `x86_64` và `aarch64`.
- Xem log: `journalctl -u levals-node -f`
- Cập nhật: `lvnode update`

## Chứng chỉ TLS (DNS-01) — đặt ngay trong panel
Trong panel, mở node → **Cách lấy chứng chỉ: Tự xin (ACME DNS-01)** → chọn nhà cung cấp
và dán khoá API, rồi **Lưu**. Node tự lấy chứng chỉ Let's Encrypt, không cần SSH. Hỗ trợ:
- **Cloudflare**: `CF_DNS_API_TOKEN`
- **DNSPod**: `DP_Id` + `DP_Key`
- **Aliyun (AliDNS)**: `Ali_Key` + `Ali_Secret`
- **Gcore**: `GCORE_API_TOKEN`

## Engine thuần Rust (tùy chọn, không cần lvcore)
Đặt `ENGINE=native` để node tự phục vụ bằng Rust, tự chọn theo giao thức node:
**trojan** (TCP-TLS + WebSocket), **shadowsocks** (AEAD + 2022-blake3),
**socks5** (+UDP), **http** — relay TCP/UDP, đếm lưu lượng + IP online như thường.
```bash
curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh | \
  PANEL_URL=https://dash.levals.org TOKEN=<token> NODE_ID=1 ENGINE=native bash
```
Hoặc sửa `core.engine: native` trong `/etc/levals-node/config.yml` (`lvnode config`).
Giao thức khác (vmess/vless/hysteria2/tuic…) hiện vẫn dùng `xray` (mặc định).

## Nhiều panel trên một máy (nâng cao)
Khai báo `panels:` thay cho `panel:` trong `/etc/levals-node/config.yml` (`lvnode config`),
mỗi panel chạy độc lập — nhớ đặt cổng node khác nhau. Xem `config.example.yml`.

Gia hạn / hỗ trợ: liên hệ quản trị levals.
