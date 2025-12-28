#!/bin/bash
set -e

# --- 0. SAGATAVOŠANĀS ---
# Pārliecināmies, ka sistēmai ir rīki failu lejupielādei un atslēgu apstrādei.
echo "🛠️  Pārbauda nepieciešamos rīkus..."
sudo apt update -qq
# Pievienojam 'binutils', lai vēlāk varētu uzbūvēt viltus pakotni, ja vajadzēs.
sudo apt install -y wget gpg ca-certificates binutils

# --- 1. INTELIĢENTĀ OS NOTEIKŠANA ---
if [ -f /etc/os-release ]; then
    . /etc/os-release
fi

echo "🚀 Uzsāk eParaksts uzstādīšanu..."
echo "ℹ️  Noteiktā sistēma: $NAME ($VERSION_CODENAME)"

# LMDE 6 (faye), Debian 12 (bookworm), Debian 13 (trixie), Kali, u.c.
if [ "$VERSION_CODENAME" = "faye" ] || [ "$VERSION_CODENAME" = "bookworm" ] || [ "$VERSION_CODENAME" = "trixie" ] || [ "$ID" = "kali" ]; then
    echo "⚠️  Konstatēts Debian/LMDE. Pārslēdzas uz 'noble' (Ubuntu 24.04) saderības režīmu..."
    TARGET_CODENAME="noble"
elif [ -n "$UBUNTU_CODENAME" ]; then
    TARGET_CODENAME="$UBUNTU_CODENAME"
else
    echo "⚠️  Nevarēja noteikt Ubuntu versiju. Pārslēdzas uz 'noble'..."
    TARGET_CODENAME="noble"
fi

echo "ℹ️  Mērķa repozitorijs: $TARGET_CODENAME"

# --- 2. NOTĪRA VECĀS VERSIJAS ---
if [ -f /etc/apt/sources.list.d/eparaksts.list ]; then
    echo "🧹 Dzēš veco repozitorija konfigurāciju..."
    sudo rm /etc/apt/sources.list.d/eparaksts.list
fi

# --- 3. LEJUPIELĀDES ATSLĒGA ---
echo "🔑 Notiek drošības atslēgas lejupielāde..."
wget -q --show-progress -O- https://www.eparaksts.lv/files/ep3updates/debian/public.key | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/eparaksts-keyring.gpg > /dev/null

# --- 4. PIEVIENO REPOZITORIJU ---
echo "📂 Pievieno repozitoriju ($TARGET_CODENAME)..."
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/eparaksts-keyring.gpg] https://www.eparaksts.lv/files/ep3updates/debian $TARGET_CODENAME eparaksts" | \
  sudo tee /etc/apt/sources.list.d/eparaksts.list > /dev/null

echo "📦 Atjaunina sarakstus..."
sudo apt update

# --- 5. "NAUTILUS-SENDTO" LABOJUMS (Fix for LMDE 6 / Debian 12) ---
# Pārbauda, vai repozitorijos eksistē 'nautilus-sendto'. Ja nē, uztaisa viltus paku.
if ! apt-cache show nautilus-sendto > /dev/null 2>&1; then
    echo "🔧 Pamanīta LMDE/Debian problēma: trūkst 'nautilus-sendto'."
    echo "🔨 Ģenerē saderības (dummy) paku..."
    
    # Izveido pagaidu mapi
    mkdir -p ns-dummy/DEBIAN
    
    # Izveido kontroles failu
    cat <<EOF > ns-dummy/DEBIAN/control
Package: nautilus-sendto
Version: 99.0
Section: misc
Priority: optional
Architecture: all
Maintainer: eParaksts Script <script@localhost>
Description: Fake package for eParaksts compatibility
 This package satisfies the outdated dependency required by eParaksts on newer Debian systems.
EOF

    # Uzbūvē .deb failu
    dpkg-deb --build ns-dummy
    
    # Uzinstalē to
    echo "📥 Instalē saderības paku..."
    sudo dpkg -i ns-dummy.deb
    
    # Sakopj pēdas
    rm -rf ns-dummy ns-dummy.deb
    echo "✅ Saderības problēma novērsta."
else
    echo "✅ 'nautilus-sendto' ir pieejams, labojums nav nepieciešams."
fi

# --- 6. INSTALĒŠANA ---
echo "💿 Uzstāda eParaksts programmatūru..."
# -y karogs automātiski apstiprina instalāciju
sudo apt install -y eparakstitajs3 awp latvia-eid-middleware eparaksts-token-signing

echo "✅ Uzstādīšana sekmīgi pabeigta!"
echo "👉 Neaizmirsti uzinstalēt pārlūka paplašinājumu (Chrome/Edge/Firefox) manuāli!"
