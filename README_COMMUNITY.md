# 🚀 Antigravity Agent Studio Monitor (macOS & Web/Mobile)

> **Pixel-Art Game Dev Studio Visualizer & Real-time Mission Control** cho các Autonomous Coding Agents của Google DeepMind Antigravity.

---

## 🌟 Tính Năng Nổi Bật

1. **🏡 Game Dev Story Studio Map (Isometric & 2D)**:
   - 4 không gian làm việc sống động: **💻 Dev Lab (Phòng lập trình)**, **🍳 Kitchen (Bếp ăn & Cafe)**, **🛋️ Lounge (Phòng giải trí)**, **🛏️ Bedroom (Phòng nghỉ ngơi)**.
   - Tối ưu màn hình: Có thể zoom toàn màn hình từng phòng hoặc thu nhỏ về tổng quan 4 phòng.
   - Hỗ trợ chế độ **Fever Mode (Phím F)** khi các bot đồng loạt code với tốc độ cao.

2. **⚡ 100% Live Data & Zero-Flickering**:
   - Tự động theo dõi các file log tại `~/.gemini/antigravity/brain/` trong thời gian thực.
   - **DOM Reconciliation chống chớp màn hình**: Các thẻ agent được cập nhật tại chỗ (in-place diffing) mượt mà không bị reload trắng trang.
   - Bộ đếm tab động chuẩn xác 100%: **Tất cả (n)**, **⚡ Đang chạy (n)**, **☕ Giải lao (n)**.
   - Cơ chế Watchdog tự động giải phóng các tác vụ chạy lâu hoặc bị treo để đưa agent về trạng thái giải lao/nghỉ ngơi.

3. **📻 Web Audio Jukebox & Hiệu Ứng Âm Thanh Sống Động**:
   - 5 bản nhạc nền tổng hợp bằng Web Audio API (100% Offline, không phụ thuộc mạng):
     - ☕ **Lo-fi Study Cafe**
     - 🕹️ **8-Bit Chiptune Arcade** (Phong cách Game Dev Story cổ điển)
     - 🌆 **Cyberpunk Synthwave**
     - 🌧️ **Coffee & Gentle Rain**
     - 🔔 **Zen Focus & Tibetan Bowls**
   - Bộ điều chỉnh âm lượng & visualizer equalizer nhảy theo nhịp nhạc.
   - Hiệu ứng pháo hoa tia sáng (Confetti & Sparkles) và âm thanh cơ học typewriter khi tương tác.

4. **🩺 Bác Sĩ Cấu Hình (Antigravity Diagnostics)**:
   - Tự động kiểm tra môi trường máy tính người dùng:
     - Kiểm tra thư mục `~/.gemini/antigravity/brain`
     - Kiểm tra Antigravity IDE `~/.gemini/antigravity-ide/brain`
     - Báo lỗi rõ ràng nếu thiếu cấu hình hoặc quyền truy cập.
   - **1-Click Tự Động Khởi Tạo Thư Mục Mẫu**: Người mới chưa có Antigravity vẫn có thể bấm nút khởi tạo để trải nghiệm app ngay lập tức!
   - Nút mở nhanh thư mục trong macOS Finder hoặc copy lệnh terminal `mkdir -p ~/.gemini/antigravity/brain`.

5. **🧠 Quota & Token Meter**:
   - Hiển thị trực tiếp **% Quota Còn Lại** trên thanh Header kèm thanh tiến trình mini.
   - Modal chi tiết (Phím `U`): Bảng thống kê hạn mức của từng model (Gemini 3.8 Flash, Claude Sonnet 4.6, Claude Opus 4.6, GPT-OSS 120B).

