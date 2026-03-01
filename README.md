# LaTeX-Klasse für onlinebrief24.de

Basierend auf KOMA-Script (scrlttr2) für DIN 5008 Typ B.

## Installation

Die Datei `onlinebrief24.cls` muss im gleichen Verzeichnis wie Ihre Briefdatei liegen oder in einem Verzeichnis, das im LaTeX-Suchpfad liegt.

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
