#!/usr/bin/env bash
# =============================================================================
# eParaksts atinstalācijas skripts
# Noņem tikai tos failus un paketes, ko uzstādīja install.sh.
# Sistēmas kritiskos failus un citas paketes neskar.
# Versija: 1.0
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

# --- Drošība: tikai root ar sudo, nevis tiešais root -------------------------
if [[ $EUID -eq 0 && -z "${SUDO_USER:-}" ]]; then
    die "Palaid kā root tiešā veidā nav atļauts. Izmanto: sudo bash $0"
fi
if ! sudo -n true 2>/dev/null; then
    warn "Skripts pieprasa sudo tiesības."
    sudo -v || die "Neizdevās iegūt sudo tiesības."
fi

# --- Versijas pārbaude -------------------------------------------------------
if [[ ${BASH_VERSINFO[0]} -lt 4 ]]; then
    die "Nepieciešams Bash 4+. Tava versija: $BASH_VERSION"
fi

# --- Žurnāls (mktemp — atomisks, 0600, novērš symlink uzbrukumus) -----------
LOGFILE=$(mktemp /tmp/eparaksts-uninstall-XXXXXX.log)
exec > >(tee -a "$LOGFILE") 2>&1
log "Žurnāls: $LOGFILE"

cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        error "Atinstalācija beidzās ar kļūdu (kods: $exit_code). Skati: $LOGFILE"
    fi
}
trap cleanup EXIT

# =============================================================================
# DROŠĪBAS PIEZĪME — kas tiek un kas NETIEK noņemts
# =============================================================================
# TIEK noņemts (tikai tas, ko uzstādīja install-eparaksts.sh):
#   • Paketes: eparakstitajs3, awp, latvia-eid-middleware,
#              eparaksts-token-signing, nautilus-sendto (dummy)
#   • APT repozitorijs: /etc/apt/sources.list.d/eparaksts.sources
#   • GPG atslēga: /usr/share/keyrings/eparaksts-apt-keyring.gpg
#   • udev noteikums: /etc/udev/rules.d/99-smartcard.rules
#   • systemd drop-in: /etc/systemd/system/pcscd.service.d/restart.conf
#
# NETIEK noņemts:
#   • pcscd, pcsc-tools, libpcsclite1 — sistēmas paketes, ko izmanto
#     citas lietotnes; noņem manuāli, ja esi pārliecināts
#   • plugdev grupas dalība — tā var būt nepieciešama citām ierīcēm
#   • Jebkādi faili ārpus iepriekš norādītajiem ceļiem
# =============================================================================

# =============================================================================
# APSTIPRINĀJUMA PIEPRASĪJUMS
# =============================================================================
section "Apstiprinājums"

echo ""
echo -e "${BOLD}Šis skripts noņems eParaksts no tavas sistēmas:${RESET}"
echo "  • Paketes: eparakstitajs3, awp, latvia-eid-middleware,"
echo "             eparaksts-token-signing, nautilus-sendto (dummy)"
echo "  • APT repozitorijs un GPG atslēga"
echo "  • udev noteikums viedkartes lasītājiem"
echo "  • systemd pcscd restart drop-in"
echo ""
echo -e "${YELLOW}pcscd, pcsc-tools un libpcsclite1 NETIKS noņemtas${RESET}"
echo "  (tās var izmantot citas sistēmas programmas)"
echo ""

# Automātisks režīms, ja padots --yes vai -y
AUTO_YES=false
for arg in "$@"; do
    [[ "$arg" == "--yes" || "$arg" == "-y" ]] && AUTO_YES=true
done

if [[ "$AUTO_YES" == false ]]; then
    read -r -p "Turpināt? [j/N] " CONFIRM
    case "${CONFIRM}" in
        j|J|y|Y) : ;;
        *) log "Atinstalācija atcelta."; exit 0 ;;
    esac
fi

# =============================================================================
# DROŠĪBAS IEROBEŽOJUMU SARAKSTS — ceļi, kurus drīkst dzēst
# =============================================================================
# Whitelist — tikai šie precīzie ceļi drīkst tikt noņemti.
# Nekāda glob-* paplašināšana, nekādi mainīgie no ārpuses.

