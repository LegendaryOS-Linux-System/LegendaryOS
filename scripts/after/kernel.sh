#!/usr/bin/env bash
# scripts/after/Kernel.sh
# Usuwa domyślne jądro Fedory i instaluje jądro LegendaryOS
set -euo pipefail

# ════════════════════════════════════════════════════════════════════════════
# Konfiguracja
# ════════════════════════════════════════════════════════════════════════════

KERNEL_URL="https://github.com/LegendaryOS-Linux-System/LegendaryOS-Kernel/releases/download/v0.0.1/LegendaryOS-Kernel-7.1-1.x86_64.rpm"
KERNEL_RPM="/tmp/LegendaryOS-Kernel-7.1-1.x86_64.rpm"
KERNEL_VERSION="7.1-1"
LOG_PREFIX="==> LegendaryOS [Kernel]:"

# ════════════════════════════════════════════════════════════════════════════
# Funkcje pomocnicze
# ════════════════════════════════════════════════════════════════════════════

log()  { echo "${LOG_PREFIX} $*"; }
warn() { echo "${LOG_PREFIX} WARN: $*" >&2; }
die()  { echo "${LOG_PREFIX} BŁĄD: $*" >&2; exit 1; }

cleanup() {
    if [[ -f "$KERNEL_RPM" ]]; then
        log "Sprzątanie — usuwanie $KERNEL_RPM..."
        rm -f "$KERNEL_RPM"
        log "Plik RPM usunięty z /tmp."
    fi
}

# Uruchom cleanup przy wyjściu (również przy błędzie)
trap cleanup EXIT

# ════════════════════════════════════════════════════════════════════════════
# 1. Sprawdzenie uprawnień
# ════════════════════════════════════════════════════════════════════════════

if [[ "$EUID" -ne 0 ]]; then
    die "Skrypt wymaga uprawnień roota. Uruchom: sudo $0"
fi

log "Start instalacji jądra LegendaryOS"
echo ""

# ════════════════════════════════════════════════════════════════════════════
# 2. Wykrycie i usunięcie domyślnych jąder Fedory
# ════════════════════════════════════════════════════════════════════════════

log "Wykrywanie zainstalowanych jąder Fedory..."

# Pobierz listę zainstalowanych jąder (kernel + kernel-core)
FEDORA_KERNELS=$(rpm -qa 'kernel' 'kernel-core' 'kernel-modules' 'kernel-modules-core' \
                           'kernel-modules-extra' 'kernel-devel' 'kernel-headers' \
                 2>/dev/null | grep -v 'LegendaryOS' | sort || true)

if [[ -z "$FEDORA_KERNELS" ]]; then
    warn "Nie znaleziono domyślnych jąder Fedory — pomijam usuwanie."
else
    log "Znalezione jądra Fedory do usunięcia:"
    echo "$FEDORA_KERNELS" | while read -r pkg; do
        echo "    - $pkg"
    done
    echo ""

    log "Usuwanie domyślnych jąder Fedory..."

    # Usuń przez dnf — ignoruje brakujące paczki (--ignore-installed nie istnieje,
    # ale dnf remove po prostu pominie paczki których nie ma)
    if dnf remove -y \
        'kernel' \
        'kernel-core' \
        'kernel-modules' \
        'kernel-modules-core' \
        'kernel-modules-extra' \
        'kernel-devel' \
        'kernel-headers' \
        2>/dev/null; then
        log "Domyślne jądra Fedory zostały usunięte."
    else
        warn "dnf remove zakończył się z błędem (możliwe że część paczek już nie istniała)."
    fi
fi

echo ""

# ════════════════════════════════════════════════════════════════════════════
# 3. Pobieranie jądra LegendaryOS
# ════════════════════════════════════════════════════════════════════════════

log "Pobieranie jądra LegendaryOS v${KERNEL_VERSION}..."
log "Źródło: $KERNEL_URL"
log "Cel:    $KERNEL_RPM"
echo ""

if ! curl -L --progress-bar --fail -o "$KERNEL_RPM" "$KERNEL_URL"; then
    die "Nie udało się pobrać jądra z: $KERNEL_URL"
fi

# Weryfikacja — czy plik istnieje i nie jest pusty
if [[ ! -s "$KERNEL_RPM" ]]; then
    die "Pobrany plik jest pusty lub nie istnieje: $KERNEL_RPM"
fi

FILESIZE=$(du -sh "$KERNEL_RPM" | cut -f1)
log "Pobrano pomyślnie (rozmiar: ${FILESIZE})."
echo ""

# ════════════════════════════════════════════════════════════════════════════
# 4. Instalacja jądra LegendaryOS
# ════════════════════════════════════════════════════════════════════════════

log "Instalowanie jądra LegendaryOS..."

if ! dnf install -y "$KERNEL_RPM"; then
    die "Instalacja jądra nie powiodła się."
fi

log "Jądro LegendaryOS zainstalowane pomyślnie."
echo ""

# ════════════════════════════════════════════════════════════════════════════
# 5. Ustawienie jądra LegendaryOS jako domyślnego
# ════════════════════════════════════════════════════════════════════════════

log "Ustawianie jądra LegendaryOS jako domyślnego w GRUB..."

# Znajdź wpis jądra LegendaryOS w grub
GRUB_ENTRY=$(grub2-editenv list 2>/dev/null | grep 'saved_entry' | cut -d= -f2 || true)

# Pobierz listę jąder z grubenv / grubby
LEGENDARYOS_KERNEL=$(grubby --info=ALL 2>/dev/null \
    | grep -A5 'LegendaryOS\|legendaryos-kernel\|7\.1' \
    | grep '^kernel=' \
    | head -1 \
    | cut -d= -f2 \
    | tr -d '"' || true)

if [[ -n "$LEGENDARYOS_KERNEL" ]]; then
    log "Znaleziono jądro: $LEGENDARYOS_KERNEL"
    grubby --set-default="$LEGENDARYOS_KERNEL"
    log "Ustawiono jako domyślne przez grubby."
else
    # Fallback: ustaw przez indeks (najnowszy wpis = 0)
    warn "Nie znaleziono jądra po nazwie — ustawiam indeks 0 (najnowszy wpis GRUB)."
    grubby --set-default-index=0
fi

# Zaktualizuj grub.cfg
if command -v grub2-mkconfig &>/dev/null; then
    log "Aktualizowanie grub.cfg..."
    if [[ -d /sys/firmware/efi ]]; then
        grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg 2>/dev/null \
            || grub2-mkconfig -o /boot/grub2/grub.cfg 2>/dev/null \
            || warn "grub2-mkconfig zakończył się błędem."
    else
        grub2-mkconfig -o /boot/grub2/grub.cfg 2>/dev/null \
            || warn "grub2-mkconfig zakończył się błędem."
    fi
    log "grub.cfg zaktualizowany."
fi

echo ""

# ════════════════════════════════════════════════════════════════════════════
# 6. Podsumowanie
# ════════════════════════════════════════════════════════════════════════════

log "════════════════════════════════════════"
log " Instalacja jądra LegendaryOS zakończona"
log "════════════════════════════════════════"
echo ""
log "Aktualnie ustawione domyślne jądro:"
grubby --default-kernel 2>/dev/null || warn "Nie można odczytać domyślnego jądra."
echo ""
log "Plik RPM zostanie usunięty z /tmp automatycznie."
log "Uruchom ponownie system, aby załadować nowe jądro."
