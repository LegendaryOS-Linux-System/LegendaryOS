#!/usr/bin/env bash
# scripts/after/check-nvidia.sh (opcjonalny)
# Uruchamiany wewnątrz kontenera — sprawdza czy konfiguracja NVIDIA jest spójna.
# NIE instaluje sterowników (to robi kickstart) — tylko waliduje.
set -euo pipefail

echo "==> LegendaryOS: NVIDIA configuration check"

# Sprawdź czy RPM Fusion jest dostępny w repos/
RPMFUSION_REPO="/etc/yum.repos.d/rpmfusion-nonfree.repo"
if [ ! -f "$RPMFUSION_REPO" ]; then
    echo "    WARN: RPM Fusion nonfree repo not found at $RPMFUSION_REPO"
    echo "    WARN: NVIDIA drivers require RPM Fusion — add repos/rpmfusion.repo"
fi

# Sprawdź czy akmod-nvidia jest dostępny
if dnf info akmod-nvidia &>/dev/null; then
    VERSION=$(dnf info akmod-nvidia 2>/dev/null | grep "^Version" | awk '{print $3}' | head -1)
    echo "    akmod-nvidia available: $VERSION"
else
    echo "    WARN: akmod-nvidia not found in repos"
    echo "    WARN: Make sure repos/rpmfusion.repo is present"
fi

echo "==> NVIDIA check done"
