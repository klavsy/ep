#!/bin/bash
set -e

# --- 0. SAKOPŠANA (KRITISKS LABOJUMS) ---
echo "🧹 Sakopj sistēmu pirms instalācijas..."
# Noņemam eparakstu, ja tas ir palicis 'pus-uzinstalēts' un bloķē sistēmu
sudo dpkg --remove --force-all eparakstitajs3 2>/dev/null || true
sudo apt --fix-broken install -y

# --- 1. SAGATAVOŠANĀS ---
echo "🛠️  Pārbauda rīkus..."
sudo apt update -qq
sudo apt install -y wget gpg ca-certificates coreutils

# --- 2. INTELIĢENTĀ OS NOTEIKŠANA ---
if [ -f /etc/os-release ]; then
    . /etc/os-release
fi

echo "🚀 Uzsāk eParaksts uzstādīšanu..."
echo "ℹ️  Noteiktā sistēma: $NAME ($VERSION_CODENAME)"

if [ "$VERSION_CODENAME" = "faye" ] || [ "$VERSION_CODENAME" = "bookworm" ] || [ "$VERSION_CODENAME" = "trixie" ] || [ "$ID" = "kali" ]; then
    echo "⚠️  Konstatēts Debian/LMDE. Pārslēdzas uz 'noble' (Ubuntu 24.04) saderības režīmu..."
    TARGET_CODENAME="noble"
elif [ -n "$UBUNTU_CODENAME" ]; then
    TARGET_CODENAME="$UBUNTU_CODENAME"
else
    TARGET_CODENAME="noble"
fi

# --- 3. REPOZITORIJA IESTATĪŠANA ---
if [ -f /etc/apt/sources.list.d/eparaksts.list ]; then
    sudo rm /etc/apt/sources.list.d/eparaksts.list
fi

echo "🔑 Iegūst atslēgas..."
wget -q -O- https://www.eparaksts.lv/files/ep3updates/debian/public.key | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/eparaksts-keyring.gpg > /dev/null

echo "📂 Pievieno repozitoriju ($TARGET_CODENAME)..."
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/eparaksts-keyring.gpg] https://www.eparaksts.lv/files/ep3updates/debian $TARGET_CODENAME eparaksts" | \
  sudo tee /etc/apt/sources.list.d/eparaksts.list > /dev/null

sudo apt update

# --- 4. "NAUTILUS-SENDTO" BRUTE FORCE FIX ---
# Mēs vairs nejautājam "vai vajag?". Mēs pārbaudām, vai ir, un ja nav - uzliekam.
if ! dpkg -s nautilus-sendto >/dev/null 2>&1; then
    echo "🔧 Fiksē 'nautilus-sendto' trūkumu (LMDE/Debian fix)..."
    
    # Izveidojam darba mapi
    TEMP_DIR=$(mktemp -d)
    mkdir -p "$TEMP_DIR/DEBIAN"
    
    # Ģenerējam kontroles failu
    cat <<EOF > "$TEMP_DIR/DEBIAN/control"
Package: nautilus-sendto
Version: 99.0
Section: misc
Priority: optional
Architecture: all
Maintainer: eParaksts Script <script@localhost>
Description: Fake package to satisfy eParakstitajs dependency
 This is a dummy package because Debian 12 removed nautilus-sendto.
EOF

    # Uzbūvējam .deb failu
    dpkg-deb --build "$TEMP_DIR" "nautilus-sendto-dummy.deb"
    
    # Instalējam to ar dpkg (apejot apt repozitorijus)
    echo "📥 Instalē dummy paku..."
    sudo dpkg -i nautilus-sendto-dummy.deb
    
    # Tīrām
    rm -rf "$TEMP_DIR" nautilus-sendto-dummy.deb
    echo "✅ Atkarība sakārtota."
else
    echo "✅ 'nautilus-sendto' jau ir sistēmā."
fi

# --- 5. FINĀLA INSTALĀCIJA ---
echo "📦 Instalē eParaksts..."
sudo apt install -y eparakstitajs3 awp latvia-eid-middleware eparaksts-token-signing

echo "✅ DARĪTS! Neaizmirsti pievienot paplašinājumu (Chrome/Edge/Firefox). Vari aizvērt šo logu!"
