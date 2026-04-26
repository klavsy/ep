#!/usr/bin/env bash
# =============================================================================
# eParaksts uzstādīšanas skripts
# Atbalsta: Ubuntu (jammy/noble/resolute), Linux Mint, LMDE, Debian, Kali
# Versija: 2.2
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

# --- Krāsas un logošana -------------------------------------------------------
RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

log()     { echo -e "${CYAN}[•]${RESET} $*"; }
success() { echo -e "${GREEN}[✔]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[!]${RESET} $*"; }
error()   { echo -e "${RED}[✘]${RESET} $*" >&2; }
die()     { error "$*"; exit 1; }
section() { echo -e "\n${BOLD}══ $* ══${RESET}"; }

# =============================================================================
# CURL | BASH DROŠĪBA — main() 
# Bash parsē visu skriptu pirms izpildes tikai tad, ja viss kods ir funkcijā.
# Tas novērš daļējas izpildes risku, ja savienojums tiek pārtraukts lejupielādes
# laikā (curl | bash truncation attack).
# =============================================================================
main() {

# --- Drošība: tikai root ar sudo, nevis tiešais root -------------------------
if [[ $EUID -eq 0 && -z "${SUDO_USER:-}" ]]; then
    die "Palaist kā root tiešā veidā nav atļauts.\n  Palaid kā parasts lietotājs: curl -fsSL https://klavsy.github.io/ep/install.sh | bash"
fi
if ! sudo -n true 2>/dev/null; then
    warn "Skripts pieprasa sudo tiesības."
    sudo -v || die "Neizdevās iegūt sudo tiesības."
fi

# --- Reģistrēšana un kļūdu apstrāde ----------------------------------------
# mktemp izveido failu atomiski ar 0600 — novērš /tmp symlink uzbrukumus
LOGFILE=$(mktemp /tmp/eparaksts-install-XXXXXX.log)
exec > >(tee -a "$LOGFILE") 2>&1
log "Žurnāls: $LOGFILE"

cleanup() {
    local exit_code=$?
    [[ -n "${TEMP_DIR:-}" && -d "${TEMP_DIR:-}" ]] && rm -rf "$TEMP_DIR"
    if [[ $exit_code -ne 0 ]]; then
        error "Instalācija neizdevās (kods: $exit_code). Skati: $LOGFILE"
    fi
}
trap cleanup EXIT

# --- Versijas pārbaude -------------------------------------------------------
MIN_BASH_VERSION=4
if [[ ${BASH_VERSINFO[0]} -lt $MIN_BASH_VERSION ]]; then
    die "Nepieciešams Bash $MIN_BASH_VERSION+. Tava versija: $BASH_VERSION"
fi

# =============================================================================
# 1. OS NOTEIKŠANA
# =============================================================================
section "OS noteikšana"

[[ -f /etc/os-release ]] || die "/etc/os-release nav atrasts. Neatbalstīta sistēma."

# Drošā parsēšana — nevis 'source', kas izpildu failu kā bash kodu.
# Iegūst tikai nepieciešamās vērtības ar grep + sed, neizpildot neko citu.
_get_os_field() {
    grep -m1 "^${1}=" /etc/os-release 2>/dev/null \
        | sed -E 's/^[^=]+=//; s/^"//; s/"$//'
}

OS_ID=$(_get_os_field ID)
OS_ID_LIKE=$(_get_os_field ID_LIKE)
OS_NAME=$(_get_os_field NAME)
OS_NAME="${OS_NAME:-Nezināma}"
OS_CODENAME=$(_get_os_field VERSION_CODENAME)
UBUNTU_CODENAME=$(_get_os_field UBUNTU_CODENAME)

log "Sistēma: ${OS_NAME} | Kodvārds: ${OS_CODENAME:-nav}"

# Noteikt mērķa kodvārdu repozitorijam
case "${OS_CODENAME}" in
    jammy)   TARGET_CODENAME="jammy" ;;
    noble)   TARGET_CODENAME="noble" ;;
    resolute) TARGET_CODENAME="noble" ;; # Ubuntu 26.04 — izmanto noble bināros
    faye|bookworm|trixie|kali-rolling)
             warn "Konstatēts Debian/LMDE/Kali — izmanto 'noble' saderības režīmu."
             TARGET_CODENAME="noble" ;;
    *)
        if [[ -n "$UBUNTU_CODENAME" ]]; then
            TARGET_CODENAME="$UBUNTU_CODENAME"
            warn "Nezināms kodvārds, izmantojot Ubuntu kodvārdu: $TARGET_CODENAME"
        else
            TARGET_CODENAME="noble"
            warn "Nezināma sistēma '$OS_CODENAME' — noklusējuma režīms: noble"
        fi
        ;;
