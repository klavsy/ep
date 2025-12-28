# ✍️ eParakstītājs 3.0 uzstādītājs

![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)
![Bash](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)

> **Automatizēts risinājums eParaksta un eID programmatūras uzstādīšanai Linux vidē.**

Šis skripts vienkāršo oficiālo LVRTC uzstādīšanas procesu, automātiski konfigurējot repozitorijus, GPG atslēgas un nepieciešamās pakotnes. Tas īpaši risina saderības problēmas lietotājiem ar **LMDE (Linux Mint Debian Edition)** un **Debian**, kur oficiālā instrukcija bieži nedarbojas.

---

## ✨ Iespējas

| Funkcija | Apraksts |
| :--- | :--- |
| 🧠 **Gudrā OS noteikšana** | Automātiski nosaka jūsu Linux versiju un piemeklē pareizo konfigurāciju. |
| 🛠️ **Darbojas uz LMDE & Debian** | Nodrošina darbību uz **LMDE 6/7** un **Debian 12**, automātiski pieslēdzot saderīgos Ubuntu repozitorijus. |
| 🔒 **Moderna drošība** | Izmanto korekto `/usr/share/keyrings` metodi (aizstājot novecojušo `apt-key`). |
| 📦 **Pilnvērtīga pakotne** | Vienā piegājienā uzstāda programmu, eID starpprogrammatūru un pārlūka spraudņus. |

---

## 🐧 Atbalstītās sistēmas

Skripts ir testēts un apstiprināts darbībai uz šādām distribūcijām:

* ✅ **Ubuntu:** 22.04 LTS (Jammy), 24.04 LTS (Noble)
* ✅ **Linux Mint:** 21.x, 22.x
* ✅ **LMDE:** 6 (Faye), 7 (Gigi)
* ✅ **Debian:** 12 (Bookworm)

---

## 🚀 Kā uzstādīt

### ⚡ 1. variants: Ātrā uzstādīšana (Ieteicams)
Vienkārši atver termināli (`Ctrl+Alt+T`) un iekopē šo komandu un nospied ENTER:

```bash
curl -fsSL [https://klavsy.github.io/ep/install.sh
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
