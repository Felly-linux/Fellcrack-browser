#!/bin/bash
# 🧅 TOR INTEGRATION - Sentinel Browser
# Integración avanzada con TOR + circuit switching dinámico

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLS_DIR="$PROJECT_ROOT/tools"

mkdir -p "$TOOLS_DIR"

# ============================================================
# Script 1: TOR Monitor y Circuit Switcher
# ============================================================
cat > "$TOOLS_DIR/tor-circuit-switcher.py" <<'EOF'
#!/usr/bin/env python3
"""
🧅 TOR Circuit Switcher
Cambia circuitos de TOR dinámicamente para sesiones aisladas
"""

import socket
import sys
import os
import time
import argparse
from datetime import datetime

class TORController:
    def __init__(self, host="127.0.0.1", port=9051, password=""):
        self.host = host
        self.port = port
        self.password = password
        self.connected = False
        
    def connect(self):
        """Conectar a TOR control port"""
        try:
            self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.sock.connect((self.host, self.port))
            self.connected = True
            print(f"✓ Conectado a TOR en {self.host}:{self.port}")
            return True
        except Exception as e:
            print(f"❌ Error conectando a TOR: {e}")
            print(f"⚠️  Asegúrate que TOR está corriendo:")
            print(f"   sudo systemctl start tor")
            print(f"   O edita /etc/tor/torrc para habilitar ControlPort 9051")
            return False
    
    def send_command(self, cmd):
        """Enviar comando a TOR"""
        if not self.connected:
            return None
        
        try:
            self.sock.send((cmd + "\r\n").encode())
            response = self.sock.recv(4096).decode()
            return response
        except Exception as e:
            print(f"❌ Error: {e}")
            return None
    
    def switch_circuit(self):
        """Cambiar circuito TOR (nueva IP/salida)"""
        if not self.connected:
            return False
        
        try:
            # Comando para cambiar circuito
            response = self.send_command("SIGNAL NEWNYM")
            if "250 OK" in response:
                print(f"[{datetime.now().strftime('%H:%M:%S')}] ✓ Circuito TOR cambió (nueva salida)")
                # Esperar a que TOR procese
                time.sleep(5)
                return True
            else:
                print(f"❌ Error cambiando circuito: {response}")
                return False
        except Exception as e:
            print(f"❌ Error: {e}")
            return False
    
    def get_circuit_info(self):
        """Obtener información del circuito actual"""
        if not self.connected:
            return None
        
        try:
            response = self.send_command("GETINFO circuit-status")
            return response
        except:
            return None

def main():
    parser = argparse.ArgumentParser(
        description="🧅 TOR Circuit Switcher - Cambia circuitos dinámicamente",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Ejemplos:
  %(prog)s --switch              # Cambiar circuito una vez
  %(prog)s --interval 300        # Cambiar cada 5 minutos
  %(prog)s --info                # Mostrar info del circuito
  %(prog)s --monitor             # Monitorear en tiempo real
        """
    )
    
    parser.add_argument("--switch", action="store_true", help="Cambiar circuito")
    parser.add_argument("--interval", type=int, help="Cambiar cada N segundos")
    parser.add_argument("--monitor", action="store_true", help="Monitorear circuitos")
    parser.add_argument("--info", action="store_true", help="Mostrar info actual")
    parser.add_argument("--host", default="127.0.0.1", help="Host TOR control")
    parser.add_argument("--port", type=int, default=9051, help="Puerto TOR control")
    
    args = parser.parse_args()
    
    # Crear controlador
    tor = TORController(args.host, args.port)
    
    if not tor.connect():
        sys.exit(1)
    
    # Ejecutar acción
    if args.switch:
        tor.switch_circuit()
    
    elif args.interval:
        print(f"🔄 Cambiando circuito cada {args.interval}s (Ctrl+C para detener)...")
        try:
            counter = 1
            while True:
                time.sleep(args.interval)
                print(f"\n[#{counter}] Cambiando circuito...")
                tor.switch_circuit()
                counter += 1
        except KeyboardInterrupt:
            print("\n\n✓ Detenido por usuario")
    
    elif args.monitor:
        print("📊 Monitoreando TOR en tiempo real (Ctrl+C para detener)...")
        try:
            while True:
                info = tor.get_circuit_info()
                if info:
                    print(f"\n[{datetime.now().strftime('%H:%M:%S')}] Circuitos activos:")
                    print(info)
                time.sleep(10)
        except KeyboardInterrupt:
            print("\n✓ Detenido")
    
    elif args.info:
        info = tor.get_circuit_info()
        if info:
            print("Información de circuitos TOR:")
            print(info)
    
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
EOF

chmod +x "$TOOLS_DIR/tor-circuit-switcher.py"
echo "✓ TOR Circuit Switcher creado"

# ============================================================
# Script 2: Detector de IP/Geolocalización
# ============================================================
cat > "$TOOLS_DIR/check-ip.sh" <<'EOF'
#!/bin/bash
# 🌐 Check IP/Geo - Verificar IP y geolocalización actual

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}✓${NC} $1"; }
log_title() { echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n${BLUE}$1${NC}\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

# Funciones para detectar IP
check_http_ip() {
    echo -e "${YELLOW}HTTP IP:${NC}"
    curl -s https://api.ipify.org?format=json | python3 -m json.tool
}

check_dns_ip() {
    echo -e "\n${YELLOW}DNS IP:${NC}"
    dig +short myip.opendns.com @resolver1.opendns.com
}

check_tor_ip() {
    if nc -z localhost 9050 2>/dev/null; then
        echo -e "\n${YELLOW}TOR IP:${NC}"
        curl -s -x socks5h://127.0.0.1:9050 https://api.ipify.org?format=json | python3 -m json.tool
    else
        echo -e "\n${RED}⚠  TOR no disponible${NC}"
    fi
}

check_proxy_info() {
    echo -e "\n${YELLOW}Información de Proxy:${NC}"
    if command -v proxychains4 &>/dev/null; then
        proxychains4 -q curl -s https://api.icanhazip.com
    fi
}

check_webrtc_leak() {
    echo -e "\n${YELLOW}WebRTC Leak Test:${NC}"
    echo "⚠️  Visita: https://browserleaks.com/webrtc"
}

# Main
log_title "🌐 SENTINEL BROWSER - IP/GEO CHECK"

check_http_ip
check_dns_ip
check_tor_ip
check_proxy_info
check_webrtc_leak

log_title "DNS Leak Test"
echo "Visita: https://www.dnsleaktest.com/"

EOF

chmod +x "$TOOLS_DIR/check-ip.sh"
echo "✓ IP Checker creado"