readonly EPARAKSTS_PACKAGES=(
    eparakstitajs3
    awp
    latvia-eid-middleware
    eparaksts-token-signing
    nautilus-sendto
)

readonly EPARAKSTS_FILES=(
    /etc/apt/sources.list.d/eparaksts.sources
    /etc/apt/sources.list.d/eparaksts.list
    /usr/share/keyrings/eparaksts-apt-keyring.gpg
    /etc/udev/rules.d/99-smartcard.rules
    /etc/systemd/system/pcscd.service.d/restart.conf
)

# Direktorija, ko drīkst noņemt TIKAI ja ir tukša pēc faila dzēšanas
readonly PCSCD_OVERRIDE_DIR="/etc/systemd/system/pcscd.service.d"

# =============================================================================
# DROŠĪBAS PĀRBAUDE — validē katru ceļu pirms dzēšanas
# =============================================================================

# Pārbauda, vai ceļš ir absolūts un iekļauts whitelist
assert_safe_path() {
    local path="$1"

    # Jābūt absolūtam ceļam
    [[ "$path" == /* ]] || die "Drošības kļūda: '${path}' nav absolūts ceļš!"

    # Nedrīkst saturēt path traversal
    [[ "$path" != *".."* ]] || die "Drošības kļūda: path traversal '${path}'!"

    # Nedrīkst būt symlink (novērš uzbrukumus uz sistēmas failiem)
    if [[ -L "$path" ]]; then
        warn "Izlaižam '${path}' — ir symlink! Nedzēšam, lai izvairītos no symlink uzbrukuma."
        return 1
    fi

    # Ceļam jābūt whitelist
    local allowed=false
    for allowed_path in "${EPARAKSTS_FILES[@]}"; do
        [[ "$path" == "$allowed_path" ]] && allowed=true && break
    done
    [[ "$allowed" == true ]] || die "Drošības kļūda: '${path}' nav atļauto ceļu sarakstā!"

    return 0
}

# Pārbauda, vai pakete ir atļauto sarakstā
assert_safe_package() {
    local pkg="$1"
    local allowed=false
    for allowed_pkg in "${EPARAKSTS_PACKAGES[@]}"; do
        [[ "$pkg" == "$allowed_pkg" ]] && allowed=true && break
    done
    [[ "$allowed" == true ]] || die "Drošības kļūda: pakete '${pkg}' nav atļauto sarakstā!"
}

# =============================================================================
# 1. PAKOTNES
# =============================================================================
section "Pakotņu noņemšana"

for pkg in "${EPARAKSTS_PACKAGES[@]}"; do
    assert_safe_package "$pkg"
    if dpkg -s "$pkg" &>/dev/null; then
        log "Noņem: $pkg"
        # apt-get purge — droša noņemšana ar atkarību pārbaudi
        # --force-* NETIEK izmantots
        if ! sudo apt-get purge -y "$pkg" 2>/dev/null; then
            warn "apt-get purge neizdevās priekš '$pkg' — mēģina dpkg remove..."
            sudo dpkg --remove "$pkg" 2>/dev/null || \
                warn "Neizdevās noņemt '$pkg' (iespējams jau noņemts)."
        fi
        success "Noņemts: $pkg"
    else
        log "Nav instalēts: $pkg — izlaižam."
    fi
done

sudo apt-get autoremove -y --purge 2>/dev/null || true
sudo apt-get autoclean -y 2>/dev/null || true
success "Paketes noņemtas."

# =============================================================================
# 2. FAILU NOŅEMŠANA (tikai whitelist)
# =============================================================================
section "Konfigurācijas failu noņemšana"

for fpath in "${EPARAKSTS_FILES[@]}"; do
    if [[ -e "$fpath" ]]; then
        # Drošības pārbaude pirms katras dzēšanas
        if assert_safe_path "$fpath"; then
            log "Dzēš: $fpath"
            sudo rm -f "$fpath"
            success "Dzēsts: $fpath"
        fi
    else
        log "Nav atrasts: $fpath — izlaižam."
    fi
done

# Noņem pcscd override direktoriju TIKAI ja ir tukša
if [[ -d "$PCSCD_OVERRIDE_DIR" ]]; then
    if [[ -z "$(ls -A "$PCSCD_OVERRIDE_DIR" 2>/dev/null)" ]]; then
        log "Noņem tukšo direktoriju: $PCSCD_OVERRIDE_DIR"
        sudo rmdir "$PCSCD_OVERRIDE_DIR"
        success "Direktorijs noņemts: $PCSCD_OVERRIDE_DIR"
    else
        warn "Direktorijs '$PCSCD_OVERRIDE_DIR' nav tukšs — atstājam (satur citu konfigurāciju)."
    fi
fi

success "Faili noņemti."

# =============================================================================
# 3. APT ATJAUNINĀJUMS
# =============================================================================
section "APT atjaunināšana"

sudo apt-get update -qq 2>/dev/null || \
    warn "apt update neizdevās — var ignorēt."
success "APT saraksts atjaunināts."

# =============================================================================
# 4. UDEV NOTEIKUMU ATJAUNINĀŠANA
# =============================================================================
section "udev atjaunināšana"

sudo udevadm control --reload-rules 2>/dev/null || true
sudo udevadm trigger 2>/dev/null || true
success "udev noteikumi atjaunināti."

# =============================================================================
# 5. SYSTEMD ATJAUNINĀŠANA
# =============================================================================
section "systemd atjaunināšana"

sudo systemctl daemon-reload 2>/dev/null || true

# Pcscd pats par sevi paliek — to pārvalda sistēma, ne mūsu skripts.
# Ja pcscd bija iespējots pirms instalācijas, tas paliek iespējots.
# Ja vēlies arī pcscd noņemt, dari to manuāli:
#   sudo systemctl stop pcscd pcscd.socket
#   sudo systemctl disable pcscd pcscd.socket
#   sudo apt-get purge pcscd pcsc-tools libpcsclite1

success "systemd atjaunināts."

# =============================================================================
# 6. PĀRBAUDE
# =============================================================================
section "Pārbaude"

FAIL=0

for pkg in eparakstitajs3 awp latvia-eid-middleware eparaksts-token-signing; do
    if dpkg -s "$pkg" &>/dev/null; then
        error "Pakete vēl ir instalēta: $pkg"
        FAIL=1
    else
        success "Noņemts: $pkg ✔"
    fi
done

for fpath in \
    /etc/apt/sources.list.d/eparaksts.sources \
    /etc/apt/sources.list.d/eparaksts.list \
    /usr/share/keyrings/eparaksts-apt-keyring.gpg \
    /etc/udev/rules.d/99-smartcard.rules \
    /etc/systemd/system/pcscd.service.d/restart.conf; do
    if [[ -e "$fpath" ]]; then
        error "Fails vēl pastāv: $fpath"
        FAIL=1
    else
        success "Noņemts: $fpath ✔"
    fi
done

# =============================================================================
# 7. NOBEIGUMS
# =============================================================================
section "Atinstalācija pabeigta"

if [[ $FAIL -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}"
    echo "  ╔══════════════════════════════════════════════╗"
    echo "  ║   eParaksts noņemts veiksmīgi!              ║"
    echo "  ╚══════════════════════════════════════════════╝"
    echo -e "${RESET}"
else
    echo -e "${YELLOW}${BOLD}"
    echo "  ╔══════════════════════════════════════════════════╗"
    echo "  ║   Noņemts ar brīdinājumiem — skatiet žurnālu    ║"
    echo "  ╚══════════════════════════════════════════════════╝"
    echo -e "${RESET}"
fi

echo -e "${BOLD}Piezīmes:${RESET}"
echo "  • pcscd un pcsc-tools nav noņemtas (drošības apsvērumu dēļ)"
echo "    Lai noņemtu manuāli:"
echo "      sudo systemctl stop pcscd pcscd.socket"
echo "      sudo systemctl disable pcscd pcscd.socket"
echo "      sudo apt-get purge pcscd pcsc-tools libpcsclite1"
echo "  • plugdev grupas dalība nav mainīta"
echo "    Lai noņemtu manuāli: sudo gpasswd -d \$USER plugdev"
echo ""
echo "  Žurnāla fails: $LOGFILE"

exit $FAIL
