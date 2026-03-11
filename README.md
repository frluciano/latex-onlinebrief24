# onlinebrief24

LaTeX-Klasse für DIN-5008-Briefe im Layout von onlinebrief24.de.

> Dieses Repository ist ein Community-Projekt und steht in keiner offiziellen Verbindung zur letterei.de Postdienste GmbH. "Onlinebrief24" ist ein eingetragenes Markenzeichen der jeweiligen Rechteinhaber. Die Nutzung erfolgt auf eigenes Risiko; es gibt keine Garantie, dass ein erzeugtes PDF vom Dienstleister in jedem Fall akzeptiert oder unverändert verarbeitet wird.

Die Klasse basiert auf `scrlttr2` aus KOMA-Script und ist auf einen robusten, reproduzierbaren Workflow für deutsche Geschäftsbriefe ausgelegt.

## Status

- Verifizierter Standard-Workflow: `xelatex`
- `pdflatex` wird nicht unterstützt
- Mehrseitige Briefe sind abgesichert: Fensterbereich, Falzmarken und optionaler Modern-Header/Footer erscheinen nur auf Seite 1
- Pflichtfelder für den Fensterbereich werden beim Start eines Briefs validiert
- CI-Workflow und lokale Verifikation sind im Repository enthalten

## Funktionsumfang

- DIN-5008-Typ-B-Grundlayout mit kalibriertem Fensterbereich
- `basic`-Stil ohne Kopf- und Fußzeile
- `modern`-Stil mit Kopfzeile, Fußzeile und Farbschemata
- `guides`-Modus zur technischen Sichtprüfung von Zonen, Abständen und Falzmarken
- Option `footercenter` für zentrierte Fußzeile im `modern`-Stil
- Arial als bevorzugte Schrift mit Fallback auf `TeX Gyre Heros`

## Schnellstart

Für eigene Briefe gibt es zwei sinnvolle Wege:

1. Lege `onlinebrief24.cls` in dasselbe Verzeichnis wie deine `.tex`-Datei und nutze `\documentclass{onlinebrief24}`.
2. Installiere die Klasse in deinem lokalen `TEXMFHOME`, wenn du sie systemweit verwenden möchtest.

Minimales Beispiel:

```latex
\documentclass[basic]{onlinebrief24}

\setreturnaddress{Erika Mustermann, Blumenweg 1, 54321 Blumenstadt}
\setrecipient{
  Mustermann GmbH \& Co. KG \\
  Herrn Hans Mustermann \\
  Musterstr. 1 \\
  12345 Musterstadt
}
\setsubject{Betreff}
\setplace{Musterstadt}
\setdate{\today}

\begin{document}
\begin{letter}{}
\opening{Sehr geehrter Herr Mustermann,}

dies ist ein Beispielbrief.

\closing{Mit freundlichen Grüßen}
\end{letter}
\end{document}
```

Build:

```bash
xelatex brief.tex
```

## Installation

### Lokal im Projekt

Lege `onlinebrief24.cls` neben deine `.tex`-Datei. Das ist der einfachste und transparenteste Weg.

### Lokal im TeX-Baum

Wenn du die Klasse global verfügbar machen möchtest:

```bash
kpsewhich -var-value TEXMFHOME
mkdir -p "$(kpsewhich -var-value TEXMFHOME)/tex/latex/onlinebrief24"
cp onlinebrief24.cls "$(kpsewhich -var-value TEXMFHOME)/tex/latex/onlinebrief24/"
texhash
```

Danach kannst du `\documentclass{onlinebrief24}` aus beliebigen Projekten verwenden.

## Beispiele

Die Dateien im Verzeichnis `examples/` sind lauffähige Referenzen für die unterstützten Varianten:

- `example-basic.tex`: einfacher Brief ohne Kopf- und Fußzeile
- `example-guides.tex`: technischer Overlay-Modus
- `example-basic-guides.tex`: einfacher Brief plus Overlay
- `example-modern.tex`: moderner Stil mit Kontaktdaten
- `example-modern-blue.tex`: moderner Stil mit alternativem Farbschema
- `example-modern-guides.tex`: moderner Stil plus Overlay
- `example-multipage-regression.tex`: Mehrseiten-Regressionsfall

Visuelle Vorschau der beiden Varianten:

| Basic | Modern Blue |
| --- | --- |
| ![Preview of the basic letter style](docs/assets/example-basic.png) | ![Preview of the modern blue letter style](docs/assets/example-modern-blue.png) |

Hinweis: Die Beispiel-Dateien referenzieren die Klasse absichtlich relativ über `../onlinebrief24`, damit sie direkt aus dem Repository heraus gebaut werden können.

