#!/usr/bin/env python3
"""
🛡️  SENTINEL BROWSER PROJECT ANALYZER
Herramienta para analizar y validar la estructura del proyecto
"""

import os
import json
from pathlib import Path
from datetime import datetime

class ProjectAnalyzer:
    def __init__(self, root_path):
        self.root = Path(root_path)
        self.stats = {
            "scripts": [],
            "configs": [],
            "docs": [],
            "patches": [],
            "tools": [],
            "sizes": {}
        }
    
    def analyze(self):
        """Analizar estructura completa del proyecto"""
        print("🔍 Analizando Sentinel Browser Project...\n")
        
        # Scripts
        scripts_dir = self.root / "scripts"
        if scripts_dir.exists():
            for script in scripts_dir.glob("*.sh"):
                size = script.stat().st_size / 1024  # KB
                self.stats["scripts"].append({
                    "name": script.name,
                    "size_kb": round(size, 2),
                    "executable": os.access(script, os.X_OK)
                })
        
        # Configuraciones
        config_dir = self.root / "config"
        if config_dir.exists():
            for config in config_dir.glob("*"):
                if config.is_file():
                    size = config.stat().st_size / 1024
                    self.stats["configs"].append({
                        "name": config.name,
                        "size_kb": round(size, 2)
                    })
        
        # Documentación
        for doc in self.root.glob("*.md"):
            size = doc.stat().st_size / 1024
            self.stats["docs"].append({
                "name": doc.name,
                "size_kb": round(size, 2)
            })
        
        # Herramientas
        tools_dir = self.root / "tools"
        if tools_dir.exists():
            for tool in tools_dir.glob("*"):
                if tool.is_file():
                    size = tool.stat().st_size / 1024
                    self.stats["tools"].append({
                        "name": tool.name,
                        "size_kb": round(size, 2)
                    })
        
        # Parches
        patches_dir = self.root / "patches"
        if patches_dir.exists():
            for patch in patches_dir.glob("*"):
                size = patch.stat().st_size / 1024
                self.stats["patches"].append({
                    "name": patch.name,
                    "size_kb": round(size, 2)
                })
    
    def print_report(self):
        """Imprimir reporte de análisis"""
        print("\n╔════════════════════════════════════════╗")
        print("║  🛡️  SENTINEL BROWSER PROJECT REPORT  ║")
        print("║" + " " * 38 + "║")
        print(f"║  Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S'):<27}║")
        print("╚════════════════════════════════════════╝\n")
        
        # Scripts
        print("📝 SCRIPTS (Fases ejecutables)")
        print("━" * 50)
        for script in self.stats["scripts"]:
            status = "✓" if script["executable"] else "✗"
            print(f"  {status} {script['name']:<30} {script['size_kb']:>6.1f} KB")
        
        # Configs
        if self.stats["configs"]:
            print("\n⚙️  CONFIGURACIONES")
            print("━" * 50)
            for conf in self.stats["configs"]:
                print(f"  • {conf['name']:<30} {conf['size_kb']:>6.1f} KB")
        
        # Documentation
        if self.stats["docs"]:
            print("\n📖 DOCUMENTACIÓN")
            print("━" * 50)
            for doc in self.stats["docs"]:
                print(f"  • {doc['name']:<30} {doc['size_kb']:>6.1f} KB")
        
        # Tools
        if self.stats["tools"]:
            print("\n🔧 HERRAMIENTAS")
            print("━" * 50)
            for tool in self.stats["tools"]:
                print(f"  • {tool['name']:<30} {tool['size_kb']:>6.1f} KB")
        
        # Patches
        if self.stats["patches"]:
            print("\n📋 PARCHES")
            print("━" * 50)
            for patch in self.stats["patches"]:
                print(f"  • {patch['name']:<30} {patch['size_kb']:>6.1f} KB")
        
        # Resumen
        print("\n" + "━" * 50)
        print("📊 RESUMEN")
        print("━" * 50)
        total_scripts = len(self.stats["scripts"])
        executable_scripts = sum(1 for s in self.stats["scripts"] if s["executable"])
        
        print(f"  Scripts: {executable_scripts}/{total_scripts} ejecutables")
        print(f"  Configuraciones: {len(self.stats['configs'])}")
        print(f"  Documentación: {len(self.stats['docs'])} archivos")
        print(f"  Herramientas: {len(self.stats['tools'])}")
        print(f"  Parches: {len(self.stats['patches'])}")
        
        total_size = sum(
            s["size_kb"] for s in (
                self.stats["scripts"] + 
                self.stats["configs"] + 
                self.stats["docs"] + 
                self.stats["tools"] + 
                self.stats["patches"]
            )
        )
        print(f"  Tamaño total: {total_size:.1f} KB")
        
        print("\n✅ PROYECTO LISTO PARA USAR")
        print("━" * 50)
        print("\nComandos de inicio:")
        print("  • Automatizado:   bash quickstart.sh")
        print("  • Menú:          bash setup.sh")
        print("  • Manual:        ./scripts/bootstrap.sh")
        print("\nDocumentación:")
        print("  • Inicio rápido: QUICKSTART.md")
        print("  • Técnico:       TECHNICAL.md")

def main():
    root = Path(__file__).parent.absolute()
    analyzer = ProjectAnalyzer(root)
    analyzer.analyze()
    analyzer.print_report()

if __name__ == "__main__":
    main()