6. **📱 Bản Web & Mobile Responsive**:
   - Đã deploy sẵn tại: **[https://antigravity-monitor.surge.sh](https://antigravity-monitor.surge.sh)**
   - Thanh Quick Room Switcher trên mobile giúp bấm chuyển nhanh giữa 4 phòng bằng 1 ngón tay.
   - Tooltip thông minh tự căn chỉnh vị trí trên màn hình nhỏ, không bao giờ bị tràn hoặc che khuất.

---

## 💾 Hướng Dẫn Cài Đặt (macOS)

### Cách 1: Cài đặt từ file `.dmg` (Khuyên dùng)
1. Tải file **`AntigravityMonitor-macOS-Universal.dmg`**.
2. Nhấp đúp vào file `.dmg` và kéo biểu tượng **AntigravityMonitor** vào thư mục **Applications**.
3. **Mở App lần đầu (Bypass macOS Gatekeeper)**:
   - Do app được build trực tiếp từ mã nguồn mã nguồn mở, macOS sẽ hỏi xác nhận quyền chạy.
   - Mở Terminal và dán lệnh sau để cấp quyền:
     ```bash
     xattr -cr /Applications/AntigravityMonitor.app
     ```
   - Hoặc nhấp chuột phải (Right-click) vào app trong Finder > chọn **Open** > bấm **Open** xác nhận.

### Cách 2: Cài đặt từ file `.zip`
1. Tải và giải nén **`AntigravityMonitor-macOS-Universal.zip`**.
2. Di chuyển `AntigravityMonitor.app` vào `/Applications/`.
3. Chạy lệnh:
   ```bash
   xattr -cr /Applications/AntigravityMonitor.app
   ```

---

## 🌐 Truy Cập Trực Tiếp Từ Điện Thoại (Web / Mobile)

Không cần cài app, bạn có thể mở Safari hoặc Chrome trên iPhone / Android:
👉 **[https://antigravity-monitor.surge.sh](https://antigravity-monitor.surge.sh)**

*Mẹo: Chọn "Add to Home Screen" trên Safari để lưu app ra màn hình chính điện thoại như một Native App.*

---

## ⌨️ Bảng Phím Tắt Tiện Ích

| Phím | Chức năng |
| :---: | :--- |
| **`H`** | Chuyển đổi giữa chế độ **Bản Đồ Nhà Studio 2D** và **Dashboard Thẻ** |
| **`J`** | Mở bảng điều khiển âm nhạc **Jukebox & Soundtracks** |
| **`D`** | Mở bảng kiểm tra cấu hình **Antigravity Diagnostics** |
| **`U`** | Xem thống kê **Quota Còn Lại & Chi Tiết Các Model** |
| **`S`** | Xem chi tiết từng step thực thi của Agent đang chọn |
| **`R`** | Ép đồng bộ và làm mới Live Data ngay lập tức |
| **`T`** | Đổi chủ đề màu (Cozy Day, Pastel Dream, Nordic Clean, Retro Cafe, Cyber Dark) |
| **`F`** | Bật/tắt chế độ **Fever Mode** (Tất cả bot tăng tốc làm việc) |
| **`M`** | Bật/tắt âm thanh hiệu ứng (SFX) |
| **`Esc`** | Đóng popup / Thoát chế độ zoom phòng về tổng quan |

---

## 🛠️ Dành Cho Developer Muốn Tự Build

Ứng dụng được viết bằng **SwiftUI / AppKit** kết hợp **WebKit** nhúng giao diện HTML5/TailwindCSS cực nhẹ:

```bash
# Clone hoặc vào thư mục dự án
cd antigravity-menubar

# Compile Universal Binary (hỗ trợ cả Apple Silicon M1/M2/M3/M4 và Intel Mac)
swiftc -parse-as-library -target arm64-apple-macos12.0 -O -o build/AntigravityMonitor_arm64 AntigravityMonitor.swift
swiftc -parse-as-library -target x86_64-apple-macos12.0 -O -o build/AntigravityMonitor_x86_64 AntigravityMonitor.swift
lipo -create -output dist/AntigravityMonitor.app/Contents/MacOS/AntigravityMonitor build/AntigravityMonitor_arm64 build/AntigravityMonitor_x86_64

# Deploy web lên surge
surge /tmp/antigravity_web_deploy --domain antigravity-monitor.surge.sh
```

---
*Phát triển với ❤️ dành cho cộng đồng AI Developer & Antigravity Users.*
