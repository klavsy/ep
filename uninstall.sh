#!/bin/bash
set -e

echo "🗑️ Sāk eParaksts noņemšanu..."

# 1. Noņem programmas un konfigurācijas failus (purge)
sudo apt purge -y eparakstitajs3 awp latvia-eid-middleware eparaksts-token-signing

# 2. Mēģina noņemt dummy paku, ja tāda tika uzlikta (ignorē kļūdu, ja nav)
sudo dpkg -r nautilus-sendto 2>/dev/null || true

# 3. Izdzēš repozitoriju un atslēgas
echo "🧹 Tīra sistēmas failus..."
sudo rm -f /etc/apt/sources.list.d/eparaksts.list
sudo rm -f /usr/share/keyrings/eparaksts-keyring.gpg

# 4. Iztīra liekās atkarības
echo "🛁 Palaiž autoremove..."
sudo apt autoremove -y
sudo apt update

echo "✅ Programmatūra ir pilnībā noņemta!"
echo "ℹ️  Pārlūkprogrammas paplašinājumi (Extensions) jāizdzēš manuāli no pārlūka."
