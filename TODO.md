# TODO: Implementierung der "modern" Option für onlinebrief24.cls

Dieses Dokument beschreibt die Schritte zur Implementierung einer optionalen, modernen Kopf- und Fußzeile für die `onlinebrief24` LaTeX-Klasse.

**Ziel:** Eine `modern`-Option hinzufügen, die das Erscheinungsbild des Briefes aufwertet, ohne die bestehenden, strengen Spezifikationen (insbesondere das DIN-konforme Adressfenster) zu verletzen.

---

### Schritt 1: Neue Datenspeicher und Befehle in `onlinebrief24.cls` definieren

- [ ] `\newcommand{\@obb@fromname}{}` erstellen, um den Namen für die Kopfzeile zu speichern.
- [ ] `\newcommand{\@obb@fromphone}{}` erstellen, um die Telefonnummer für die Fußzeile zu speichern.
- [ ] `\newcommand{\@obb@fromemail}{}` erstellen, um die E-Mail-Adresse für die Fußzeile zu speichern.
- [ ] Benutzerbefehle `\setfromname{...}`, `\setfromphone{...}` und `\setfromemail{...}` erstellen, die die entsprechenden internen Makros füllen.

### Schritt 2: Neue Klassenoption `modern` deklarieren

- [ ] Einen neuen booleschen Schalter `\newif\if@modernstyle` definieren.
- [ ] Die Option `modern` mit `\DeclareOption{modern}{\@modernstyletrue}` deklarieren.
- [ ] Den Standardwert auf `false` setzen (`\@modernstylefalse`).

### Schritt 3: Bedingtes Laden von Abhängigkeiten und Definitionen

- [ ] Eine `\if@modernstyle`-Bedingung nach `\ProcessOptions\relax` einfügen.
- [ ] Innerhalb der Bedingung, die folgenden Pakete mit `\RequirePackage` laden:
    - `sourcesanspro` (mit Optionen `[default, light, semibold]`)
    - `marvosym` (für Telefon- und E-Mail-Symbole)
- [ ] Innerhalb der Bedingung, die Farbe `color2` definieren: `\definecolor{color2}{rgb}{0.45,0.45,0.45}`.

### Schritt 4: Moderne Kopf- und Fußzeile im `AddToShipoutPictureBG`-Block implementieren

- [ ] Den bestehenden `\AddToShipoutPictureBG`-Block um eine `\if@modernstyle` Abfrage erweitern.
- [ ] **Moderne Kopfzeile:**
    - [ ] Innerhalb der `if`-Bedingung, eine `\put`-Anweisung für die Kopfzeile hinzufügen.
    - [ ] Position: Rechtsbündig, oberhalb des Adressfensters (z.B. Y-Koordinate ~270mm).
    - [ ] Inhalt: Der Wert von `\@obb@fromname`.
    - [ ] Formatierung: `\Huge`, semibold (`\sffamily\bfseries`), `\color{color2}`.
- [ ] **Moderne Fußzeile:**
    - [ ] Innerhalb der `if`-Bedingung, eine `\put`-Anweisung für die Fußzeile hinzufügen.
    - [ ] Position: Rechtsbündig, im unteren Seitenbereich (z.B. Y-Koordinate ~15mm).
    - [ ] Inhalt: Eine formatierte Zeichenkette, die `\@obb@fromphone` und `\@obb@fromemail` mit Symbolen (`\Mobilefone`, `\Letter`) und Trennzeichen kombiniert.
    - [ ] Eine Logik implementieren (`\ifdefempty`), die sicherstellt, dass die Elemente und Trennzeichen nur angezeigt werden, wenn die entsprechenden Daten gesetzt sind.
    - [ ] Formatierung: `\sffamily`, `\color{color2}`.
- [ ] Sicherstellen, dass die bestehenden `\put`-Anweisungen für Adressfenster, Falzmarken etc. von dieser Logik unberührt bleiben.

### Schritt 5: Dokumentation und Beispiel anpassen

- [ ] Die `README.md` oder eine andere Dokumentationsdatei aktualisieren, um die neue `modern`-Option und die neuen `\set...`-Befehle zu erklären.
- [ ] Ein neues Beispiel-`.tex`-Dokument (`example-modern.tex`) erstellen, das die Verwendung der neuen Funktion demonstriert.
