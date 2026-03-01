# Spezifikation: onlinebrief24.cls LaTeX-Klasse

## 1. Kontext & Basis

- **Ziel**: LaTeX-Klasse für onlinebrief24.de
- **Basis**: KOMA-Script (scrlttr2)
- **Norm**: Briefbogen DIN 5008 Typ B
- **Besonderheit**: Datamatrix- und Einschreiben-Codes werden vom System automatisch überlagert (Zone 2)

## 2. Geometrische Spezifikationen (Layout-Maße)

| Zone | Beschreibung | Höhe |
|------|--------------|------|
| Zone 1 | Absenderangabe | 2 mm |
| Zone 2 | Sendungskennzeichnung (wird bei Einschreiben überblendet) | 20 mm |
| Zone 3 | Empfängeranschrift (Adresserkennungszone) | 20 mm |
| **Gesamt** | Adressbereichhöhe | **42 mm** |

### Positionierung
- Fensterbreite: 72 mm
- Fensterhöhe: 54 mm
- Fensterhorizontalposition: 20 mm von links
- Zone 3 (Empfänger): unterste Zone im Fenster

## 3. Technische Anforderungen

### Schriftart
- Standard: Serifenlos (Helvetica/Arial-ähnlich)
- Empfängeranschrift: Mindestens 9pt (5 Zeilen) bis 11pt (4 Zeilen)
- Absender: 8pt

### Falzmarken
- 1. Falz: 105 mm
- 2. Falz: 205 mm

### Draft-Modus
- Visualisierung der "Sperrzonen" (Zone 2: 20 mm) durch farbige Boxen
- Zone 1: Grau
- Zone 2: Rot (Überblendungsbereich)

## 4. Makros

| Befehl | Beschreibung |
|--------|--------------|
| `\setrecipient{...}` | Empfänger in Zone 3 |
| `\setreturnaddress{...}` | Einzeiliger Absender für Zone 1 |
| `\enablesafetyzones` | Aktiviert Draft-Modus mit Visualisierung |

## 5. Klassenoptionen

- `draft` - Aktiviert Draft-Modus
- `final` - Deaktiviert Draft-Modus
- `fontsize=<size>` - Schriftgröße für Empfängeradresse (Standard: 9pt)
