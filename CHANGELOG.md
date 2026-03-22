# Aenderungsprotokoll

Alle wesentlichen Aenderungen an `onlinebrief24` werden in dieser Datei dokumentiert.

Das Format orientiert sich an [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
und dieses Projekt nutzt Datumsversionen passend zu den CTAN-Releases (YYYY-MM-DD).

## [Unreleased]

## [2026-03-22]

### Hinzugefuegt
- optionale Klassenoption `infoblock` fuer einen festen DIN-nahen
  Informationsblock oben rechts im Briefkopf
- neue Makros `\setyourref`, `\setyourmessage`, `\setourref`,
  `\setourmessage`, `\setcontactname`, `\setcontactphone`,
  `\setcontactfax` und `\setcontactemail` fuer den Informationsblock
- lokalisierte `infoblock`-Beschriftungen fuer `german`, `ngerman`,
  `english`, `french`, `spanish`, `italian`, `dutch` und `polish`
- neues Beispiel `example-onlinebrief24-infoblock.tex` samt PDF im CTAN-Paket
- Release-Bundle fuer CTAN mit ZIP, SHA256, `announcement-draft.txt` und
  `release-metadata.json`
- Dokumentation des manuellen Real-Release-Ablaufs in `ctan/RELEASE.md`
- separater Workflow `Sync GitHub Release`, der nach erfolgreichem
  CTAN-Release aus demselben validierten Bundle Tag und GitHub Release erzeugt

### Geaendert
- CTAN-Automation in die strikt getrennten Workflows `Prepare CTAN Release` und
  `Release CTAN` aufgeteilt
- CTAN-Publishing ist jetzt nur noch aus einem zuvor vorbereiteten Bundle
  moeglich und erfordert eine explizite Freigabe im GitHub-Environment
  `ctan-release`
- Tag-Pushes loesen keinen CTAN-Publish mehr aus
- GitHub-Releases werden jetzt aus dem erfolgreichen `Release CTAN`-Lauf
  nachgelagert synchronisiert, statt losgeloest davon gepflegt zu werden
- das CTAN-Paket wurde auf zwei fokussierte Beispielbriefe reduziert:
  `example-onlinebrief24-infoblock` und `example-onlinebrief24-modern`
- die fokussierten CTAN-Beispiele wurden auf englische Musterdaten umgestellt
- der CTAN-Announcement-Draft kann nun explizit aus
  `ctan/release-announcement.txt` kommen; sonst wird ein gefilterter Draft aus
  releaserelevanten Commit-Subjects erzeugt
- Release-relevante GitHub-Workflows schreiben jetzt sichtbare Step Summaries
  mit Bundle-, Commit- und Run-Zuordnung

### Intern
- Release-Workflow validiert Prepare-Run-Provenance, Bundle, Checksumme und
  Announcement-Draft vor dem Publish erneut
- CTAN-Credentials sind auf den `publish-to-ctan`-Job im geschuetzten
  Environment `ctan-release` begrenzt
- der GitHub-Release-Sync ist separat retrybar und loest niemals einen zweiten
  CTAN-Submit aus
- `scripts/verify.sh` prueft den neuen Informationsblock engine-robust ueber
  normalisierten PDF-Text fuer XeLaTeX, LuaLaTeX und pdfLaTeX
- `scripts/verify.sh` enthaelt jetzt einen italienischen Regressionsfall fuer
  kompakte lokalisierte `infoblock`-Beschriftungen

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
- Footer im modernen Stil naeher an den unteren Seitenrand gesetzt; die
  README-Vorschau fuer `modern-blue` wurde entsprechend aktualisiert
- Markenname des Zieldienstes in README, CTAN-Dokumentation und
  Release-Metadaten konsistent als `onlinebrief24.de` geschrieben

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
