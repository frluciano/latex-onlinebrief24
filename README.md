# LaTeX-Klasse für onlinebrief24.de

**Haftungsausschluss:** Dieses Projekt ist ein inoffizielles Community-Projekt und steht in keinerlei Verbindung zur letterei.de Postdienste GmbH. "Onlinebrief24" ist ein eingetragenes Markenzeichen der jeweiligen Rechteinhaber. Die Nutzung dieser LaTeX-Klasse erfolgt auf eigene Gefahr; es wird keine Garantie für die fehlerfreie Verarbeitung durch den Dienstleister übernommen.


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

## Vorschau

<p align="center">
  <img src="examples/example-basic-preview.png" alt="Basic" width="45%">
  <img src="examples/example-modern-preview.png" alt="Modern" width="45%">
</p>

## Optionen

- `guides`: Aktiviert einen Visualisierungs-Modus, der das komplette Layout mit allen Zonen, Maßen und Falzmarken als technische Zeichnung über den Brief legt. Ideal zur Überprüfung des Satzspiegels. Kann mit `modern` kombiniert werden.
- `basic`: (Standard) Deaktiviert den `guides`-Modus.
- `modern`: Aktiviert ein alternatives, modernes Layout für Kopf- und Fußzeile kann mit `guides` kombiniert werden.
- `footercenter`: Zentriert die Fußzeile. Diese Option hat nur in Verbindung mit `modern` einen Effekt.

## Befehle

- `\setrecipient{...}`: Setzt die vollständige Empfängeradresse.
- `\setreturnaddress{...}`: Setzt die **einzeilige** Absenderadresse für das Sichtfenster (Zone 1). Diese ist für die postalische Verarbeitung zwingend erforderlich. Die Adresse wird automatisch unterstrichen.

### Befehle für die `modern`-Option

Diese Befehle haben nur eine Auswirkung, wenn die `modern`-Option aktiv ist.

- `\setfromfirstname{...}`: Vorname des Absenders für die Kopfzeile.
- `\setfromlastname{...}`: Nachname des Absenders für die Kopfzeile.
- `\setfromaddress{...}`: Adresse für die Kopfzeile (z.B., "Musterweg 1 | 12345 Musterstadt").
- `\setfromlandline{...}`: (Optional) Festnetznummer für die Fußzeile.
- `\setfromphone{...}`: (Optional) Mobilfunknummer für die Fußzeile.
- `\setfromemail{...}`: (Optional) E-Mail-Adresse für die Fußzeile.
- `\setfromweb{...}`: (Optional) Webseite für die Fußzeile.
- `\setfromlinkedin{...}`: (Optional) LinkedIn-Profilname für die Fußzeile.
