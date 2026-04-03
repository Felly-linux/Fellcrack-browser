# 🛡️ Sentinel Browser - Guía de Inicio Rápido

## Estructura Completa

```
sentinel-browser/
├── README.md                        # Este archivo
├── TECHNICAL.md                     # Documentación técnica
├── quickstart.sh                    # Setup automatizado
├── setup.sh                         # Menú interactivo
│
├── scripts/
│   ├── bootstrap.sh                 # ⭐ Fase 1: Descargar + preparar
│   ├── build-impl.sh                # ⭐ Fase 2: Compilar Brave
│   ├── opsec-config.sh              # ⭐ Fase 3: Configuración de privacidad
│   ├── install-tor-tools.sh         # ⭐ Fase 4: Herramientas TOR
│   ├── sentinel                     # ⭐ Fase 5: Ejecutar navegador
│   └── .env.sh                      # Variables de entorno
│
├── config/
│   ├── sentinel-opsec.conf          # Configuración OPSEC
│   ├── routing-rules.yaml           # Reglas de routing (direct/proxy/tor)
│   └── .opsec-env                   # Variables OPSEC
│
├── patches/
│   └── 001-disable-update-check.patch.example
│
├── tools/
│   ├── tor-circuit-switcher.py      # Cambiar circuito TOR
│   ├── check-ip.sh                  # Verificar IP/geo/leaks
│   ├── install-extensions.sh        # Instalar extensiones
│   └── create-pkgbuild.sh           # Generar PKGBUILD
│
├── arch/
│   └── PKGBUILD                     # Paquete Arch Linux
│
└── build/
    ├── depot_tools/                 # Herramientas de compilación
    ├── brave/build/                 # Fuente de Brave
    └── out/                         # Binarios compilados
        └── brave-release/brave      # Binario final
```

---

## 🚀 INICIO RÁPIDO

### Opción A: Automatizado (RECOMENDADO)

```bash
cd /home/fellcrack/Trabajo/Personal/Desarrollo/Fellcrack-browser
bash quickstart.sh
```

**Lo que hace:**
1. ✓ Valida dependencias
2. ✓ Bootstrap (descarga Brave, ~2 horas)
3. ✓ Compila (Brave fork, ~1-3 horas)
4. ✓ Configura OPSEC
5. ✓ Genera herramientas

### Opción B: Paso a Paso

```bash
# Fase 1: Preparar entorno
./scripts/bootstrap.sh

# Fase 2: Compilar (espera ~2 horas)
./scripts/build.sh --release

# Fase 3: Configurar privacidad
./scripts/opsec-config.sh

# Fase 4: Ejecutar
./scripts/sentinel --mode opsec
```

### Opción C: Menú Interactivo

```bash
bash setup.sh

# Selecciona opciones del 1-9
```

---

## ⚡ USOS DIRECTOS

### Navegación Normal
```bash
./scripts/sentinel https://github.com
```

### Modo Privacy (HTTPS + Anti-fingerprint)
```bash
./scripts/sentinel --mode privacy https://duckduckgo.com
```

### Modo OPSEC (TODO a través de TOR)
```bash
./scripts/sentinel --mode opsec
```

### Forzar TOR
```bash
./scripts/sentinel --tor https://example.onion
```

### Con VPN del sistema
```bash
./scripts/sentinel --vpn
```

### Perfil aislado
```bash
./scripts/sentinel --profile banking https://mybank.com
```

### Cambiar circuito TOR
```bash
python3 tools/tor-circuit-switcher.py --switch
python3 tools/tor-circuit-switcher.py --interval 300  # Cada 5 min
```

### Verificar IP/Geo
```bash
bash tools/check-ip.sh
```

---

## 📋 REQUISITOS PREVIOS

### Linux (Arch preferible)
```bash
# Arch Linux
sudo pacman -S base-devel git ninja python gn

# Ubuntu/Debian
sudo apt-get install build-essential git ninja-build python3 gn

# Fedora
sudo dnf install gcc gcc-c++ git ninja python3 gn
```

