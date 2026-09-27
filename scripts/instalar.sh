#!/bin/bash
# Compila Maskot y lo instala en /Applications. Uso: ./scripts/instalar.sh
set -euo pipefail
cd "$(dirname "$0")/.."

./scripts/app.sh >/dev/null
pkill -x Maskot 2>/dev/null || true
rm -rf /Applications/Maskot.app
cp -R build/Maskot.app /Applications/
echo "✅ Maskot instalado en /Applications"
open /Applications/Maskot.app
