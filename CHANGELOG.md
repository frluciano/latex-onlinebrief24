# Aenderungsprotokoll

Alle wesentlichen Aenderungen an `onlinebrief24` werden in dieser Datei dokumentiert.

Das Format orientiert sich an [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
und dieses Projekt nutzt Datumsversionen passend zu den CTAN-Releases (YYYY-MM-DD).

## [Unreleased]

## [2026-04-17]

### Hinzugefuegt
- Regression-Fixture fuer `\addfooteritem` (`tests/fixtures/addfooteritem-regression.tex`)
- Regression-Fixture fuer `\addinfoblockrow` inkl. Assertion, dass der Infoblock
  auch ohne eingebaute Felder erscheint (`tests/fixtures/addinfoblockrow-regression.tex`)
- Regression-Fixture fuer die Layout-Tuning-API `\setinfoblocktopoffset`,
  `\setinfoblockrightedge`, `\setinfoblockcolwidths` (`tests/fixtures/layout-tuning-regression.tex`)
- Regression-Fixture fuer die Kombination `modern + infoblock` mit farbigen Labels
  (`tests/fixtures/modern-infoblock-regression.tex`)
- Regression-Fixture fuer die 72-mm-Grenze der Ruecksendeadresse
  (`tests/fixtures/returnaddress-width-regression.tex`)

### Behoben
- Modern-Mode-Header-Breite korrigiert: `\parbox{\paperwidth-50mm}` ist keine
  gueltige LaTeX-Laengenrechnung; `\dimexpr\paperwidth-50mm\relax` berechnet
  die Breite korrekt mit 160 mm, sodass der Sendernamen-Block nicht mehr ueber
  den rechten Seitenrand laeuft (`onlinebrief24.cls`)
- CTAN-Dokumentation korrigiert: `\faXTwitter` (existiert in fontawesome5 nicht)
  durch `\faTwitter` ersetzt (`ctan/onlinebrief24-doc.tex`)
- `\addinfoblockrow` wird jetzt auch gerendert, wenn keines der eingebauten
  Infoblock-Felder gesetzt ist; die `\ifboolexpr`-Bedingung prueft nun auch
  `\@obb@extrainfoblockrows` (`onlinebrief24.cls`)
- `\addfooteritem` gibt jetzt eine `\ClassWarningNoLine` aus, wenn es ohne die
  `modern`-Option verwendet wird (`onlinebrief24.cls`)
- `\addinfoblockrow` renderte bei Literaltext-Werten den Wert doppelt und mit
  abgeschnittenem erstem Zeichen: `\ifdefempty{#2}` konsumierte das erste Token
  des Literal-Arguments ueber `\ifdefined`; Fix: Argument per `\protected@edef`
  in Hilfsmakro expandieren, dann erst testen (`onlinebrief24.cls`)

### Geaendert
- Fuenf kopierte Footer-Separator-Bloecke durch den gemeinsamen Helper
  `\@obb@renderfooterfield{icon}{value}` ersetzt (`onlinebrief24.cls`)
- Breiten-Messung der Ruecksendeadresse in `\@obb@measurereturnaddress`
  ausgelagert; Validierung und Rendering teilen sich dieselbe Implementierung (`onlinebrief24.cls`)
- Magic-Numbers fuer die Modern-Stil-Position durch benannte Konstanten
  `\@obb@picmodernx`, `\@obb@picheadery`, `\@obb@picfootery`, `\@obb@headermargin`,
  `\@obb@headerheight`, `\@obb@footerheight`, `\@obb@headerfontsize`, `\@obb@headerbaseline`
  ersetzt (`onlinebrief24.cls`)
- `\setfromname` gibt jetzt eine Deprecation-Warning aus und empfiehlt
  `\setfromfirstname` + `\setfromlastname` (`onlinebrief24.cls`)
- `\g@addto@macro` durch das dokumentierte `\gappto` (etoolbox) ersetzt
  (`onlinebrief24.cls`)

### Intern
- GitHub-Actions (`actions/checkout`, `actions/upload-artifact`) und
  `ctan-o-mat` auf unveraenderliche Commit-SHAs gepinnt; Release-Pipeline ist
  damit gegen kompromittierte Mutable-Tags geschuetzt
- Workflow-Eingaben in den Release-Workflows ueber `env:`-Variablen
  weitergeleitet statt direkt in Shell-Befehlszeilen interpoliert
- DIN-5008-Fenster-Geometrie als benannte Laengen-Konstanten (`\@obb@din*`)
  zentralisiert; die TikZ-Guides-Darstellung referenziert jetzt dieselben
  Konstanten wie der Picture-Modus, sodass beide Pfade nicht mehr
  auseinanderdriften koennen
- Kalibrierungs-Offset fuer Zone 3 (+1 mm unter DIN-Nominalwert) im
  Guides-Overlay korrigiert: Zone 2 endet jetzt bei 73 mm statt 72 mm,
  passend zur tatsaechlichen Empfaenger-Position im Picture-Modus
- Locale-Fixtures (`german`, `french`, `spanish`, `dutch`, `polish`) auf volle
  Feldabdeckung der italienischen Fixture erweitert: `\setplace`, `\setourref`,
  `\setourmessage`, `\setcontactname`, `\setcontactphone`, `\setcontactfax`
- Assertions fuer alle Locale-Fixtures um interne Referenz und Kontakt-E-Mail
  ergaenzt, sodass Regressionen in allen Sprachen erkannt werden
- Franzoesische Label-Assertion (`Vos references`) auf ASCII-sicheren Teilstring
  `rences` umgestellt, damit die Pruefung unter pdflatex+T1 robust ist
- Assertions fuer `footercenter`-Fixture um Telefon- und Festnetz-Felder ergaenzt
- Inhalts-Assertion fuer `guides`-Fixture ergaenzt (Betreff-Text)
- Drei neue Regressions-Fixtures: `modern-no-footercenter` (Modern-Modus ohne
  zentrierten Footer), `guides-infoblock` (Guides + Infoblock kombiniert),
  `basic-no-modern` (negativer Test: Footer-Email darf im Basic-Modus nicht
  im PDF erscheinen)

## [2026-03-27]

### Hinzugefuegt
- `\addfooteritem{icon}{text}` fuer zusaetzliche Footer-Eintraege im
  modernen Stil
- `\addinfoblockrow{label}{value}` fuer benutzerdefinierte Zusatzzeilen im
  DIN-nahen Informationsblock
- oeffentliche Layout-Makros `\setinfoblocktopoffset`,
  `\setinfoblockrightedge` und `\setinfoblockcolwidths` zur Feinjustierung des
  Informationsblocks aus dem Dokument heraus
- neues Beispiel `examples/example-onlinebrief24-guides.tex` fuer den
  technischen Guides-Modus
- `CONTRIBUTING.md` und GitHub-Issue-Templates fuer strukturierte Mitarbeit

### Behoben
- CI-Regression in den Overlay-Helfern behoben: ungueltige interne
  Makronamen und die versehentlich entfernte Abhaengigkeit `eso-pic` brechen
  den Klassen-Load nicht mehr
- eingebettete Python-Heredocs in den Release-Workflows entfernt; die
  Workflows `Prepare CTAN Release`, `Release CTAN` und `Sync GitHub Release`
  sind wieder shell-parsebar
- nicht-ASCII-Zeichen in Kommentaren und Guides-Beschriftungen durch
  ASCII-sichere Varianten ersetzt, damit Builds ueber alle unterstuetzten
  Engines robuster laufen
- Leerzeilen zwischen den lokalisierten `infoblock`-Label-Bloecken entfernt,
  damit beim Laden der Klasse keine stoerenden `\par`-Token entstehen
- Layout-Overflow in der CTAN-Dokumentation behoben: lange Befehlsnamen in
  Tabellen werden nun umgebrochen

### Entfernt
- `ngerman`-Infoblock-Labels entfernt; `lang=german` deckt beide Varianten ab

### Geaendert
- CTAN-Dokumentation erweitert: neuer Abschnitt zum Guides-Modus,
  Extensibility-Abschnitt und API-Dokumentation fuer die neuen Makros
- KOMA-Script-Interna rund um `\opening` sind nun im Klassenfile mit
  Begruendung sowie Risiko-/Mitigationshinweisen dokumentiert
- CTAN-Announcements werden kuenftig nur noch aus
  `ctan/release-announcement.txt` erzeugt; der bisherige Fallback aus
  gefilterten Commit-Subjects wurde entfernt
- `Prepare CTAN Release` scheitert jetzt absichtlich, wenn
  `ctan/release-announcement.txt` fehlt oder leer ist; Maskierung von Fehlern
  durch `|| true` wurde entfernt

### Intern
- Rueckadress-Fontgroessen als benannte Makros zentralisiert, um
  Duplikation im Klassenfile zu reduzieren
- DIN-5008-Fenster- und Overlay-Koordinaten als benannte interne Makros
  herausgezogen
- Herkunft der moderncv-Farbschema-RGB-Werte im Klassenfile kommentiert
- Regressionsabdeckung fuer Guides-Modus und `footercenter` erweitert
- automatisierte Inhaltsvalidierung auf alle lokalisierten Sprachen erweitert:
  `german`, `english`, `french`, `spanish`, `italian`, `dutch` und `polish`
  werden im CI-Pfad verifiziert
- `scripts/check-tooling.sh` integriert ShellCheck mit graceful fallback und
  prueft zusaetzlich die Python-Helfer auf Syntax
- Python-Validierungslogik in `scripts/lib/release_validation.py`
  ausgelagert; `get_zip_versions` konsolidiert die ZIP-Pruefung fuer alle
  Release-Skripte

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
