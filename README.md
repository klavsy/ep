# ✍️ eParakstītājs 3.0 uzstādītājs

![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)
![Bash](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)

> **Automatizēts risinājums eParaksta un eID programmatūras uzstādīšanai Linux vidē.**

Šis skripts vienkāršo oficiālo LVRTC uzstādīšanas procesu, automātiski konfigurējot repozitorijus, GPG atslēgas un nepieciešamās pakotnes priekš Ubuntu, Linux Mint un Debian. Tas īpaši risina saderības problēmas lietotājiem ar **LMDE (Linux Mint Debian Edition)** un **Debian**, kur oficiālā instrukcija bieži nedarbojas.

---

## ✨ Iespējas

| Funkcija | Apraksts |
| :--- | :--- |
| **🕵️‍♂️ Automātiska OS noteikšana** | Skripts pats atpazīst sistēmu (Ubuntu, Linux Mint, LMDE, Kali, Debian Trixie u.c.) un pieslēdz atbilstošāko Ubuntu repozitoriju. |
| **🛡️ Drošība un standarti** | Izmanto mūsdienīgu `signed-by` atslēgu pārvaldību (nevis novecojušo un nedrošo `apt-key`), garantējot, ka visi faili tiek verificēti pret oficiālajiem LVRTC serveriem. |
| **🛠️ Debian 12 / LMDE 6 Labojums** | Automātiski izveido un uzinstalē "fiktīvu" (dummy) pakotni priekš `nautilus-sendto`, lai novērstu "unmet dependencies" kļūdu, kas bieži sastopama jaunākajās Debian versijās. |
| **🧹 Tīra instalācija** | Pirms sākšanas iztīra iepriekšējos neveiksmīgos instalācijas mēģinājumus un bojātās pakotnes, lai nodrošinātu veiksmīgu rezultātu. |
| **📦 Pilna komplektācija** | Vienā piegājienā uzstāda gan darbvirsmas lietotni, gan eID starpprogrammatūru (middleware), gan pārlūkprogrammu parakstīšanas moduli. 
Drošības īpašības

main() iesaiņojums — bash parsē visu skriptu pirms jebkādas izpildes; novērš daļējas izpildes risku ja savienojums tiek pārtraukts
GPG pirkstu nospieduma verifikācija — atslēga tiek pārbaudīta pret zināmu hash; neatbilstība aptur instalāciju
Whitelist arhitektūra (atinstalētājā) — tiek dzēsti tikai precīzi norādīti faili
Symlink aizsardzība — noraida symlink mērķus pirms dzēšanas
Nav source — /etc/os-release tiek parsēts droši ar grep/sed
Nav sudo -E — lietotāja vide netiek nodota root kontekstam
Nav --force-all — paketes tiek noņemtas ar apt-get purge
mktemp — visi pagaidu faili tiek veidoti atomiski ar 0600
set -euo pipefail + IFS — pilna kļūdu apstrāde

|

## 🐧 Atbalstītās sistēmas

Skripts ir testēts un apstiprināts darbībai uz šādām distribūcijām:

* ✅ **Ubuntu:** 22.04 LTS (Jammy), 24.04 LTS (Noble)
* ✅ **Linux Mint:** 21.x, 22.x
* ✅ **LMDE:** 6 (Faye), 7 (Gigi)
* ✅ **Debian:** 12 (Bookworm)

---

## 🚀 Kā uzstādīt?

### ⚡ Ātrā uzstādīšana
Vienkārši atver termināli (`Ctrl+Alt+T`) un iekopē šo komandu un nospied ENTER:

```bash
curl -fsSL https://klavsy.github.io/ep/install.sh | bash

Lai noņemtu programmau izpildi komandu terminālī:

curl -fsSL https://klavsy.github.io/ep/uninstall.sh | bash
```

## 📦 Kas tiek uzstādīts?

Skripts uzstāda pilnu LVRTC programmatūras komplektu:

* **`eparakstitajs3`** – Galvenā darbvirsmas lietotne dokumentu parakstīšanai.
* **`latvia-eid-middleware`** – Starpprogrammatūra eID kartes lasīšanai.
* **`eparaksts-token-signing`** – Spraudnis parakstīšanai pārlūkprogrammās.
* **`awp`** – Papildu draiveri vecākām viedkartēm.

---

## ⚠️ Atruna / Disclaimer

**LV:**
> Šis ir **neoficiāls** instalācijas skripts. Es neesmu saistīts ar šīs programmatūras izstrādātājiem, un viņi nav šo skriptu apstiprinājuši. Šis repozitorijs piedāvā skriptu, lai automatizētu instalācijas procesu Linux sistēmās.

**EN:**
> This is an **unofficial** installation script. I am not affiliated with, endorsed by, or connected to the developers of this software. This repository simply provides a script to automate the installation process on Linux systems.

### 🏢 Software Owner / Programmatūras īpašnieks

All rights regarding the software belong to / Visas tiesības uz programmatūru pieder:

**Valsts akciju sabiedrība “Latvijas Valsts radio un televīzijas centrs” (LVRTC)**

* **Reg. Nr:** 40003011203
* **Address / Adrese:** Zemitāna iela 9 k-3, Rīga, Latvija, LV-1012
* **Website / Vietne:** [eparaksts.lv](https://www.eparaksts.lv)

---
*Izveidots ar ❤️ Linux kopienai Latvijā.*
