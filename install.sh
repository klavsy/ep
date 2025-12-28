#!/bin/bash
set -e

# --- 1. INTELIĢENTĀ OS NOTEIKŠANA ---
# Mērķis: Piespiest izmantot "noble" vai "jammy", jo eParaksts neatbalsta Debian nosaukumus.

if [ -f /etc/os-release ]; then
    . /etc/os-release
fi

echo "🚀 Uzsāk eParaksts uzstādīšanu..."
echo "ℹ️  Noteiktā sistēma: $NAME ($VERSION_CODENAME)"

# Loģika: Ja ir LMDE 7 (faye) vai Debian Bookworm, mēs "melojam" serverim, ka tas ir Ubuntu Noble.
if [ "$VERSION_CODENAME" = "faye" ] || [ "$VERSION_CODENAME" = "bookworm" ]; then
    echo "⚠️  Konstatēts LMDE 7 / Debian 12."
    echo "🔄 Pārslēdzas uz 'noble' (Ubuntu 24.04) saderības režīmu..."
    TARGET_CODENAME="noble"
elif [ -n "$UBUNTU_CODENAME" ]; then
    TARGET_CODENAME="$UBUNTU_CODENAME"
else
    # Fallback visiem citiem - mēģinām noble, jo tas ir jaunākais
    echo "⚠️  Nevarēja noteikt Ubuntu versiju. Pārslēdzas uz 'noble'..."
    TARGET_CODENAME="noble"
fi

echo "ℹ️  Mērķa repozitorijs: $TARGET_CODENAME"

# --- 2. NOTĪRA VECĀS VERSIJAS (Jau lietotājam bija neveiksmīgs mēģinājums) ---
if [ -f /etc/apt/sources.list.d/eparaksts.list ]; then
    echo "🧹 Dzēš veco repozitorija konfigurāciju..."
    sudo rm /etc/apt/sources.list.d/eparaksts.list
fi

# --- 3. LEJUPIELĀDES ATSLĒGA ---
echo "🔑 Notiek drošības atslēgas lejupielāde..."
wget -qO- https://www.eparaksts.lv/files/ep3updates/debian/public.key | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/eparaksts-keyring.gpg > /dev/null

# --- 4. PIEVIENO REPOZITORIJU ---
echo "📂 Pievieno repozitoriju ($TARGET_CODENAME)..."
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/eparaksts-keyring.gpg] https://www.eparaksts.lv/files/ep3updates/debian $TARGET_CODENAME eparaksts" | \
  sudo tee /etc/apt/sources.list.d/eparaksts.list > /dev/null

# --- 5. INSTALĒŠANA ---
echo "📦 Atjaunina sarakstus un uzstāda eParaksts..."
sudo apt update

# Mēģinām instalēt. Ja neizdodas atkarību dēļ, skripts apstāsies un parādīs kļūdu.
sudo apt install -y eparakstitajs3 awp latvia-eid-middleware eparaksts-token-signing

echo "✅ Uzstādīšana sekmīgi pabeigta! Vari aizvērt logu."
