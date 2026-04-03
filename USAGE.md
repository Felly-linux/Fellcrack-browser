# 🛡️ OPSEC Browser - Usage Guide

## Quick Start (2 Minutes)

```bash
# 1. Clone
git clone https://github.com/Felly-linux/Fellcrack-browser.git
cd Fellcrack-browser

# 2. Install (auto-detects Arch/Ubuntu/Fedora)
bash scripts/auto-setup.sh

# 3. Use
opsec-browser --tor
```

**Done!** Brave will launch with privacy flags and TOR proxy configured.

---

## Installation

### Automatic (Recommended)
```bash
bash scripts/auto-setup.sh
```

Installs:
- Brave Browser
- TOR daemon
- Creates symlink: `opsec-browser`
- Sets up profiles

### Manual
```bash
# Install dependencies
sudo pacman -S brave-browser tor          # Arch
sudo apt-get install brave-browser tor    # Ubuntu/Debian

# Create symlink
sudo ln -sf ~/Fellcrack-browser/bin/opsec-browser /usr/local/bin/

# Run
opsec-browser --tor
```

---

## Usage

### Modes

**Normal Mode** (No privacy features)
```bash
opsec-browser --normal
opsec-browser --normal https://github.com
```

**Privacy Mode** (DNS-HTTPS + anti-fingerprinting)
```bash
opsec-browser --privacy
opsec-browser --privacy https://duckduckgo.com
```

**TOR Mode** (All traffic via TOR - maximum privacy)
```bash
opsec-browser --tor
opsec-browser --tor https://example.onion
```

### Profiles

Isolated browsing contexts (separate cookies, cache, extensions):

```bash
# Default profile
opsec-browser --tor

# Banking profile (isolated)
opsec-browser --profile banking https://mybank.com

# Work profile
opsec-browser --profile work https://github.com

# Personal profile
opsec-browser --profile personal
```

Profiles stored in: `~/.config/opsec-browser/{default,banking,work,personal}`

### Full Examples

```bash
# Browse .onion sites anonymously
opsec-browser --tor https://3g2upl4pq6kufc4m.onion

# Private searches
opsec-browser --privacy https://duckduckgo.com

# Banking (isolated profile, privacy mode)
opsec-browser --profile banking https://mybank.com

# Work (another isolated profile)
opsec-browser --profile work https://github.com

# Normal browsing
opsec-browser --normal https://reddit.com
```

---

## How It Works

```
opsec-browser CLI
      ↓
/bin/opsec-browser
      ↓
Parse arguments (--tor, --privacy, --profile)
      ↓
scripts/core.sh
      ├─ Detect Brave
      ├─ Detect TOR (if mode=--tor)
      ├─ Build privacy flags
      ├─ Setup profile directory
      └─ Launch Brave with flags + optional SOCKS5 proxy

Brave launches with:
  - Privacy flags (--disable-sync, --no-tracking, etc.)
  - Isolated profile (--user-data-dir)
  - Optional TOR proxy (--proxy-server=socks5://127.0.0.1:9050)
```

---

## Architecture

```
Fellcrack-browser/
├── bin/
│   └── opsec-browser          ← Main CLI entry point
├── scripts/
│   ├── core.sh                ← Core functions (detect, launch, flags)
│   ├── run.sh                 ← Alternative launcher
│   ├── install.sh             ← Install dependencies
│   └── auto-setup.sh          ← One-command setup
├── config/
│   └── privacy_flags.conf     ← Privacy configuration
└── [other files: docs, patches, etc.]

Execution Flow:
  opsec-browser --tor
    → sources bin/opsec-browser
    → sources scripts/core.sh (functions)
    → ensure_tor()
    → get_privacy_flags("opsec")
    → setup_profile("default")
    → launch_brave("opsec", "default", "")
    → exec brave [flags] [proxy]
```

---

## Features

✅ **Auto-detection**
- Detects if Brave installed → installs if missing
- Detects if TOR running → starts if missing

✅ **Privacy Modes**
- Normal: Standard browser
- Privacy: DNS-HTTPS + anti-fingerprint
- TOR: Max privacy via TOR

✅ **Profile Isolation**
- Separate profiles: default, banking, work, personal
- Each has own cookies, cache, extensions

✅ **Flexible**
- Works on Arch, Ubuntu, Fedora
- Can use any URL (http/https/.onion)
- Fallback to Chromium if Brave missing

---

## Configuration

Edit `config/privacy_flags.conf` to customize:

```ini
[privacy_flags]
base_flags=--disable-sync --no-first-run
privacy_flags=--block-mixed-content
opsec_flags=--disable-plugins --no-service-autorun

[tor_config]
tor_host=127.0.0.1
tor_port=9050

[profiles]
available_profiles=default,banking,work,personal
```

---

## Troubleshooting

### "Brave not found"
```bash
# Install Brave
sudo pacman -S brave-browser    # Arch
sudo apt-get install brave-browser  # Ubuntu
```

### "TOR not running"
```bash
# Start TOR
sudo systemctl start tor
sudo systemctl enable tor
```

### "Can't connect through TOR"
```bash
# Check if TOR is listening
nc -zv 127.0.0.1 9050

# If failed, restart
sudo systemctl stop tor
sudo systemctl start tor
sleep 3
```

### "Command not found: opsec-browser"
```bash
# Reinstall symlink
sudo ln -sf ~/Fellcrack-browser/bin/opsec-browser /usr/local/bin/
```

---

## Performance Tips

1. **Use Privacy Mode Instead of TOR** if anonymity not critical
   - TOR is slower but harder to intercept
   - Privacy mode is faster with good privacy

2. **Close Unused Profiles**
   - Each profile uses RAM
   - Only keep active ones open

3. **Disable Extensions in OPSEC Mode**
   - Reduces fingerprint
   - Faster loading

4. **Use DNS Filters**
   - uBlock Origin blocks ads
   - Faster browsing when ads removed

---

## Security Notes

⚠️ **TOR + VPN = Bad**
- Don't use system VPN + TOR mode
- Can detect your real IP

⚠️ **Profile ≠ Anonymity**
- Profiles are isolated but you're not anonymous
- Use TOR mode for anonymity

⚠️ **WebRTC Leaks**
- Firefox blocks WebRTC better
- Brave disabled it via flags
- Test: https://browserleaks.com/webrtc

---

## What's Next?

Future additions:
- [ ] I2P integration
- [ ] Proxy auto-rotation
- [ ] Circuit switching UI
- [ ] VPN compartmentalization  
- [ ] Custom DNS per-profile
- [ ] DNS over TLS (DoT)

---

## Support

Have issues?

1. Check this guide
2. Check GitHub issues
3. Run `opsec-browser --help`
4. Check logs: `~/.cache/opsec-browser/`

---

**Ready?** Start with:

```bash
git clone https://github.com/Felly-linux/Fellcrack-browser.git
cd Fellcrack-browser
bash scripts/auto-setup.sh
opsec-browser --tor
```

🛡️ **Private browsing, simplified.**
