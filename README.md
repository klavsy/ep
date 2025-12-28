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

Here is the final, combined Markdown file. You can copy and paste this directly into your `README.md`.

```markdown
# ✍️ eParakstītājs 3.0 Installer

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

```

### 📝 2. variants: Manuāla uzstādīšana

Ja vēlies vispirms pārskatīt kodu:

1. **Lejupielādējiet skriptu:**
```bash
wget [https://klavsy.github.io/ep/install.sh](https://klavsy.github.io/ep/install.sh)

```

2. **Padari to izpildāmu:**
```bash
chmod +x install.sh

```


3. **Palaidiet:**
```bash
./install.sh

```

## 📦 Kas tiek uzstādīts?

Skripts uzstāda pilnu LVRTC programmatūras komplektu:

1. `eparakstitajs3` - Galvenā darbvirsmas lietotne dokumentu parakstīšanai.
2. `latvia-eid-middleware` - Starpprogrammatūra eID kartes lasīšanai.
3. `eparaksts-token-signing` - Spraudnis parakstīšanai pārlūkprogrammās.
4. `awp` - Papildu draiveri vecākām viedkartēm.

---

## ⚠️ Atruna / Disclaimer

**LV:**
Šis ir **neoficiāls** instalācijas skripts. Es neesmu saistīts ar šīs programmatūras izstrādātājiem, un viņi nav šo skriptu apstiprinājuši. Šis repozitorijs piedāvā skriptu, lai automatizētu instalācijas procesu Linux sistēmās.

**EN:**
This is an **unofficial** installation script. I am not affiliated with, endorsed by, or connected to the developers of this software. This repository simply provides a script to automate the installation process on Linux systems.

### Software Owner / Programmatūras īpašnieks

All rights regarding the software belong to / Visas tiesības uz programmatūru pieder:

**Valsts akciju sabiedrība “Latvijas Valsts radio un televīzijas centrs” (LVRTC)**

* **Reg. Nr:** 40003011203
* **Address / Adrese:** Zemitāna iela 9 k-3, Rīga, Latvija, LV-1012
* **Website / Vietne:** [eparaksts.lv](https://www.eparaksts.lv)

---

*Izveidots ar ❤️ Linux kopienai Latvijā.*

```

```

