#!/bin/bash
set -e

# --- 1. INTELIĢENTĀ OS NOTEIKŠANA ---
# Ubuntu/Mint = noble, jammy, focal
# LMDE/Debian = bookworm, bullseye

# Load OS details
if [ -f /etc/os-release ]; then
    . /etc/os-release
fi

# Loģika, lai noteiktu pareizo repozitorija nosaukumu.
if [ -n "$UBUNTU_CODENAME" ]; then
    # Variants A: Ubuntu, Linux Mint, Pop!_OS
    TARGET_CODENAME="$UBUNTU_CODENAME"
elif [ -n "$DEBIAN_CODENAME" ]; then
    # Variants B: LMDE 6/7
    TARGET_CODENAME="$DEBIAN_CODENAME"
elif [ "$ID" = "debian" ] && [ -n "$VERSION_CODENAME" ]; then
    # Variants C: Tīrs Debian
    TARGET_CODENAME="$VERSION_CODENAME"
else
    # Variants D: Manuāla atkāpšanās vecākiem priekš LMDE / nezināmām distribūcijām
    DETECTED=$(lsb_release -cs)
    case $DETECTED in
        "faye")  TARGET_CODENAME="bookworm" ;; # LMDE 6
        "elsie") TARGET_CODENAME="bullseye" ;; # LMDE 5
        *)       TARGET_CODENAME="$DETECTED" ;; # Default
    esac
fi

echo "🚀 Uzsāk eParaksts uzstādīšanu..."
echo "ℹ️  Noteiktā sistēma: $NAME"
echo "ℹ️  Mērķa repozitorijs: $TARGET_CODENAME"

# --- 2. LEJUPIELĀDES ATSLĒGA ---
echo "🔑 Notiek drošības atslēgas lejupielāde..."
wget -qO- https://www.eparaksts.lv/files/ep3updates/debian/public.key | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/eparaksts-keyring.gpg > /dev/null

# --- 3. PIEVIENO REPOZITORIJU ---
echo "📂 Pievieno repozitoriju..."
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/eparaksts-keyring.gpg] https://www.eparaksts.lv/files/ep3updates/debian $TARGET_CODENAME eparaksts" | \
  sudo tee /etc/apt/sources.list.d/eparaksts.list > /dev/null

# --- 4. INSTALĒŠANA ---
echo "📦 Uzstāda eParaksts..."
sudo apt update
sudo apt install -y eparakstitajs3 awp latvia-eid-middleware eparaksts-token-signing

echo "✅ Uzstādīšana sekmīgi pabeigta! Vari aizvērt logu."
