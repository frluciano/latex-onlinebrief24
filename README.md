# LaTeX-Klasse für onlinebrief24.de

**Haftungsausschluss:** Dieses Projekt ist ein inoffizielles Community-Projekt und steht in keinerlei Verbindung zur letterei.de Postdienste GmbH. "Onlinebrief24" ist ein eingetragenes Markenzeichen der jeweiligen Rechteinhaber. Die Nutzung dieser LaTeX-Klasse erfolgt auf eigene Gefahr; es wird keine Garantie für die fehlerfreie Verarbeitung durch den Dienstleister übernommen.


Basierend auf KOMA-Script (scrlttr2) für DIN 5008 Typ B.

## Installation

Fuer eigene Briefe sollte die Datei `onlinebrief24.cls` im gleichen Verzeichnis wie deine `.tex`-Datei liegen. Die Beispiele in diesem Repo referenzieren die Klasse relativ ueber `../onlinebrief24.cls`.

## Voraussetzungen

- Empfohlener und verifizierter Build-Workflow: `xelatex`.
- `lualatex` ist prinzipiell vorgesehen, wird in diesem Repository aktuell aber nicht als Standard-Workflow verifiziert.
- `pdflatex` wird nicht unterstützt, da die Klasse `fontspec` nutzt.
- `Arial` wird bevorzugt verwendet. Wenn die Schrift nicht installiert ist, fällt die Klasse automatisch auf `TeX Gyre Heros` zurück.

### Globale Installation (optional)

Für eine systemweite Verfügbarkeit kann die Klassendatei in Ihrem lokalen TeX-Verzeichnisbaum abgelegt werden. Dadurch musst du die `.cls`-Datei nicht mehr in jedem Projektordner vorhalten.

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

Empfohlener Start:

```bash
cd examples
xelatex example-basic.tex
```

Hier findest du die verschiedenen Stile und Optionen der Dokumentenklasse im direkten Vergleich.

Zur lokalen Verifikation aller Beispiele inklusive Mehrseiten-Regression:

```bash
sh scripts/verify.sh
```

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
\setreturnaddress{Erika Mustermann, Blumenweg. 1, 54321 Blumenstadt}
\setrecipient{Mustermann GmbH \& Co. KG \\ Herrn Hans Mustermann \\ ...}
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
\setfromfirstname{Erika}
\setfromlastname{Mustermann}
\setfromaddress{Blumenweg. 1 | 54321 Blumenstadt}
\setfromphone{0123 / 456 789}
\setfromemail{erika@example.com}
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

## Optionen

### Layout-Optionen

- `basic`: (Standard) Einfaches Layout ohne Kopf- und Fußzeile.
- `modern`: Aktiviert ein alternatives, modernes Layout mit Kopf- und Fußzeile.
- `guides`: Aktiviert einen Visualisierungs-Modus, der das komplette Layout mit allen Zonen, Maßen und Falzmarken als technische Zeichnung über den Brief legt. Ideal zur Überprüfung des Satzspiegels. Kann mit `basic` oder `modern` kombiniert werden.
- `footercenter`: Zentriert die Fußzeile. Diese Option hat nur in Verbindung mit `modern` einen Effekt.

## Kalibrierung

- Die offizielle Maßgrafik von onlinebrief24.de nennt das Fenster nominell mit Start bei `49 mm` und Zonen `49-51 / 51-71 / 71-91 mm`.
- Die reale PDF-Vorschau des Onlinebrief24-Tools liegt jedoch messbar etwa `1 mm` tiefer.
- Diese Klasse ist deshalb bewusst auf `50-52 / 52-72 / 72-92 mm` kalibriert, weil damit der automatisch eingedruckte Sendungsaufdruck in der echten Vorschau korrekt in Zone 2 sitzt.
- Kurzform: `49 mm` ist der Nennwert aus der Grafik, `50 mm` der praxistaugliche Kompatibilitätswert zur echten Tool-Ausgabe.

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
- `\setfromaddress{...}`: Adresse für die Kopfzeile (z.B., "Blumenweg. 1 | 54321 Blumenstadt").
- `\setfromlandline{...}`: (Optional) Festnetznummer für die Fußzeile.
- `\setfromphone{...}`: (Optional) Mobilfunknummer für die Fußzeile.
- `\setfromemail{...}`: (Optional) E-Mail-Adresse für die Fußzeile.
- `\setfromweb{...}`: (Optional) Webseite für die Fußzeile.
- `\setfromlinkedin{...}`: (Optional) LinkedIn-Profilname für die Fußzeile.
