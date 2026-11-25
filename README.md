# levals-node (bản cài)

Trình cài **levals-node** — node agent cho panel levals. Repo này chỉ chứa trình cài
và binary dựng sẵn (ở **Releases**); **mã nguồn không công khai**.

## Cài
```bash
curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh | \
  PANEL_URL=https://dash.levals.org TOKEN=<token-giấy-phép> NODE_ID=1 bash
```
- `TOKEN`: token giấy phép do quản trị levals cấp (có thời hạn). Hết hạn → node tự dừng.
- Giấy phép **gắn với URL panel** (`PANEL_URL`): quản trị gán sẵn URL, hoặc giấy phép tự
  gắn vào URL panel ở lần chạy đầu tiên. Dùng giấy phép với panel khác → node tự dừng.
- Script tải binary levals-node (engine thuần Rust, **không cần lõi ngoài**), tạo
  `/etc/levals-node/config.yml`, dựng dịch vụ systemd. Hỗ trợ `x86_64` và `aarch64`.
- Quản lý đa instance & xem log realtime hợp nhất (agent + client):
```
lvnode                              - Hiển thị menu quản lý tương tác
lvnode list                         - Liệt kê các instance & trạng thái
lvnode new <name> [k1=v1 ...]       - Tạo instance mới
lvnode remove <name> [name...]      - Xoá instance
lvnode rename <old_name> <new_name> - Đổi tên instance
lvnode start [name]                 - Khởi động instance
lvnode stop [name]                  - Dừng instance
lvnode restart [name]               - Khởi động lại instance
lvnode enable [name]                - Bật tự chạy khi khởi động máy
lvnode disable [name]               - Tắt tự chạy khi khởi động máy
lvnode log [name]                   - Xem log realtime hợp nhất (agent + client)
lvnode log [name] -n <số_dòng>      - Xem N dòng log gần nhất
lvnode config [name]                - Xem file cấu hình
lvnode config [name] -e             - Sửa file cấu hình bằng nano/vi
lvnode config [name] k1=v1 k2=v2    - Sửa hoặc thêm cấu hình & tự restart
lvnode update [version]             - Cài đặt / cập nhật levals-node
lvnode uninstall                    - Gỡ cài đặt hoàn toàn levals-node
lvnode self-update                  - Cập nhật script quản lý lvnode
lvnode version                      - Xem phiên bản
```

### Panel khác levals (xboard / v2board)
Mặc định nhận panel **levals**. Dùng panel khác thì khai báo loại + node_type:
```bash
curl -fsSL https://raw.githubusercontent.com/harryngne/levals-node-dist/main/install.sh | \
  PANEL_URL=https://your-panel TOKEN=<token> NODE_ID=1 \
  PANEL_KIND=xboard NODE_TYPE=vless bash
```
- `PANEL_KIND`: `levals` (mặc định) | `xboard` | `v2board`.
- `NODE_TYPE`: bắt buộc cho xboard/v2board — `shadowsocks|vmess|trojan|vless|hysteria|tuic|anytls|mieru`.

## Giao thức & transport
Engine native thuần Rust phục vụ trực tiếp, tự chọn theo giao thức node:
**trojan**, **vless** (REALITY + X25519MLKEM768, XTLS Vision, hoặc TLS thường),
**vmess**, **shadowsocks** (AEAD + 2022-blake3, cả UDP), **socks5** (+UDP),
**http**, **tuic**, **hysteria2** (+obfs Salamander), **anytls** (v1/v2, `padding_scheme` động, UDP-over-TCP v1/v2), **mieru** (v3 TCP/UDP, XChaCha20-Poly1305, Low-Entropy).
Transport: `tcp`, `ws`, `grpc`, `httpupgrade`, `xhttp` (stream-one/stream-up/packet-up,
trên HTTP/2 và HTTP/3). *(naive chưa hỗ trợ.)*

## DNS kiểu soga (tuỳ chọn)
Đặt `dns.yml` cạnh `config.yml` (mẫu: `dns.example.yml`) để phân giải domain qua
**DNS riêng** theo nhóm domain, **ghim IP tĩnh** (như hosts), hoặc **chặn**; có
`strategy` ipv4/ipv6. Không có file = dùng DNS hệ thống như bình thường.

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
