# ✍️ eParakstītājs 3.0 Installer

![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)
![Bash](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)

> **Automatizēts risinājums eParaksta un eID programmatūras uzstādīšanai Linux vidē.**

Šis skripts vienkāršo oficiālo LVRTC uzstādīšanas procesu, automātiski konfigurējot repozitorijus, GPG atslēgas un nepieciešamās pakotnes. Tas īpaši risina saderības problēmas lietotājiem ar **LMDE** un **Debian**, kur oficiālā instrukcija bieži nedarbojas.

---

## ✨ Iespējas

| Funkcija | Apraksts |
| :--- | :--- |
| 🧠 **Vieda OS noteikšana** | Automātiski nosaka jūsu Linux versiju un piemeklē pareizo konfigurāciju. |
| 🛠️ **LMDE & Debian Salabošana** | Nodrošina darbību uz **LMDE 6/7** un **Debian 12**, automātiski pieslēdzot saderīgos Ubuntu repozitorijus. |
| 🔒 **Moderna drošība** | Izmanto korekto `/usr/share/keyrings` metodi (aizstājot novecojušo `apt-key`). |
| 📦 **Pilna pakotne** | Vienā piegājienā uzstāda programmu, eID starpprogrammatūru un pārlūka spraudņus. |

---

## 🐧 Atbalstītās Sistēmas

Skripts ir testēts un apstiprināts darbībai uz šādām distribūcijām:

* ✅ **Ubuntu:** 22.04 LTS (Jammy), 24.04 LTS (Noble)
* ✅ **Linux Mint:** 21.x, 22.x
* ✅ **LMDE:** 6 (Faye), 7 (Gigi)
* ✅ **Debian:** 12 (Bookworm)

---

## 🚀 Kā uzstādīt

### ⚡ 1. variants: Ātrā uzstādīšana (Ieteicams)
Vienkārši atveriet termināli (`Ctrl+Alt+T`) un iekopējiet šo komandu:

```bash
curl -fsSL [https://klavsy.github.io/ep/install.sh](https://klavsy.github.io/ep/install.sh) | bash
