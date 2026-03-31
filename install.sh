#!/bin/bash
set -e

echo "🧹 Sakopj sistēmu pirms instalācijas..."

sudo dpkg --remove --force-all eparakstitajs3 2>/dev/null || true
sudo apt --fix-broken install -y

echo "🛠️  Pārbauda rīkus..."
sudo apt update -qq
sudo apt install -y wget gpg ca-certificates coreutils

if [ -f /etc/os-release ]; then
    . /etc/os-release
fi

echo "🚀 Uzsāk eParaksts uzstādīšanu..."
echo "ℹ️  Noteiktā sistēma: $NAME ($VERSION_CODENAME)"

if [[ "$VERSION_CODENAME" =~ ^(faye|bookworm|trixie)$ ]] || [[ "$ID" = "kali" ]]; then
    echo "⚠️  Konstatēts Debian/LMDE. Pārslēdzas uz 'noble' saderības režīmu..."
    TARGET_CODENAME="noble"
elif [ -n "$UBUNTU_CODENAME" ]; then
    TARGET_CODENAME="$UBUNTU_CODENAME"
else
    TARGET_CODENAME="noble"
fi

sudo rm -f /etc/apt/sources.list.d/eparaksts.list

echo "🔑 Iegūst atslēgas..."
wget -qO- https://www.eparaksts.lv/files/ep3updates/debian/eparaksts-apt-public.asc | \
    sudo gpg --dearmor -o /usr/share/keyrings/eparaksts-apt-keyring.gpg

echo "📂 Pievieno repozitoriju ($TARGET_CODENAME)..."
sudo bash -c "cat > /etc/apt/sources.list.d/eparaksts.sources <<EOF
Types: deb
URIs: https://www.eparaksts.lv/files/ep3updates/debian
Suites: jammy noble
Components: eparaksts
Architectures: amd64
Signed-By: /usr/share/keyrings/eparaksts-apt-keyring.gpg
EOF"

sudo apt update

if ! dpkg -s nautilus-sendto >/dev/null 2>&1; then
    echo "🔧 Fiksē 'nautilus-sendto' trūkumu (LMDE/Debian fix)..."
    TEMP_DIR=$(mktemp -d)
    mkdir -p "$TEMP_DIR/DEBIAN"

    cat <<EOF > "$TEMP_DIR/DEBIAN/control"
Package: nautilus-sendto
Version: 99.0
Section: misc
Priority: optional
Architecture: all
Maintainer: eParaksts Script <script@localhost>
Description: Dummy package to satisfy eParakstitajs dependency
 This is a dummy package because Debian removed nautilus-sendto.
EOF

    dpkg-deb --build "$TEMP_DIR" "nautilus-sendto-dummy.deb"
    sudo dpkg -i nautilus-sendto-dummy.deb

    rm -rf "$TEMP_DIR" nautilus-sendto-dummy.deb
    echo "✅ Atkarība sakārtota."
else
    echo "✅ 'nautilus-sendto' jau ir sistēmā."
fi


echo "📦 Instalē eParaksts un middleware..."
sudo apt install -y eparakstitajs3 awp latvia-eid-middleware eparaksts-token-signing

echo "✅ DARĪTS! Neaizmirsti pievienot paplašinājumu (Chrome/Edge/Firefox)."
