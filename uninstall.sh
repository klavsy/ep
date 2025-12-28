#!/bin/bash
echo "🗑️  Sāk piespiedu tīrīšanu..."

# 1. Mēģina noņemt galvenās programmas (ignorējot kļūdas, ja tās nav)
sudo apt purge -y eparakstitajs3 awp latvia-eid-middleware eparaksts-token-signing || true

# 2. Mēģina noņemt mūsu 'dummy' paku
sudo dpkg -r nautilus-sendto || true

# 3. Ar spēku izdzēš repozitoriju failus
sudo rm -f /etc/apt/sources.list.d/eparaksts.list
sudo rm -f /usr/share/keyrings/eparaksts-keyring.gpg

# 4. Iztīra kešatmiņu
sudo apt autoremove -y
sudo apt update

echo "✅ Tīrīšana pabeigta. Sistēma ir tīra."
