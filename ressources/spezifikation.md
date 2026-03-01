# Spezifikation: onlinebrief24.cls LaTeX-Klasse

## 1. Kontext & Basis

- **Ziel**: Robuste LaTeX-Klasse für onlinebrief24.de Briefdruck.
- **Basis**: KOMA-Script (`scrlttr2`).
- **Besonderheit**: Die Klasse deaktiviert die Standard-Layout-Automatismen von KOMA-Script zugunsten einer absoluten Positionierung (`eso-pic`, `tikz`), um pixelgenaue Konformität mit DIN 5008 Typ B zu gewährleisten.
- **Sprache**: Deutsch (`ngerman` via `babel`).

## 2. Geometrische Spezifikationen (DIN 5008 Typ B)

### Adressfenster (Physisch)
- **Position oben**: 45 mm vom Papierrand.
- **Position links**: 20 mm vom Papierrand.
- **Breite**: 72 mm (laut Vorgabe, Standard wäre 85mm).
- **Höhe**: 45 mm (beinhaltet Zonen 1-3).

### Zonen (innerhalb des Fensters)
Die Zonen werden relativ zum oberen Papierrand positioniert:

| Zone | Beschreibung | Höhe | Y-Position (von oben) |
|---|---|---|---|
| **Zone 1** | Absender (einzeilig) | 2 mm | 45 mm - 47 mm |
| **Zone 2** | Sperrzone (Codes) | 20 mm | 47 mm - 67 mm |
| **Zone 3** | Empfängeranschrift | 20 mm | 67 mm - 87 mm |

### Ausrichtung (Fluchtlinie)
Alle Textelemente richten sich an einer gemeinsamen **Fluchtlinie bei 25 mm** vom linken Papierrand aus:
- Inhalt Zone 1 (Absender)
- Inhalt Zone 3 (Empfänger) - *Einrückung um 5mm im Fenster*
- Betreffzeile
- Brieftext

### Weitere Maße
- **Textbeginn (Körper)**: 110 mm vom oberen Rand.
- **1. Falzmarke**: 105 mm.
- **2. Falzmarke**: 205 mm.

## 3. Klassenoptionen

- `guides` (Standard: aus): Aktiviert einen technischen Zeichnungsmodus.
    - Zeigt farbige Rahmen um die Zonen (Zone 1, 2, 3).
    - Zeigt Bemaßungspfeile und Maße in Rot.
    - Zeigt die Fluchtlinie (gestrichelt, rot).
    - Zeigt Falzmarken-Hinweise.
- `final` (Standard): Deaktiviert alle Hilfslinien für den produktiven Druck.

## 4. Befehle & Makros

Um Doppelungen durch KOMA-Script zu vermeiden, nutzt die Klasse eigene Datenspeicher.

| Befehl | Beschreibung |
|---|---|
| `\setreturnaddress{...}` | Setzt die Absenderzeile (Zone 1). |
| `\setrecipient{...}` | Setzt die Empfängeranschrift (Zone 3). |
| `\setsubject{...}` | Setzt den Betreff (Fettdruck, über der Anrede). |
| `\setdate{...}` | Setzt das Datum (Standard: `\today`). |
| `\setplace{...}` | Setzt den Ort vor dem Datum. |

## 5. Nutzung

```latex
\documentclass[guides]{onlinebrief24} % 'guides' für Vorschau, 'final' für Druck

\setreturnaddress{Max Mustermann, Musterstraße 1, 12345 Musterstadt}
\setrecipient{Erika Mustermann \\ Musterweg 1 \\ 12345 Stadt}

\setsubject{Betreffzeile}
\setplace{Musterstadt}
\setdate{\today}

\begin{document}
\begin{letter}{} % Leeres Argument!
    \opening{Sehr geehrte Damen und Herren,}
    ...
    \closing{Mit freundlichen Grüßen}
\end{letter}
\end{document}
```
