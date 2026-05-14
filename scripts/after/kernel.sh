#!/usr/bin/env bash
# scripts/after/00-kernel.sh
# Instaluje Nobara kernel i ustawia go jako domyślny w GRUB.
# Fedora kernel zostaje zainstalowany jako fallback.
#
# Kolejność w GRUB po instalacji:
#   [0] Nobara kernel (domyślny)
#   [1] Fedora kernel (fallback)
set -euo pipefail

echo "==> LegendaryOS: Installing Nobara kernel"

# Zainstaluj Nobara kernel (repo musi być w /etc/yum.repos.d/)
dnf install -y \
    nobara-kernel \
    nobara-kernel-modules \
    nobara-kernel-modules-extra \
    || {
        echo "WARN: nobara-kernel not found — check repos/nobara.repo"
        exit 0
    }

echo "==> Setting Nobara kernel as default"

# Znajdź najnowszy wpis Nobara w GRUB
NOBARA_ENTRY=$(grubby --info=ALL 2>/dev/null \
    | grep -A5 "nobara" \
    | grep "^kernel=" \
    | head -1 \
    | sed 's/kernel=//')

if [ -n "$NOBARA_ENTRY" ]; then
    grubby --set-default="$NOBARA_ENTRY"
    echo "    Default kernel set to: $NOBARA_ENTRY"
else
    # Fallback: ustaw przez index (Nobara zazwyczaj instaluje się jako 0)
    grubby --set-default-index=0
    echo "    Default kernel set to index 0"
fi

# Weryfikacja
echo "    Current default kernel:"
grubby --default-kernel 2>/dev/null || true

echo "==> Nobara kernel setup done"
echo ""
echo "    Boot menu will show:"
echo "      [0] Nobara kernel (default)  ← gaming optimized"
echo "      [1] Fedora kernel             ← fallback"