esac

success "Mērķa repozitorija kodvārds: $TARGET_CODENAME"

# =============================================================================
# 2. PAMATPRASĪBU PĀRBAUDE
# =============================================================================
section "Pamatprasību pārbaude"

check_arch() {
    local arch; arch=$(dpkg --print-architecture)
    [[ "$arch" == "amd64" ]] || die "Neatbalstīta arhitektūra: $arch (nepieciešama amd64)"
    success "Arhitektūra: amd64 ✔"
}

check_internet() {
    log "Pārbauda interneta savienojumu..."

    # 1. mēģinājums: HEAD pieprasījums (ātrs, bet dažiem serveriem bloķēts)
    if curl -fsSL --max-time 10 --head "https://www.eparaksts.lv" \
            -o /dev/null 2>/dev/null; then
        success "Interneta savienojums ✔"
        return 0
    fi

    # 2. mēģinājums: GET uz zināmu mazu failu (ja HEAD tiek bloķēts)
    if curl -fsSL --max-time 15 --range 0-0 \
            "https://www.eparaksts.lv/files/ep3updates/debian/eparaksts-apt-public.asc" \
            -o /dev/null 2>/dev/null; then
        success "Interneta savienojums ✔ (GET fallback)"
        return 0
    fi

    # 3. mēģinājums: tīkla pārbaude pret 1.1.1.1 (Cloudflare DNS)
    if curl -fsSL --max-time 10 --connect-timeout 8 \
            "https://1.1.1.1" -o /dev/null 2>/dev/null; then
        # Tīkls strādā, bet eparaksts.lv nav sasniedzams
        die "Tīkls darbojas, bet eparaksts.lv nav sasniedzams. Iespējams servera pārtraukums — mēģiniet vēlāk."
    fi

    # Nekas nedarbojas — nav interneta
    die "Nav interneta savienojuma. Pārbaudiet tīkla iestatījumus."
}

check_disk_space() {
    local needed=200  # MB
    local free; free=$(df /usr --output=avail -m | tail -1)
    if [[ $free -lt $needed ]]; then
        die "Nepietiek vietas diskā: ${free}MB pieejams, nepieciešami ${needed}MB."
    fi
    success "Diska vieta: ${free}MB pieejams ✔"
}

check_arch
check_internet
check_disk_space

# =============================================================================
# 3. ATKARĪBU INSTALĀCIJA
# =============================================================================
section "Pamatrīki"

sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends \
    wget curl gnupg ca-certificates coreutils apt-transport-https \
    lsb-release dpkg-dev pcscd pcsc-tools libpcsclite1

success "Pamatrīki uzstādīti."

# =============================================================================
# 4. VECO VERSIJU TĪRĪŠANA
# =============================================================================
section "Veco versiju tīrīšana"

for pkg in eparakstitajs3 latvia-eid-middleware eparaksts-token-signing awp; do
    if dpkg -s "$pkg" &>/dev/null; then
        log "Noņem veco paketi: $pkg"
        # Izmanto apt-get purge — tas droši apstrādā atkarības.
        # --force-all netiek izmantots, jo tas apiet dpkg drošības pārbaudes.
        if ! sudo apt-get purge -y "$pkg" 2>/dev/null; then
            warn "apt-get purge neizdevās priekš $pkg — pēdējā iespēja ar dpkg remove (bez force)..."
            sudo dpkg --remove "$pkg" 2>/dev/null || \
                warn "Neizdevās noņemt $pkg — turpina (iespējams, jau daļēji noņemts)."
        fi
    fi
done

# Noņem vecos repozitoriju ierakstus
sudo rm -f /etc/apt/sources.list.d/eparaksts.list \
           /etc/apt/sources.list.d/eparaksts.sources \
           /usr/share/keyrings/eparaksts-apt-keyring.gpg

