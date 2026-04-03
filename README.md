# 🛡️ Sentinel Browser

> **Privacy-First Brave Fork with TOR Integration, DNS Privacy & OPSEC Routing**

[![License: MPL 2.0](https://img.shields.io/badge/License-MPL%202.0-brightgreen.svg)](LICENSE)
[![Arch Linux](https://img.shields.io/badge/Platform-Arch%20Linux-1793d1.svg)](https://archlinux.org)
[![GitHub](https://img.shields.io/badge/GitHub-Felly--linux-181717.svg)](https://github.com/Felly-linux/Fellcrack-browser)
![Version](https://img.shields.io/badge/Version-1.0.0--alpha-blueviolet)
![Status](https://img.shields.io/badge/Status-Active-green)

---

## 🎯 What is Sentinel Browser?

**Sentinel Browser** is an ultra-hardened, privacy-focused fork of Brave Browser optimized for **OPSEC** on Arch Linux. It combines cutting-edge privacy technologies with advanced routing capabilities to give you complete control over your network traffic.

Whether you need **anonymous browsing via TOR**, **corporate privacy with DNS-HTTPS/TLS**, or **direct access** for performance, Sentinel Browser lets you choose—**per-site, in real-time**.

### 🔐 Privacy by Design

Unlike standard browsers where privacy is reactive, Sentinel Browser is built from the ground up with:
- **Zero telemetry** (no crash reports, no "anonymous" tracking)
- **Hardened Chromium** (no NaCl, plugins, or DRM)
- **TOR integration** with dynamic circuit switching
- **DNS privacy** (DoH/DoT with custom providers)
- **Anti-fingerprinting** (canvas, WebGL, fonts, timezones)
- **Flexible routing** (direct/proxy/tor per-domain rules)

---

## ✨ Key Features

### 🧅 TOR Integration
```bash
./scripts/sentinel --tor                      # Force all traffic via TOR
./scripts/sentinel --mode opsec              # OPSEC mode (everything to TOR)
python3 tools/tor-circuit-switcher.py        # Get new exit IP
```
- Automatic SOCKS5 proxy detection
- Per-circuit isolation
- .onion site support
- Dynamic exit IP rotation

### 🔒 DNS Privacy
- **DNS over HTTPS** (Cloudflare, Quad9, NextDNS)
- **DNS over TLS** (securely encrypted DNS queries)
- **No DNS leaks** (WebRTC blocking included)
- Custom provider support

### 🎭 Anti-Fingerprinting
- Canvas fingerprint protection
- WebGL protection
- Font enumeration blocking
- Hardware acceleration disabled
- Timezone & locale masking
- Motion sensor blocking

### 🔀 Dynamic Routing Engine
Define per-domain routing rules in `config/routing-rules.yaml`:

```yaml
routes:
  direct:     [github.com, stackoverflow.com]      # Fast, no privacy
  proxy:      [google.com, facebook.com]           # Moderate privacy
  tor:        ["*.onion", protonmail.com]          # Maximum privacy
```

Switch modes without restarting:
```bash
./scripts/sentinel --mode privacy                   # DNS-HTTPS + anti-fingerprint
./scripts/sentinel --mode opsec                     # TOR + everything
./scripts/sentinel --profile banking                # Isolated profile
```

### 📡 VPN Integration
- Auto-detects OpenVPN (TUN0) and WireGuard (WG0)
- System VPN transparent integration
- Network isolation

### 🏗️ Arch Linux Integration
One-command installation:
```bash
cd arch && makepkg -si
```
Creates:
- `/usr/bin/sentinel-browser` (executable)
- `/usr/share/applications/sentinel-browser.desktop` (launcher)
- `man sentinel-browser` (documentation)

---

## 🚀 Quick Start

### 30-Second Setup

```bash
git clone https://github.com/Felly-linux/Fellcrack-browser.git
cd Fellcrack-browser

# Automated setup (3-5 hours first run)
bash quickstart.sh
```

Or **step-by-step**:
```bash
./scripts/bootstrap.sh      # Phase 1: Download Brave (~2h)
./scripts/build.sh --release # Phase 2: Compile (~1-3h)
./scripts/opsec-config.sh   # Phase 3: Configure OPSEC
./scripts/sentinel --mode opsec  # Phase 4: Launch
```

### System Requirements

```
OS:       Linux (Arch recommended)
RAM:      8GB minimum (16GB recommended)
Disk:     100GB for build (80GB source + 20GB compilation)
Time:     3-5 hours first run
Tools:    git, gcc, ninja, python3, gn
```

**Arch Linux only?**
```bash
sudo pacman -S base-devel git ninja python gn
```

**Ubuntu/Debian?**
```bash
sudo apt-get install build-essential git ninja-build python3 gn
```

---

## 📖 Usage Examples

### 1. Normal Mode (Standard Brave)
```bash
./scripts/sentinel
./scripts/sentinel https://github.com
```

### 2. Privacy Mode (DNS-HTTPS + Anti-fingerprint)
```bash
./scripts/sentinel --mode privacy
./scripts/sentinel --mode privacy https://duckduckgo.com
```

### 3. OPSEC Mode (Maximum Privacy)
```bash
./scripts/sentinel --mode opsec
# Forces: TOR + DNS-HTTPS/TLS + anti-fingerprinting + no extensions
```

### 4. Force TOR
```bash
./scripts/sentinel --tor
./scripts/sentinel --tor https://example.onion
```

### 5. Isolated Profiles
```bash
./scripts/sentinel --profile banking https://mybank.com
./scripts/sentinel --profile work https://github.com
./scripts/sentinel --profile personal
# Each profile has isolated cookies, cache, extensions
```

### 6. Offline Mode
```bash
./scripts/sentinel --offline
# Cached content only, no network requests
```

### 7. TOR Circuit Switching
```bash
# Change exit IP immediately
python3 tools/tor-circuit-switcher.py --switch

# Change every 5 minutes
python3 tools/tor-circuit-switcher.py --interval 300

# Real-time monitoring
python3 tools/tor-circuit-switcher.py --monitor
```

### 8. IP/Geo Verification
```bash
bash tools/check-ip.sh
# Tests: HTTP IP, DNS IP, TOR IP, WebRTC leaks
```

---

## 🏗️ Architecture

```
Sentinel Browser
├── Core: Chromium + Brave
├── Privacy Layer
│   ├── TOR (SOCKS5 proxy)
│   ├── DNS over HTTPS/TLS
│   ├── Anti-fingerprinting
│   └── WebRTC blocking
├── Routing Engine
│   ├── Dynamic per-domain rules
│   ├── Direct/Proxy/TOR selection
│   └── Runtime switching
└── CLI + Tools
    ├── Circuit switcher
    ├── IP checker
    └── Profile manager
```

### Build Configuration (GN Args)

```gn
is_official_build = true          # Official build
is_debug = false                  # Release mode
enable_widevine = false           # No DRM
enable_nacl = false               # No deprecated tech
enable_plugins = false            # No Flash/plugins
enable_socks5 = true              # TOR support
use_custom_libcxx = true          # LLVM libc++
```

---

## 📁 Project Structure

```
Fellcrack-browser/
├── scripts/                       # Build automation
│   ├── bootstrap.sh              # Phase 1: Env prep
│   ├── build-impl.sh             # Phase 2: Compilation
│   ├── opsec-config.sh           # Phase 3: Configuration
│   ├── install-tor-tools.sh      # Phase 4: TOR tools
│   └── sentinel                  # Phase 5: Launcher
├── config/                        # Configuration files
│   ├── sentinel-opsec.conf       # Main OPSEC config
│   └── routing-rules.yaml        # Routing rules
├── tools/                         # Utilities
│   ├── tor-circuit-switcher.py   # Circuit switcher
│   ├── check-ip.sh               # IP/Geo checker
│   └── install-extensions.sh     # Extension installer
├── patches/                       # Custom Brave patches
├── arch/                          # Arch Linux integration
│   └── PKGBUILD                  # Package definition
└── [Documentation]
    ├── PROJECT.md                # Project overview
    ├── QUICKSTART.md             # Quick start guide
    ├── TECHNICAL.md              # Technical docs
    └── README.md                 # This file
```

---

## 🔧 Configuration

### Main Config: `config/sentinel-opsec.conf`

```ini
[privacy]
dns_over_https = true
dns_over_tls = true
dns_providers = ["1.1.1.2", "1.0.0.2"]
disable_telemetry = true
disable_plugins = true

[proxy]
tor_enabled = true
tor_host = 127.0.0.1
tor_port = 9050

[security]
disable_webrtc_leak = true
block_mixed_content = true
```

### Routing Rules: `config/routing-rules.yaml`

```yaml
routes:
  direct:
    - github.com
    - stackoverflow.com
  proxy:
    - google.com
    - facebook.com
  tor:
    - "*.onion"
    - protonmail.com
```

---

## 🐛 Troubleshooting

### TOR Not Available
```bash
sudo systemctl start tor
sudo systemctl enable tor
# Verify:
nc -zv 127.0.0.1 9050
```

### Build Failed
```bash
# Check logs
tail -f build/logs/build.log

# Clean and retry
./scripts/build.sh --clean --release

# One job at a time (safer)
./scripts/build.sh --jobs 1
```

### Missing Dependencies
```bash
# Arch Linux
sudo pacman -S --needed base-devel git ninja python gn

# Ubuntu/Debian
sudo apt-get install build-essential git ninja-build python3 gn
```

### WebRTC Leak Detection
```bash
bash tools/check-ip.sh
# Or online: https://browserleaks.com/webrtc
```

---

## 🔐 Security Notes

⚠️ **Privacy ≠ Anonymity**
- Sentinel Browser provides privacy (encrypted, no tracking)
- For true anonymity, use TOR mode (`--mode opsec`)
- Avoid mixing VPN + TOR (can leak your real IP)

⚠️ **TOR Circuit Rules**
- Changing circuits every 5 minutes reduces anonymity
- Recommended: daily or less frequent rotation

⚠️ **Profile Isolation**
- Each profile has separate cookies/cache/extensions
- Use for compartmentalized browsing

---

## 📦 Installation Methods

### Method 1: Arch Linux (Native Package)
```bash
cd arch
makepkg -si
# Then: sentinel-browser --mode opsec
```

### Method 2: Manual Build
```bash
bash quickstart.sh
# Or step-by-step: see Quick Start above
```

### Method 3: Docker (Future)
```bash
docker run -it felly-linux/sentinel-browser --mode opsec
# Coming soon
```

---

## 🤝 Contributing

Contributions welcome! Areas:

- 🐛 **Bug fixes** - Reports/PRs
- 📚 **Documentation** - Guides, translations
- 🔧 **Features** - I2P, obfuscation, new routing modes
- 🎨 **UI/UX** - Icon, branding
- ✅ **Testing** - Cross-distro compatibility

**Workflow:**
```bash
git checkout -b feature/amazing-feature
git commit -am "Add amazing feature"
git push origin feature/amazing-feature
# Open PR on GitHub
```

---

## 📄 License

Sentinel Browser is dual-licensed:

- **Brave Browser**: [MPL 2.0](https://mozilla.org/MPL/2.0/) + Apache 2.0
- **Sentinel Patches**: [MIT License](LICENSE)

You're free to use, modify, and distribute under these terms.

---

## 🔗 Resources

- **Brave Browser**: https://github.com/brave/brave-browser
- **TOR Project**: https://www.torproject.org/
- **DNS Privacy**: https://www.eff.org/https-everywhere
- **Browser Security**: https://browserleaks.com/
- **Chromium Build**: https://chromium.googlesource.com/chromium/src/+/master/docs/

---

## 📞 Support

**Having issues?**

1. Check [QUICKSTART.md](QUICKSTART.md) for common problems
2. Review [TECHNICAL.md](TECHNICAL.md) for architecture details
3. Check build logs: `cat build/logs/build.log`
4. Open GitHub issue: [issues](https://github.com/Felly-linux/Fellcrack-browser/issues)

---

## 🎯 Roadmap

- [ ] I2P integration
- [ ] Pluggable transports (obfuscation)
- [ ] Anonymous VPN database
- [ ] Decentralized DNS (ENS/IPNS)
- [ ] Hardened V8 sandbox
- [ ] Wayland optimization
- [ ] Docker support
- [ ] macOS/Windows ports

---

## ⭐ Why Sentinel Browser?

| Feature | Stock Brave | Sentinel | Firefox | Tor Browser |
|---------|------------|----------|---------|-----------|
| **Speed** | ✅ Fast | ✅ Fast | ✅ Medium | ❌ Slow |
| **TOR Built-in** | ❌ No | ✅ Yes | ❌ No | ✅ Yes |
| **DNS Privacy** | 🟡 Partial | ✅ Full | 🟡 Partial | ✅ Full |
| **Arch Native** | ❌ No | ✅ Yes | ✅ Yes | 🟡 Community |
| **Customization** | 🟡 Limited | ✅ Full | ✅ Full | ❌ No |
| **OPSEC Modes** | ❌ No | ✅ Yes | ❌ No | ✅ Yes |

---

## ⚖️ Lightweight Comparison: Size & Memory Usage

| Browser | Binary Size | RAM (Typical) | Startup | TOR Built-in | Privacy | Customization |
|---------|-------------|---------------|---------|-------------|---------|---------------|
| **Sentinel Browser** | 200-300 MB | 400-800 MB | ⚡⚡⚡ | ✅ Yes | ✅ Excellent | ✅ Full |
| **Chrome** | 200 MB | 300-800 MB | ⚡⚡⚡⚡ | ❌ No | ❌ Poor | 🟡 Limited |
| **Firefox** | 200 MB | 400-700 MB | ⚡⚡⚡ | ❌ No | ✅ Good | ✅ Full |
| **Opera GX** | 200 MB | 300-700 MB | ⚡⚡⚡⚡ | ❌ No | 🟡 Moderate | ✅ Good |
| **Vivaldi** | 250 MB | 400-700 MB | ⚡⚡⚡ | ❌ No | 🟡 Moderate | ✅ Excellent |
| **LibreWolf** | 200 MB | 400-600 MB | ⚡⚡⚡ | ❌ No | ✅ Good | ✅ Full |
| **Tor Browser** | 200 MB | 500-800 MB | ⚡⚡ | ✅ Yes | ✅ Excellent | 🟡 Limited |
| **Ungoogled Chromium** | 180 MB | 300-600 MB | ⚡⚡⚡⚡ | ❌ No | ✅ Excellent | ✅ Full |
| **Brave (Stock)** | 200 MB | 400-700 MB | ⚡⚡⚡ | ❌ No | ✅ Good | 🟡 Limited |
| **Safari** | 250 MB | 300-600 MB | ⚡⚡⚡⚡ | ❌ No | ✅ Good | ❌ None |
| **Qutebrowser** | 50 MB | 100-300 MB | ⚡⚡⚡⚡⚡ | ❌ No | 🟡 Moderate | ✅ Excellent |
| **w3m (CLI)** | 5 MB | 10-50 MB | ⚡⚡⚡⚡⚡ | ❌ No | ✅ Good | ✅ Full |

### 🎯 Lightweight Analysis

**Ultra-Lightweight (< 100 MB)**
- **Qutebrowser** (50 MB) - Qt-based, keyboard-driven, minimal features
- **w3m** (5 MB) - CLI-only browser, no JS/CSS rendering

**Lightweight (100-200 MB)**
- **Ungoogled Chromium** (180 MB) - Chromium without Google, highly recommended for privacy

**Standard (200-300 MB)** ← **Sentinel Browser is here**
- Sentinel Browser, Chrome, Firefox, Opera GX, LibreWolf, Tor Browser, Brave

**Heavier (> 250 MB)**
- Vivaldi, Safari

### ✅ Conclusion: Is Sentinel Lightweight?

**Yes, within the Chromium-based category:**
- ✅ Standard size like Firefox, Chrome, Brave
- ✅ Faster than Tor Browser (smaller overhead)
- ✅ Same memory footprint as Firefox
- ❌ Larger than Ungoogled Chromium (due to privacy features)
- ❌ Much larger than Qutebrowser or w3m

**Best for different needs:**
| Use Case | Recommendation |
|----------|-----------------|
| **Privacy + Performance** | Sentinel Browser ⭐ |
| **Extreme Privacy** | Tor Browser |
| **Lightweight + Privacy** | LibreWolf, Ungoogled Chromium |
| **Ultra-Lightweight** | Qutebrowser, w3m |
| **Balance (stock)** | Firefox |

---

## 💡 Philosophy

> *"Privacy is a human right. Anonymity is a choice. Surveillance is a weapon."*

Sentinel Browser gives you **all three**:
- Privacy by default (no tracking, encrypted)
- Anonymity when needed (TOR mode)
- Freedom to choose (flexible routing)

---

## 👨‍💻 Built by

**Developer**: Felly-linux  
**Project**: Sentinel Browser  
**Updated**: 2026-04-02  
**License**: MPL 2.0 + MIT

---

## 📊 Stats

- **Lines of Code**: 3,090+
- **Scripts**: 7 main + 3 utilities
- **Documentation**: 4 guides
- **Build Time**: 3-5 hours (first run)
- **Binary Size**: 200-300 MB
- **Disk Required**: 100 GB

---

**Ready to browse privately?**

```bash
git clone https://github.com/Felly-linux/Fellcrack-browser.git
cd Fellcrack-browser
bash quickstart.sh
```

🛡️ **Privacy starts here.**