Beispiel-Build:

```bash
cd examples
xelatex example-basic.tex
```

## Verifikation

Die lokale Standardprüfung baut alle Beispiele mit XeLaTeX und prüft zusätzlich den Mehrseiten-Fall:

- kein Wiederholen der Rücksendezeile auf Seite 2
- kein Wiederholen des Empfängerblocks auf Seite 2
- normaler Textbeginn auf Seite 2 statt geerbtem Fenster-Offset

Ausführen:

```bash
sh scripts/verify.sh
```

Dafür werden lokal insbesondere `latexmk`, `xelatex` und `pdftotext` benötigt. Für GitHub Actions ist ein Workflow unter `.github/workflows/verify.yml` enthalten.

## Optionen

### Layout

| Option | Bedeutung |
| --- | --- |
| `basic` | Einfaches Layout ohne Kopf- und Fußzeile |
| `modern` | Moderner Stil mit Kopfzeile, Fußzeile und Akzentfarbe |
| `guides` | Technischer Overlay-Modus zur Layoutprüfung |
| `footercenter` | Zentriert die Fußzeile im `modern`-Stil |

### Farbschemata für `modern`

| Option | RGB |
| --- | --- |
| `grey` | `0.55, 0.55, 0.55` |
| `blue` | `0.22, 0.45, 0.70` |
| `orange` | `0.95, 0.55, 0.15` |
| `green` | `0.35, 0.70, 0.30` |
| `red` | `0.95, 0.20, 0.20` |
| `purple` | `0.50, 0.33, 0.80` |
| `burgundy` | `0.596, 0, 0` |
| `black` | `0, 0, 0` |

Beispiel:

```latex
\documentclass[modern, blue, footercenter]{onlinebrief24}
```

## Wichtige Befehle

### Pflichtangaben

- `\setreturnaddress{...}`: einzeilige Rücksendeadresse für Zone 1 im Fensterbereich; Pflichtfeld
- `\setrecipient{...}`: vollständiger Empfängerblock; Pflichtfeld

Alternativ kann der Empfänger auch an `\begin{letter}{...}` übergeben werden. Wenn `\setrecipient` bereits gesetzt ist, wird das Argument von `letter` ignoriert.

### Optionale Grundangaben

- `\setsubject{...}`: Betreff oberhalb der Anrede
- `\setdate{...}`: Datum; Standard ist `\today`
- `\setplace{...}`: Ort vor dem Datum

### Zusatzangaben für `modern`

- `\setfromfirstname{...}`
- `\setfromlastname{...}`
- `\setfromaddress{...}`
- `\setfromlandline{...}`
- `\setfromphone{...}`
- `\setfromemail{...}`
- `\setfromweb{...}`
- `\setfromlinkedin{...}`
- `\setfromname{...}`: Legacy-Fallback, wenn keine getrennten Vor-/Nachnamen gesetzt werden

## Kalibrierung

Die Klasse ist bewusst gegen die reale Onlinebrief24-Vorschau kalibriert, nicht nur gegen die nominellen Maßangaben der offiziellen Grafik. Praktisch bedeutet das:

- Die offizielle Maßgrafik nennt den Fensterstart nominell bei `49 mm`
- Die reale Vorschau liegt messbar etwa `1 mm` tiefer
- Die Klasse verwendet deshalb effektiv `50-52 / 52-72 / 72-92 mm`, weil das in der Vorschau besser mit dem automatisch eingedruckten Sendungsbereich zusammenpasst

## Bekannte Grenzen

- Der aktuell verifizierte Standard-Workflow ist `xelatex`
- `lualatex` ist prinzipiell vorgesehen, wird in diesem Repository derzeit aber nicht als Standardpfad getestet
- Die Klasse ist auf deutschsprachige Briefe zugeschnitten und lädt `babel` mit `ngerman`
- Für einen robusten Einsatz ist aktuell ein Brief pro Dokument der gehärtete Use Case
- Der `guides`-Modus ist ein Prüfwerkzeug und nicht für finale Produktions-PDFs gedacht

## Herkunft

- Basis: KOMA-Script `scrlttr2`
- Der moderne Stil ist an die [LaTeX-Briefvorlage von Jan Mattfeld](https://github.com/janmattfeld/latex-briefvorlage/tree/master) angelehnt
- Die Farbschemata orientieren sich an `moderncv`

## Lizenz

Das Projekt steht unter der LaTeX Project Public License (LPPL) 1.3c. Details stehen in [LICENSE](LICENSE).