### Espacio en Disco
- **80GB** para fuente de Brave
- **20GB** para compilación
- **5GB** para binario final

### Tiempo
- **2 horas** para bootstrap (descarga)
- **1-3 horas** para compilación
- Total: **3-5 horas** primera ejecución

---

## 🔐 CARACTERÍSTICAS INCLUIDAS

### ✅ Hardened Brave
- Flags de privacidad preconfigurados
- Telemetría desactivada
- NaCl/plugins/Widevine deshabilitados

### ✅ TOR Integration
- SOCKS5 proxy automático
- Circuit switcher dinámico
- Detección automática del servicio TOR

### ✅ DNS Privada
- DNS over HTTPS (Cloudflare, Quad9)
- DNS over TLS
- Prevención de DNS leaks

### ✅ Routing Dinámico
- Direct (rápido)
- Proxy (moderado)
- TOR (máxima privacidad)
- Reglas personalizables por dominio

### ✅ Anti-fingerprinting
- Canvas protection
- WebGL protection
- Font blocking
- User-Agent randomization
- Timezone masking

### ✅ VPN Integration
- Detección automática (TUN/WireGuard)
- Integración con OpenVPN/WireGuard

### ✅ Herramientas CLI
- TOR circuit switcher
- IP/Geo checker
- Extensión installer
- Profile manager

---

## 📖 DOCUMENTACIÓN ADICIONAL

- **TECHNICAL.md** - Arquitectura técnica, features detalladas
- **scripts/bootstrap.sh** - Explicación del proceso de bootstrap
- **config/sentinel-opsec.conf** - Configuración completa comentada
- **config/routing-rules.yaml** - Reglas de routing

---

## 🐛 TROUBLESHOOTING

### "TOR no disponible"
```bash
# Instalar TOR
sudo pacman -S tor

# Iniciar TOR
sudo systemctl start tor
sudo systemctl enable tor

# Verificar
sudo systemctl status tor
```

### "Build falló"
1. Revisa logs: `tail -f build/logs/build.log`
2. Limpia build anterior: `./scripts/build.sh --clean`
3. Verifica dependencies: `pacman -S base-devel ninja python gn`
4. Reinicia: `./scripts/build.sh --release --jobs 1`

### "Binario no ejecuta"
```bash
./build/sentinel-browser --version

# Si faltan libs
ldd ./build/sentinel-browser | grep "not found"
```

### "No hay espacio en disco"
- Bootstrap necesita **100GB** temporal
- Usa: `du -sh build/` para verificar tamaño
- Limpia después: `rm -rf build/brave/build/src/`

---

## 🏗️ ARCH LINUX (PKGBUILD)

```bash
cd arch
makepkg -si              # Compilador e instala
# O solo compilar:
makepkg                  # Genera .pkg.tar.zst
```

Crea:
- `/usr/bin/sentinel-browser`
- `/usr/share/applications/sentinel-browser.desktop`
- Man page: `man sentinel-browser`

---

## 🔗 ENLACES ÚTILES

- [Brave Browser](https://github.com/brave/brave-browser)
- [TOR Project](https://www.torproject.org/)
- [Browser Leaks](https://browserleaks.com/)
- [DNS Leak Test](https://www.dnsleaktest.com/)
- [EFF - DoH/DoT](https://www.eff.org/https-everywhere)

---

## 📜 LICENCIA

- Brave: MPL2.0 + Apache 2.0
- Sentinel patches: MIT (libre)

---

## 🤝 CONTRIBUCIONES

1. Fork el proyecto
2. Crea branch feature: `git checkout -b feature/amazing`
3. Commit cambios: `git commit -am 'Add feature'`
4. Push: `git push origin feature/amazing`
5. Pull request

---

## ⚠️ DISCLAIMER

Sentinel Browser es para **uso educativo y de investigación**. El uso de TOR y VPNs puede estar regulado en tu jurisdicción. **USO BAJO TU RESPONSABILIDAD**.

---

**Actualizado:** 2026-04-02  
**Versión:** 1.0.0-alpha  
**Proyecto:** Sentinel Browser - Privacy-First Brave Fork
