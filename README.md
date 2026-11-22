# levals-node (bản cài)

Trình cài **levals-node** — node agent cho panel levals. Repo này chỉ chứa trình cài
và binary dựng sẵn (ở **Releases**); **mã nguồn không công khai**.

## Cài
```bash
curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh | \
  PANEL_URL=https://dash.levals.org TOKEN=<token-giấy-phép> NODE_ID=1 bash
```
- `TOKEN`: token giấy phép do quản trị levals cấp (có thời hạn). Hết hạn → node tự dừng.
- Script tải binary levals-node (engine thuần Rust, **không cần lõi ngoài**), tạo
  `/etc/levals-node/config.yml`, dựng dịch vụ systemd. Hỗ trợ `x86_64` và `aarch64`.
- Xem log: `journalctl -u levals-node -f`
- Cập nhật: `lvnode update`

## Giao thức & transport
Engine native thuần Rust phục vụ trực tiếp, tự chọn theo giao thức node:
**trojan**, **vless** (REALITY + X25519MLKEM768, XTLS Vision, hoặc TLS thường),
**vmess**, **shadowsocks** (AEAD + 2022-blake3, cả UDP), **socks5** (+UDP),
**http**, **tuic**, **hysteria2** (+obfs Salamander).
Transport: `tcp`, `ws`, `grpc`, `httpupgrade`, `xhttp` (stream-one/stream-up/packet-up,
trên HTTP/2 và HTTP/3). *(anytls/naive chưa hỗ trợ.)*

## Chứng chỉ TLS (DNS-01) — đặt ngay trong panel
Trong panel, mở node → **Cách lấy chứng chỉ: Tự xin (ACME DNS-01)** → chọn nhà cung cấp
và dán khoá API, rồi **Lưu**. Node tự lấy chứng chỉ Let's Encrypt, không cần SSH. Hỗ trợ:
- **Cloudflare**: `CF_DNS_API_TOKEN`
- **DNSPod**: `DP_Id` + `DP_Key`
- **Aliyun (AliDNS)**: `Ali_Key` + `Ali_Secret`
- **Gcore**: `GCORE_API_TOKEN`

REALITY không cần chứng chỉ (nguỵ trang theo site đích).

## Nhiều panel trên một máy (nâng cao)
Khai báo `panels:` thay cho `panel:` trong `/etc/levals-node/config.yml` (`lvnode config`),
mỗi panel chạy độc lập — nhớ đặt cổng node khác nhau. Xem `config.example.yml`.

Gia hạn / hỗ trợ: liên hệ quản trị levals.