sudo apt-get --fix-broken install -y -qq
success "Tīrīšana pabeigta."

# =============================================================================
# 5. GPG ATSLĒGA — DROŠĀ VEIDĀ
# =============================================================================
section "GPG atslēgas importēšana"

KEY_URL="https://www.eparaksts.lv/files/ep3updates/debian/eparaksts-apt-public.asc"
KEY_FILE="/usr/share/keyrings/eparaksts-apt-keyring.gpg"
KEY_TMP=$(mktemp /tmp/eparaksts-key-XXXXXX.asc)

# Zināmais eParaksts GPG atslēgas pirkstu nospiedums (verificēts no eparaksts.lv).
# Ja mainās, jāatjauno šeit — tas ir apzināts drošības lēmums.
EXPECTED_FINGERPRINT="8D38 5068 38D5 E7B0 93AC  2E05 4FB5 3DD4 98B7 5C23"

log "Lejupielādē GPG atslēgu..."
if ! curl -fsSL --max-time 30 --retry 3 --retry-delay 2 \
         -o "$KEY_TMP" "$KEY_URL"; then
    rm -f "$KEY_TMP"
    die "Neizdevās lejupielādēt GPG atslēgu no $KEY_URL"
fi

# Pārbauda ASCII armor formātu — cietais kļūdas iznākums, nevis brīdinājums
if ! grep -q "BEGIN PGP PUBLIC KEY" "$KEY_TMP"; then
    rm -f "$KEY_TMP"
    die "Lejupielādētais fails nav PGP ASCII armor atslēga. Iespējams MITM uzbrukums!"
fi

sudo gpg --batch --yes --dearmor -o "$KEY_FILE" "$KEY_TMP"
sudo chmod 644 "$KEY_FILE"
rm -f "$KEY_TMP"

# Verificē pirkstu nospiedumu — cietais kļūdas iznākums, ja neatbilst
log "Verificē GPG atslēgas pirkstu nospiedumu..."
ACTUAL_FINGERPRINT=$(sudo gpg --no-default-keyring --keyring "$KEY_FILE" \
    --fingerprint 2>/dev/null \
    | grep -A1 "^pub" | tail -1 | tr -d '[:space:]')
EXPECTED_CLEAN=$(echo "$EXPECTED_FINGERPRINT" | tr -d '[:space:]')

if [[ "$ACTUAL_FINGERPRINT" != "$EXPECTED_CLEAN" ]]; then
    sudo rm -f "$KEY_FILE"
    error "GPG pirkstu nospiedums NEATBILST!"
    error "  Gaidīts:  $EXPECTED_FINGERPRINT"
    error "  Saņemts:  $ACTUAL_FINGERPRINT"
    die "Atslēga noraidīta. Iespējams kompromitēts serveris vai MITM uzbrukums."
fi

success "GPG atslēga verificēta ✔  ($EXPECTED_FINGERPRINT)"

# =============================================================================
# 6. REPOZITORIJS
# =============================================================================
section "Repozitorija pievienošana"

REPO_FILE="/etc/apt/sources.list.d/eparaksts.sources"

sudo tee "$REPO_FILE" > /dev/null <<EOF
Types: deb
URIs: https://www.eparaksts.lv/files/ep3updates/debian
Suites: jammy noble
Components: eparaksts
Architectures: amd64
Signed-By: /usr/share/keyrings/eparaksts-apt-keyring.gpg
EOF

sudo chmod 644 "$REPO_FILE"
sudo apt-get update -qq || {
    warn "apt update ar eparaksts repozitoriju neizdevās — pārbauda savienojumu..."
    check_internet
    sudo apt-get update || die "apt update neizdevās."
}

success "Repozitorijs pievienots."

# =============================================================================
# 7. NAUTILUS-SENDTO DUMMY PAKETE (ja nepieciešams)
# =============================================================================
section "Atkarību labošana"

if ! dpkg -s nautilus-sendto &>/dev/null; then
    log "Izveido dummy 'nautilus-sendto' paketi..."
    TEMP_DIR=$(mktemp -d /tmp/dummy-pkg-XXXXXX)
    mkdir -p "$TEMP_DIR/DEBIAN"

    cat > "$TEMP_DIR/DEBIAN/control" <<EOF
