# eParaksts - automātiskā uzstādīšana

Automātiska eParaksts Mobile uzstādīšana un noņemšana Debian bāzes sistēmām.

## Uzstādīšana

```bash
curl -fsSL https://klavsy.github.io/ep/install.sh | bash
```

## Noņemšana

```bash
curl -fsSL https://klavsy.github.io/ep/uninstall.sh | bash
```

---

## Atbalstītās sistēmas

| Sistēma | Versija |
|---|---|
| Ubuntu | 22.04 (jammy), 24.04 (noble), 26.04 (resolute) |
| Linux Mint | 21.x, 22.x (MATE / Cinnamon / Xfce) |
| Linux Mint Debian Edition (LMDE) | 5, 6 |
| Debian | 12 (bookworm), 13 (trixie) |
| Kali Linux | rolling |

---

## Iespējas

**Automātiska OS noteikšana**
Skripts pats atpazīst sistēmu (Ubuntu, Linux Mint, LMDE, Kali, Debian u.c.) un pieslēdz atbilstošāko repozitoriju — nekādas manuālas konfigurācijas nav nepieciešamas.

**Drošība un standarti**
Izmanto mūsdienīgu `signed-by` atslēgu pārvaldību (nevis novecojušo `apt-key`) un verificē GPG atslēgas pirkstu nospiedumu pret zināmu vērtību — neatbilstība aptur instalāciju.

**Debian 12 / LMDE 6 labojums**
Automātiski izveido un uzinstalē fiktīvu (dummy) pakotni `nautilus-sendto`, lai novērstu "unmet dependencies" kļūdu, kas bieži parādās jaunākajās Debian versijās.

**Tīra instalācija**
Pirms sākšanas iztīra iepriekšējos neveiksmīgos instalācijas mēģinājumus un bojātās pakotnes, lai nodrošinātu veiksmīgu rezultātu.

**Pilna komplektācija**
Vienā piegājienā uzstāda darbvirsmas lietotni, eID starpprogrammatūru (middleware), pcscd viedkartes pakalpojumu un pārlūkprogrammu parakstīšanas moduli.

---

## Drošības īpašības

- `main()` iesaiņojums — bash parsē visu skriptu pirms jebkādas izpildes; novērš daļējas izpildes risku ja savienojums tiek pārtraukts
- GPG pirkstu nospieduma verifikācija — neatbilstība aptur instalāciju
- Whitelist arhitektūra (atinstalētājā) — tiek dzēsti tikai precīzi norādīti faili
- Symlink aizsardzība — noraida symlink mērķus pirms dzēšanas
- Nav `source /etc/os-release` — parsēts droši ar `grep`/`sed`
- Nav `sudo -E` — lietotāja vide netiek nodota root kontekstam
- Nav `--force-all` — paketes tiek noņemtas ar `apt-get purge`
- `mktemp` visiem pagaidu failiem — atomiski, `0600`
- `set -euo pipefail` + `IFS` — pilna kļūdu apstrāde

---

## Ja nevēlies izmantot curl | bash

Droša alternatīva — lejupielādē, pārskati kodu, tad palaid:

```bash
# Uzstādīšana
curl -fsSL https://klavsy.github.io/ep/install.sh -o install.sh
less install.sh
bash install.sh

# Noņemšana
curl -fsSL https://klavsy.github.io/ep/uninstall.sh -o uninstall.sh
less uninstall.sh
bash uninstall.sh
```
