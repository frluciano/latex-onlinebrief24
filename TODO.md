# TODO

## Offen ausserhalb des Repos


## Queued

## Für nächsten CTAN-Release

*(Alle Änderungen sind implementiert und bereit; Release folgt separat.)*

- [ ] Version-Datum in `onlinebrief24.cls` und `ctan/onlinebrief24-doc.tex` auf Release-Datum setzen — `sh scripts/bump-version.sh YYYY-MM-DD`
- [ ] `ctan/release-announcement.txt` erstellen — Zusammenfassung der Änderungen für CTAN
- [ ] CTAN-Paket bauen und validieren — `sh scripts/build-ctan.sh`
- [ ] Prepare CTAN Release Workflow auslösen — GitHub Actions

## Done

- [x] KOMA-Interna dokumentieren — ausführliche Kommentare vor `\opening` in `onlinebrief24.cls`
- [x] Ungenutzte Abhängigkeit `eso-pic` entfernen — aus `onlinebrief24.cls` entfernt
- [x] Font-Größen zentralisieren — `\@obb@returnaddressfontsz` / `\@obb@returnaddresslinesz` in `onlinebrief24.cls`
- [x] Fenster-Koordinaten als benannte Macros — `\@obb@picwindowx`, `\@obb@piczone1y`, `\@obb@piczone3y`, `\@obb@picfoldmarki`, `\@obb@picfoldmarkii` in `onlinebrief24.cls`
- [x] Farbschema-RGB-Werte kommentieren — moderncv-Palette-Herkunft in `onlinebrief24.cls` dokumentiert
- [x] Regressionstests für Guides-Modus — `tests/fixtures/guides-regression.tex`
- [x] Regressionstests für `footercenter`-Option — `tests/fixtures/footercenter-regression.tex`, Text-Check in `verify.sh`
- [x] ShellCheck in `scripts/check-tooling.sh` integriert — graceful fallback wenn nicht vorhanden
- [x] Guides-Modus-Beispiel in `examples/` — `examples/example-onlinebrief24-guides.tex`
- [x] CONTRIBUTING.md erstellt
- [x] GitHub Issue-Templates erstellt — `.github/ISSUE_TEMPLATE/bug_report.md` und `feature_request.md`
- [x] `\addfooteritem{icon}{text}` — Custom-Footer-Felder im modern-Stil (erweiterbar)
- [x] `\addinfoblockrow{label}{value}` — Custom-Infoblock-Zeilen (erweiterbar)
- [x] Öffentliche Layout-API — `\setinfoblocktopoffset`, `\setinfoblockrightedge`, `\setinfoblockcolwidths` in `onlinebrief24.cls`
- [x] Python-Validierungslogik extrahiert — `scripts/lib/release_validation.py` (3 Subcommands), `validate-release-inputs.sh` vereinfacht
- [x] CTAN-Doku erweitert — Guides-Abschnitt, Erweiterbarkeits-Abschnitt, neue Macros in API-Tabelle in `ctan/onlinebrief24-doc.tex`

