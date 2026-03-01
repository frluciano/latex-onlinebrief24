# LaTeX-Klasse für onlinebrief24.de

**Haftungsausschluss:** Dieses Projekt ist ein inoffizielles Community-Projekt und steht in keinerlei Verbindung zur Onlinebrief24 GmbH. "Onlinebrief24" ist ein eingetragenes Markenzeichen der jeweiligen Rechteinhaber. Die Nutzung dieser LaTeX-Klasse erfolgt auf eigene Gefahr; es wird keine Garantie für die fehlerfreie Verarbeitung durch den Dienstleister übernommen.


Basierend auf KOMA-Script (scrlttr2) für DIN 5008 Typ B.

## Installation

Die Datei `onlinebrief24.cls` muss im gleichen Verzeichnis wie Ihre Briefdatei liegen.

### Globale Installation (optional)

Für eine systemweite Verfügbarkeit kann die Klassendatei in Ihrem lokalen TeX-Verzeichnisbaum abgelegt werden. Dadurch müssen Sie die `.cls`-Datei nicht mehr in jedem Projektordner vorhalten.

1.  **Finden Sie Ihren `TEXMFHOME`-Pfad:**
    *   Führen Sie im Terminal den Befehl `kpsewhich -var-value TEXMFHOME` aus.
    *   Das Ergebnis ist der Pfad zu Ihrem lokalen TeX-Verzeichnis (z. B. `~/texmf`).

2.  **Erstellen Sie die nötige Ordnerstruktur:**
    *   Innerhalb Ihres `TEXMFHOME`-Verzeichnisses benötigen Sie folgenden Pfad: `tex/latex/onlinebrief24/`.
    *   Erstellen Sie die Ordner, falls sie nicht existieren: `mkdir -p $(kpsewhich -var-value TEXMFHOME)/tex/latex/onlinebrief24`

3.  **Kopieren Sie die Klassendatei:**
    *   Verschieben oder kopieren Sie `onlinebrief24.cls` in das soeben erstellte Verzeichnis.

4.  **Aktualisieren Sie die TeX-Datenbank:**
    *   Führen Sie den Befehl `texhash` (oder `mktexlsr`) im Terminal aus. Bei MiKTeX finden Sie eine entsprechende Option in den Einstellungen (Settings -> "Refresh file name database").

Danach können Sie von überall auf Ihrem System `\documentclass{onlinebrief24}` verwenden.


## Verwendung

```latex
\documentclass{onlinebrief24}

\usepackage{fontspec}
\setmainfont{Arial}

\setreturnaddress{Max Mustermann \\ Musterstraße 123 \\ 12345 Musterstadt}

\begin{document}

\begin{letter}{Empfängeradresse}
\opening{Sehr geehrte Damen und Herren,}

Ihr Briefinhalt hier...

\closing{Mit freundlichen Grüßen}

\end{letter}

\end{document}
```

## Optionen

- `draft` - Aktiviert den Draft-Modus mit Sicherheitszonen-Visualisierung
- `fontsize=<size>` - Schriftgröße für Empfängeradresse (Standard: 9pt, max 11pt)

## Befehle

- `\setrecipient{...}` - Empfängeradresse
- `\setreturnaddress{...}` - Absenderadresse (einzeilig)
- `\enablesafetyzones` - Blendet im Draft-Modus graue/rote Boxen zur Visualisierung der Überblendungsbereiche ein

## Zonen (DIN 5008 Typ B)

- **Zone 1**: Absenderangabe (2 mm Höhe)
- **Zone 2**: Sendungskennzeichnung (20 mm Höhe) - wird bei Einschreiben überblendet
- **Zone 3**: Empfängeranschrift (20 mm Höhe)

## Falzmarken

Zwei Falzmarken bei 105 mm und 205 mm sind automatisch implementiert.
