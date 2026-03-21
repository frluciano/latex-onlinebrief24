# Aenderungsprotokoll

Alle wesentlichen Aenderungen an `onlinebrief24` werden in dieser Datei dokumentiert.

Das Format orientiert sich an [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
und dieses Projekt nutzt Datumsversionen passend zu den CTAN-Releases (YYYY-MM-DD).

## [2026-03-21]

### Hinzugefuegt
- `\encl{...}` in README.md und CTAN-Dokumentation als standardmaessiger
  KOMA-Script-Befehl fuer Anlagen unterhalb der Grussformel dokumentiert
- Beispiel-PDFs (`basic`, `modern`) werden nun gebaut und ins CTAN-Paket
  aufgenommen, damit Nutzer die Ausgabe ohne lokalen Build ansehen koennen

### Geaendert
- Standard-Babelsprache von `ngerman` auf `german` umgestellt, fuer bessere
  Kompatibilitaet mit aktuellen Babel-Versionen
- Alle Beispiel-Dateien auf das Praefix `example-onlinebrief24-*` umbenannt,
  passend zu den CTAN-Namenskonventionen
- `marvosym` fuer Footer-Icons im modernen Stil durch `fontawesome5` ersetzt;
  `\faPhone`, `\faMobile`, `\faEnvelope`, `\faGlobe`, `\faLinkedin` ersetzen
  die entsprechenden `marvosym`-Symbole
- Toter `\ifPDFTeX`-Zweig beim Laden der Modern-Stil-Pakete entfernt; beide
  Zweige luden `sourcesanspro` identisch
- CTAN-README um Maintainer-Namen und Kontakt-URLs erweitert

### Intern
- `verify.sh` prueft Signatur-Regression und moderne Beispiel-PDFs jetzt
  inhaltlich per `pdftotext`, nicht nur auf erfolgreichen Build
- Branch-Protection fuer `main` eingerichtet; Aenderungen laufen jetzt ueber
  Pull Requests mit Pflicht-Checks statt ueber Direkt-Commits

## [2026-03-20]

### Behoben
- `\closing` wird nun konsistent linksbuendig gesetzt, auch wenn ueber
  KOMA-Variablen eine laengere `signature` hinterlegt ist

## [2026-03-11]

### Hinzugefuegt
- pdfLaTeX-Unterstuetzung ueber engine-abhaengiges Font-Loading
  (`fontenc`/`tgheros` als Fallback)
- Konfigurierbare Dokumentsprache (`lang=<babel name>` als Klassenoption,
  Standard: `german`)
- pdfLaTeX als dritte Engine in der CI-Verifikationsmatrix

### Geaendert
- Datumsversionierung ersetzt Semver in `\ProvidesClass`, im CHANGELOG und in
  release-relevanten Versionsreferenzen
- Alle `\DeclareOption` vor `\ProcessOptions` verschoben, fuer korrekte
  Optionsverarbeitung
- CI-Workflow in `Build LaTeX Verification` umbenannt
- CTAN-Dokumentation fuer pdfLaTeX-Unterstuetzung, `lang=` und Installation via
  `tlmgr` aktualisiert

### Intern
- CTAN-ZIP-Artefakte enthalten nun das Release-Datum im Archivnamen
- `bump-version.sh` akzeptiert jetzt `YYYY-MM-DD` und aktualisiert Klasse und
  Doku-Dateien gemeinsam

## [2026-03-10]

Erstes CTAN-Release.

### Hinzugefuegt
- DIN-5008-Typ-B-Briefklasse auf Basis von KOMA-Script `scrlttr2`
- Guides-Modus mit technischem Overlay: Adressfenster-Zonen, Falzmarken,
  Bemaassung und Textbeginn-Linie
- `modern`-Option mit Kopf- und Fusszeile (Telefon, E-Mail, Web, LinkedIn)
- 8 Farbschemata angelehnt an moderncv: grey, blue, orange, green, red,
  purple, burgundy, black
- `footercenter`-Option fuer zentrierte Fusszeilen-Ausrichtung
- `basic`-Option als expliziter Default-Stil
- Mehrseiten-Haertung: Overlays werden nur auf Seite 1 gerendert
- Regressionstest, der prueft, dass auf Seite 2 keine Overlay-Inhalte leaken
- Verifizierte LuaLaTeX-Unterstuetzung mit reproduzierbarem Font-Caching
- CI-Workflow `Build LaTeX Verification` mit Zwei-Engine-Matrix
  (XeLaTeX + LuaLaTeX)
- CI-Workflow `Build CTAN Package` fuer automatischen Artefakt-Build mit
  SHA256-Pruefsumme
- CTAN-Submission-Workflow in `ctan/RELEASE.md` dokumentiert
- Englische CTAN-Dokumentation (`ctan/onlinebrief24-doc.tex`)
- Pflichtfeld-Validierung: Rueckadresse und Empfaenger muessen gesetzt sein
- Font-Fallback: Arial bevorzugt, TeX Gyre Heros als Ersatz
- Projektstruktur mit LICENSE (LPPL 1.3c), README und `.gitignore`

### Behoben
- Guides: Beschriftungen der Falzmarken vertikal am Linienende positioniert
- Doppelte Datumsanzeige in der Ausgabe entfernt
- Datumsformat und Datumsposition korrigiert
- Unterstreichung in Zone 1: TikZ-Pfad durch einfaches `\rule` ersetzt
- Scoping-Probleme der Fusszeile ueber alle Farbschemata hinweg behoben

### Geaendert
- Adressfenster und Guides um 1 mm nach unten kalibriert, passend zum
  Preview von onlinebrief24.de

### Entfernt
- Ungenutzte `.doc`-Vorlage aus den Ressourcen
- Altes Spezifikationsdokument
- Kompilierte PDFs aus dem `examples`-Verzeichnis
