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

Gia hạn / hỗ trợ: liên hệ quản trị levals.