Package: nautilus-sendto
Version: 99.0
Section: misc
Priority: optional
Architecture: all
Maintainer: eParaksts Script <noreply@localhost>
Description: Dummy package — aizstāj noņemto nautilus-sendto
 Šī ir aizstājpakete, lai apmierinātu eparakstitajs3 atkarību,
 jo Debian/LMDE sistēmās nautilus-sendto ir noņemts.
EOF

    dpkg-deb --build "$TEMP_DIR" "$TEMP_DIR/nautilus-sendto-dummy.deb" 2>/dev/null
    sudo dpkg -i "$TEMP_DIR/nautilus-sendto-dummy.deb"
    rm -rf "$TEMP_DIR"
    success "nautilus-sendto aizstājpakete uzstādīta."
else
    success "nautilus-sendto jau ir sistēmā."
fi

# =============================================================================
# 8. EPARAKSTS PAKOTNES
# =============================================================================
section "eParaksts instalācija"

PACKAGES=(eparakstitajs3 awp latvia-eid-middleware eparaksts-token-signing)

for pkg in "${PACKAGES[@]}"; do
    log "Instalē: $pkg"
    if ! sudo apt-get install -y "$pkg" 2>&1; then
        warn "Pakotni '$pkg' neizdevās — mēģina labot..."
        sudo apt-get --fix-broken install -y -qq
        sudo apt-get install -y "$pkg" || warn "Neizdevās instalēt $pkg — turpina."
    fi
done

success "Pakotnes instalētas."

# =============================================================================
# 9. PCSCD SERVISS — AUTOMĀTISKA STARTĒŠANA UN LABOŠANA
# =============================================================================
section "pcscd servisa konfigurācija"

enable_and_start_pcscd() {
    log "Iespējo un startē pcscd..."

    # Ielādē nepieciešamos kodola moduļus viedkartes lasītājiem
    for mod in usbserial usb_wwan ccid; do
        sudo modprobe "$mod" 2>/dev/null || true
    done

    # Iespējo un startē pakalpojumu
    sudo systemctl daemon-reload
    sudo systemctl enable pcscd.service pcscd.socket 2>/dev/null || true
    sudo systemctl enable pcscd.socket 2>/dev/null || true

    # Zaķu caurums: dažās sistēmās socket aktivizācija ir vēlamā metode
    if systemctl is-active --quiet pcscd.socket; then
        log "pcscd.socket jau aktīvs — palaiz arī pcscd.service..."
    fi

    sudo systemctl stop pcscd.service pcscd.socket 2>/dev/null || true
    sleep 1
    sudo systemctl start pcscd.socket
    sudo systemctl start pcscd.service

    sleep 2

    if systemctl is-active --quiet pcscd; then
        success "pcscd serviss darbojas ✔"
    else
        warn "pcscd neizdevās startēt automātiski — mēģina manuālo metodi..."
        # Palaiž pcscd, saglabā PID, reģistrē cleanup trap
        sudo pcscd --foreground --debug &
        PCSCD_FALLBACK_PID=$!
        trap 'cleanup; [[ -n "${PCSCD_FALLBACK_PID:-}" ]] && sudo kill "$PCSCD_FALLBACK_PID" 2>/dev/null || true' EXIT
        sleep 2
        if kill -0 "$PCSCD_FALLBACK_PID" 2>/dev/null; then
            success "pcscd palaists manuāli (PID: $PCSCD_FALLBACK_PID)."
            warn "Piezīme: šis pcscd process nav pārvaldīts ar systemd. Restartē sistēmu, lai aktivizētu pastāvīgo pakalpojumu."
        else
            error "pcscd neizdevās palaist. Pārbaudi: sudo journalctl -u pcscd"
        fi
    fi
}

# Pārbauda, vai pcscd ir instalēts
if ! command -v pcscd &>/dev/null; then
    log "pcscd nav atrasts — instalē..."
    sudo apt-get install -y pcscd pcsc-tools libpcsclite1
fi

# udev noteikums viedkartes lasītājiem (novērš atļauju problēmas)
UDEV_RULE='/etc/udev/rules.d/99-smartcard.rules'
if [[ ! -f "$UDEV_RULE" ]]; then
    log "Pievieno udev noteikumu viedkartes lasītājiem..."
    sudo tee "$UDEV_RULE" > /dev/null <<'EOF'
