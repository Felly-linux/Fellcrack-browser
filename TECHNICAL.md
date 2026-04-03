# 🛡️ SENTINEL BROWSER - Technical Documentation

## Architecture

### Components

```
Sentinel Browser (Brave fork)
├── Core Brave
│   ├── Chromium/V8
│   ├── Privacy features
│   └── Adblocking
├── OPSEC Layer
│   ├── TOR Integration (SOCKS5)
│   ├── DNS over HTTPS/TLS
│   ├── Anti-fingerprinting
│   └── Routing engine
└── CLI + Tools
    ├── Circuit switcher
    ├── IP checker
    └── Profile manager
```

## Features

### 1. TOR Integration ✅

**How it works:**
- Detects local TOR daemon (port 9050/9051)
- Routes traffic via SOCKS5 proxy
- Supports circuit switching (new exit IP)
- Per-tab routing possible

**Commands:**
```bash
./scripts/sentinel --tor                  # Force TOR
./scripts/sentinel --mode opsec          # TOR + anti-fingerprinting
tools/tor-circuit-switcher.py --switch   # Change exit IP
```

**Configuration:**
```yaml
# config/sentinel-opsec.conf
[proxy]
tor_enabled = true
tor_host = 127.0.0.1
tor_port = 9050
tor_verify_ssl = false
```

### 2. DNS over HTTPS/TLS 🔒

**Supported providers:**
- Cloudflare (1.1.1.2 - malware filtered)
- Quad9 (9.9.9.9)
- NextDNS
- Custom DoH/DoT endpoints

**Prevents:**
- DNS hijacking
- DNS-based filtering
- ISP DNS monitoring
- DNS leaks (via WebRTC)

**Configuration:**
```conf
dns_over_https = true
dns_over_tls = true
dns_providers = ["1.1.1.2", "1.0.0.2"]
```

### 3. Anti-fingerprinting 🎭

**Brave built-in features:**
- Canvas fingerprint protection
- WebGL fingerprint protection
- Font enumeration blocking
- User-Agent randomization (optional)
- Hardware acceleration disabled

**Additional:**
- Timezone tracking prevention
- Motion sensor blocking
- Reduced motion mode

### 4. Routing Engine 🔀

**Three routing modes:**

1. **Direct** - Fast, no privacy
   - GitHub, StackOverflow, YouTube

2. **Proxy** - Moderate privacy
   - Google, Facebook, Amazon
   - Via HTTP/HTTPS proxy

3. **TOR** - Maximum privacy
   - .onion sites
   - Privacy-focused services
   - Sensitive queries

**Dynamic switching:**
```yaml
# config/routing-rules.yaml
routes:
  direct:
    - github.com
  proxy:
    - google.com
  tor:
    - "*.onion"
    - protonmail.com
```

### 5. VPN Integration 📡

**Automatic detection:**
- TUN0 (OpenVPN)
- WG0 (WireGuard)
- Custom interfaces

**Usage:**
```bash
./scripts/sentinel --vpn                 # Use system VPN
# Si VPN está activo, se usa automáticamente
```

### 6. Security Hardening 🔐

**Disabled:**
- NaCl (deprecated)
- Pepper plugins
- Widevine DRM
- Telemetry/crash reporting
- Safe browsing (tracker list)

**Enabled:**
- HTTPS Everywhere
- Mixed content blocking
- Sandbox
- Site isolation

## Building

### System Requirements

- Linux (Arch recommended)
- 80GB+ disk space
- 8GB+ RAM (16GB recommended)
- Build time: 1-3 hours

### Build Chain

```bash
# Phase 1: Bootstrap (prep)
./scripts/bootstrap.sh

# Phase 2: Compile
./scripts/build.sh --release

# Phase 3: Configure OPSEC
./scripts/opsec-config.sh

# Phase 4: Run
./scripts/sentinel --mode opsec
```

### GN Arguments (Build Configuration)

Key variables in `build/brave/build/out/Release/args.gn`:

```gn
is_official_build = true        # Official build
is_debug = false                # Release build
enable_nacl = false             # Disable NaCl
enable_plugins = false          # Disable plugins
enable_widevine = false         # Disable DRM
enable_socks5 = true            # SOCKS5 support
use_custom_libcxx = true        # LLVM libc++
```

## Execution Modes

### 1. Normal Mode
```bash
./scripts/sentinel
```
- Standard Brave behavior
- DNS plain
- No routing preferences

### 2. Privacy Mode
```bash
./scripts/sentinel --mode privacy
```
- DNS over HTTPS
- Ad blocking (uBlock Origin)
- Anti-fingerprinting

### 3. OPSEC Mode ⚠️
```bash
./scripts/sentinel --mode opsec
```
- All traffic via TOR
- DNS over HTTPS/TLS
- Anti-fingerprinting maximized
- Extended validation
- No plugins/extensions except uBlock

### 4. TOR Mode
```bash
./scripts/sentinel --tor
./scripts/sentinel https://example.onion
```
- Force TOR for all sites
- .onion support

### 5. Offline Mode
```bash
./scripts/sentinel --offline
```
- No network requests
- Cached content only
- Local resources

## Profiles

Each profile is isolated:
```bash
~/.sentinel-browser/default/          # Default profile
~/.sentinel-browser/privacy/          # Privacy profile
~/.sentinel-browser/banking/          # Banking (no extensions)
~/.sentinel-browser/development/      # Development
```

Usage:
```bash
./scripts/sentinel --profile banking
```

## Tools

### TOR Circuit Switcher
```bash
tools/tor-circuit-switcher.py --switch     # Change exit IP
tools/tor-circuit-switcher.py --interval 300  # Every 5min
tools/tor-circuit-switcher.py --monitor   # Real-time monitoring
```

### IP Checker
```bash
tools/check-ip.sh                    # Check current IP
# Tests: HTTP, DNS, TOR, WebRTC leak
```

### Extension Manager
```bash
tools/install-extensions.sh          # Install privacy extensions
```

## Arch Linux Integration

### Installation

```bash
cd arch
makepkg -si
```

Creates:
- `/usr/bin/sentinel-browser`
- `/usr/share/applications/sentinel-browser.desktop`
- Man page: `man sentinel-browser`

### System Integration

```bash
# Update system
pacman -Syu

# Install Sentinel
makepkg -si

# Launch
sentinel-browser --mode opsec
```

## Troubleshooting

### TOR not working
```bash
# Check TOR service
sudo systemctl status tor

# Start TOR
sudo systemctl start tor

# Test connection
nc -zv 127.0.0.1 9050
```

### Build failures
1. Ensure all deps: `pacman -S base-devel git ninja python gn`
2. Check logs: `tail -f build/logs/build.log`
3. Clean previous build: `./scripts/build.sh --clean`

### IP leak detection
```bash
# Test with tools
tools/check-ip.sh

# Online: https://browserleaks.com/
# DNS leak: https://dnsleaktest.com/
# WebRTC: https://browserleaks.com/webrtc
```

## Future Roadmap

- [ ] I2P integration
- [ ] Obfuscation layer (Pluggable transports)
- [ ] Anonymous VPN integration
- [ ] Decentralized DNS (ENS/IPNS)
- [ ] Hardened V8 sandbox
- [ ] Wayland support optimization

## References

- [Brave Security](https://github.com/brave/brave-browser)
- [TOR Project](https://www.torproject.org/)
- [DNS over HTTPS/TLS](https://www.eff.org/https-everywhere)
- [Browser Security](https://browserleaks.com/)
