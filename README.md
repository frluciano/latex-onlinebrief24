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

Im Ordner [`examples/`](examples/) findest du fertige `.tex`-Dateien, die du direkt kompilieren kannst.

Hier findest du die verschiedenen Stile und Optionen der Dokumentenklasse im direkten Vergleich.

### 1. Standard-Stile

| Stil | Beschreibung |
| :--- | :--- |
| **Einfacher Brief (`basic`)** | Einfaches Layout ohne Kopf- und Fußzeile |
| **Modern (`modern, blue`)** | Modernes Layout mit Kopf- und Fußzeile.|

<table>
  <tr>
    <td><strong>Beispiel: Basic-Stil</strong>

```latex
\documentclass[basic]{onlinebrief24}
\setreturnaddress{Max Mustermann, ...}
\setrecipient{Erika Mustermann \\ ...}
\setsubject{Betreff des Briefes}
\begin{document}
\begin{letter}{}
\opening{Sehr geehrte Damen...}
Ihr Briefinhalt hier...
\closing{Mit freundlichen Grüßen}
\end{letter}
\end{document}
```

</td>
    <td><strong>Resultat</strong>

<img src="https://github.com/user-attachments/assets/943fcd60-6e56-4d7e-91d6-1fa519cabbd4" width="350" alt="example-basic">

</td>
  </tr>
  <tr>
    <td><strong>Beispiel: Modern-Stil</strong>

```latex
\documentclass[modern, blue, footercenter]{onlinebrief24}
\setfromfirstname{Max}
\setfromlastname{Mustermann}
\setfromaddress{Musterstraße 1 | ...}
\setfromphone{0123 / 456 789}
\setfromemail{max@example.com}
\begin{document}
\begin{letter}{}
\opening{Sehr geehrte Frau...}
Ihr Briefinhalt hier...
\closing{Mit freundlichen Grüßen}
\end{letter}
\end{document}
```

</td>
    <td><strong>Resultat</strong>

<img src="https://github.com/user-attachments/assets/53d11876-95f7-40be-aa7d-69f6e04935c6" width="350" alt="example-modern-blue">

</td>
  </tr>
</table>

---

### 2. Visualisierungs-Modus (`guides`)

Nutze die Option `guides`, um Hilfslinien für Faltmarken und Fensterpositionen (nach DIN 5008) einzublenden.

<table>
  <tr>
    <td><strong>Beispiel: Basic mit Guides</strong>

```latex
\documentclass[basic, guides]{onlinebrief24}
\setreturnaddress{Max Mustermann...}
...
```

</td>
    <td><strong>Resultat</strong>

<img src="https://github.com/user-attachments/assets/81e246d0-f94b-4875-8819-aabaeb3ceed9" width="350" alt="example-guides">

</td>
  </tr>
  <tr>
    <td><strong>Beispiel: Modern mit Guides</strong>

```latex
\documentclass[modern, guides, footercenter]{onlinebrief24}
\setfromfirstname{Max} ...
```

</td>
    <td><strong>Resultat</strong>

<img src="https://github.com/user-attachments/assets/47bcb426-d4d2-44aa-9823-244d12644cba" width="350" alt="example-modern-guides">

</td>
  </tr>
</table>

## Optionen

### Layout-Optionen

- `basic`: (Standard) Einfaches Layout ohne Kopf- und Fußzeile.
- `modern`: Aktiviert ein alternatives, modernes Layout mit Kopf- und Fußzeile.
- `guides`: Aktiviert einen Visualisierungs-Modus, der das komplette Layout mit allen Zonen, Maßen und Falzmarken als technische Zeichnung über den Brief legt. Ideal zur Überprüfung des Satzspiegels. Kann mit `basic` oder `modern` kombiniert werden.
- `footercenter`: Zentriert die Fußzeile. Diese Option hat nur in Verbindung mit `modern` einen Effekt.

### Farbschema-Optionen (nur mit `modern`)

Die Farbschemata sind kompatibel mit [moderncv](https://github.com/xdanaux/moderncv) und steuern die Akzentfarbe des Namens in der Kopfzeile.

| Option | Farbe | RGB |
|--------|-------|-----|
| `grey` | Dunkelgrau (Standard) | `0.55, 0.55, 0.55` |
| `blue` | Hellblau | `0.22, 0.45, 0.70` |
| `orange` | Orange | `0.95, 0.55, 0.15` |
| `green` | Grün | `0.35, 0.70, 0.30` |
| `red` | Rot | `0.95, 0.20, 0.20` |
| `purple` | Lila | `0.50, 0.33, 0.80` |
| `burgundy` | Burgund | `0.596, 0, 0` |
| `black` | Schwarz | `0, 0, 0` |

**Beispiel:**

```latex
\documentclass[modern, blue, footercenter]{onlinebrief24}
```

## Befehle

- `\setrecipient{...}`: Setzt die vollständige Empfängeradresse.
- `\setreturnaddress{...}`: Setzt die **einzeilige** Absenderadresse für das Sichtfenster (Zone 1). Diese ist für die postalische Verarbeitung zwingend erforderlich. Die Adresse wird automatisch unterstrichen.
- `\setsubject{...}`: Setzt den Betreff des Briefes (fett, über der Anrede).
- `\setdate{...}`: Setzt das Datum (Standard: `\today`).
- `\setplace{...}`: Setzt den Ort vor dem Datum.

### Befehle für die `modern`-Option 

Die modern-Option ist an die [LaTeX-Briefvorlage von Jan Mattfeld](https://github.com/janmattfeld/latex-briefvorlage) angelehnt.

Diese Befehle haben nur eine Auswirkung, wenn die `modern`-Option aktiv ist.

- `\setfromfirstname{...}`: Vorname des Absenders für die Kopfzeile.
- `\setfromlastname{...}`: Nachname des Absenders für die Kopfzeile.
- `\setfromaddress{...}`: Adresse für die Kopfzeile (z.B., "Musterweg 1 | 12345 Musterstadt").
- `\setfromlandline{...}`: (Optional) Festnetznummer für die Fußzeile.
- `\setfromphone{...}`: (Optional) Mobilfunknummer für die Fußzeile.
- `\setfromemail{...}`: (Optional) E-Mail-Adresse für die Fußzeile.
- `\setfromweb{...}`: (Optional) Webseite für die Fußzeile.
- `\setfromlinkedin{...}`: (Optional) LinkedIn-Profilname für die Fußzeile.