# eParaksts — viedkartes lasītāja piekļuves noteikums
# Aptver tikai CCID klases ierīces (bInterfaceClass 0x0b) — nevis visas USB ierīces.
# idVendor=="*" NETIEK izmantots — tas piešķirtu plugdev piekļuvi VISĀM USB ierīcēm.
SUBSYSTEM=="usb", ATTRS{bInterfaceClass}=="0b", GROUP="plugdev", MODE="0664"
EOF
    sudo udevadm control --reload-rules
    sudo udevadm trigger
fi

# Pievieno lietotāju plugdev grupai
if id -nG "$USER" | grep -qv plugdev; then
    sudo usermod -aG plugdev "$USER"
    warn "Lietotājs '$USER' pievienots plugdev grupai. Izlogojies un pieraksties no jauna, lai izmaiņas varētu stāties spēkā."
fi

enable_and_start_pcscd

# systemd vienība, kas nodrošina pcscd restartēšanu pēc sistēmas ieslēgšanas
SYSTEMD_OVERRIDE_DIR="/etc/systemd/system/pcscd.service.d"
sudo mkdir -p "$SYSTEMD_OVERRIDE_DIR"
sudo tee "$SYSTEMD_OVERRIDE_DIR/restart.conf" > /dev/null <<'EOF'
[Service]
Restart=on-failure
RestartSec=5
StartLimitIntervalSec=60
StartLimitBurst=5
EOF
sudo systemctl daemon-reload
success "pcscd automātiskās restartēšanas politika iestatīta."

# =============================================================================
# 10. PĀRBAUDE UN ATSKAITE
# =============================================================================
section "Instalācijas pārbaude"

FAIL=0

check_pkg() {
    if dpkg -s "$1" &>/dev/null; then
        success "Pakete instalēta: $1"
    else
        error "Pakete NAV instalēta: $1"
        FAIL=1
    fi
}

check_service() {
    if systemctl is-active --quiet "$1"; then
        success "Serviss aktīvs: $1"
    else
        warn "Serviss nav aktīvs: $1"
    fi
}

for pkg in eparakstitajs3 awp latvia-eid-middleware eparaksts-token-signing pcscd; do
    check_pkg "$pkg"
done

check_service pcscd
check_service pcscd.socket

# Pieejamais viedkartes lasītājs
if command -v pcsc_scan &>/dev/null; then
    log "Meklē viedkartes lasītājus (2 sekundes)..."
    timeout 3 pcsc_scan 2>/dev/null | head -5 || true
fi

# =============================================================================
# 11. NOBEIGUMS
# =============================================================================
section "Instalācija pabeigta"

if [[ $FAIL -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}"
    echo "  ╔══════════════════════════════════════════════╗"
    echo "  ║   eParaksts uzstādīts veiksmīgi!            ║"
    echo "  ╚══════════════════════════════════════════════╝"
    echo -e "${RESET}"
else
    echo -e "${YELLOW}${BOLD}"
    echo "  ╔══════════════════════════════════════════════════╗"
    echo "  ║   Uzstādīts ar brīdinājumiem — skati žurnālu  ║"
    echo "  ╚══════════════════════════════════════════════════╝"
    echo -e "${RESET}"
fi

echo -e "${BOLD}Nākamie soļi:${RESET}"
echo "  1. Pievieno paplašinājumu pārlūkam: Chrome / Edge / Brave / Vivaldi/ Firefox"
echo "     https://www.eparaksts.lv/lv/lejupielade"
echo "  2. Pievieno viedkartes lasītāju un ievieto karti"
echo "  3. Ja tikko pievienots plugdev — izlogojies un pieraksties no jauna"
echo ""
echo "  Žurnāla fails: $LOGFILE"
echo "  Uzstādīšana:  curl -fsSL https://klavsy.github.io/ep/install.sh | bash"
echo "  Vai lokāli:   sudo bash install-eparaksts.sh"

exit $FAIL

} # end main()

# Izsauc main tikai pēc tam, kad bash ir parsējis visu skriptu.
# Šī ir vienīgā izpildes ieejas vieta.
main "$@"
