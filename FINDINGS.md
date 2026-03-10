# Robustheits-Findings

Stand: 2026-03-10

## Gepruefter Umfang

- Klasse: `onlinebrief24.cls`
- Doku: `README.md`, `ressources/spezifikation.md`
- Beispiele: alle `.tex`-Dateien unter `examples/`

## Kurzfazit

- Alle vier urspruenglich dokumentierten Findings sind behoben.
- Alle sechs Beispiel-Dateien bauen mit `xelatex` im vorgesehenen Repo-Workflow.
- `pdflatex` bricht mit einer klaren Fehlermeldung ab. Das ist gut.
- `\setfromname` funktioniert im `modern`-Stil wieder.
- Offene Findings aus diesem Audit: keine.

## Findings

### 1. Empfaengerblock ist breiter als das Fenster

Status: behoben am 2026-03-10
Fix umgesetzt in: `onlinebrief24.cls:190-194`

Schweregrad: hoch

- In `onlinebrief24.cls:176-180` wird Zone 3 mit `\parbox{80mm}` gesetzt.
- Die Spezifikation nennt fuer das Fenster aber `72 mm` Breite in `ressources/spezifikation.md:15`.
- Repro: Ein Test mit einer langen zweiten Empfaengerzeile erzeugte fuer `SehrLangeBeispielstrasseMitHausnummerZusatz` einen `xMax` von `297.252 pt`.
- Die rechte Fenstergraenze liegt bei `260.787 pt` (`56.693 pt + 72 mm`).

Risiko:

- Lange Empfaengerzeilen koennen rechts aus dem sichtbaren Fenster laufen.
- Das ist genau der Bereich, der beim Druck im Umschlag kritisch ist.

Empfehlung:

- Breite von Zone 3 auf `72mm` reduzieren.
- Optional `\raggedright` setzen, damit Zeilenumbruch robuster wird.

### 2. Das `letter`-Argument wird stillschweigend verworfen

Status: behoben am 2026-03-10
Fix umgesetzt in: `onlinebrief24.cls:98-106`

Schweregrad: mittel

- In `onlinebrief24.cls:89-93` wird `\letter` ueberschrieben und das uebergebene Argument immer ignoriert.
- Repro: Ein Minimalbeispiel mit `\begin{letter}{Empfaenger Aus Letter Argument ...}` und ohne `\setrecipient` erzeugte gar keine Empfaengeranschrift im PDF.
- `pdftotext` zeigte nur Datum, Anrede, Inhalt und Schlussformel.

Risiko:

- Standard-`scrlttr2`-Nutzung verliert Adressdaten ohne Fehlermeldung.
- Nutzer sehen kein Build-Problem, sondern erst spaeter ein falsches PDF.

Empfehlung:

- Entweder das `letter`-Argument in `\@obb@recipient` uebernehmen, wenn `\setrecipient` leer ist.
- Oder bei nicht-leerem `letter`-Argument explizit einen Klassenfehler ausgeben.

### 3. Leerer Ort fuehrt zu fuehrendem Komma vor dem Datum

Status: behoben am 2026-03-10
Fix umgesetzt in: `onlinebrief24.cls:69-94`

Schweregrad: mittel

- `onlinebrief24.cls:55` initialisiert `\@obb@place` leer.
- `onlinebrief24.cls:86-87` uebergibt den leeren Ort trotzdem an KOMA.
- Repro: Ein Minimalbeispiel ohne `\setplace` erzeugte die Zeile `, 10. Maerz 2026`.

Risiko:

- Die Defaults erzeugen ein sichtbar falsches Datumsformat.
- Das trifft jeden Nutzer, der nur `\setdate` oder gar nichts setzt.

Empfehlung:

- Datumszeile so definieren, dass das Komma nur erscheint, wenn `place` nicht leer ist.
- Alternativ die KOMA-Ausgabe fuer Ort/Datum explizit selbst rendern.

### 4. Beispiele sind nicht mehr eigenstaendig kompilierbar

Status: behoben am 2026-03-10
Fix umgesetzt in: `examples/*.tex`, `README.md`

Schweregrad: niedrig

- Das Audit hat den Bruch zwischen Repo-Struktur und Beispiel-Build aufgedeckt.
- Die Beispiele referenzieren die Klasse jetzt relativ ueber `../onlinebrief24.cls`.
- Der README-Workflow wurde auf den direkten Build in `examples/` umgestellt.
- Repro jetzt erfolgreich: `cd examples && xelatex example-basic.tex`.

Risiko:

- Nutzer stolpern beim direkten Testen im `examples/`-Ordner in einen vermeidbaren Build-Fehler.

Empfehlung:

- README klar auf Root-Build oder globale Installation ausrichten.
- Optional ein kleines Build-Script bereitstellen.

## Verifikation

- Alle `examples/*.tex` bauen mit `xelatex` im `examples/`-Ordner erfolgreich.
- `pdflatex` liefert die erwartete Fehlermeldung fuer die nicht unterstuetzte Engine.
- `lualatex` konnte in dieser Sandbox nicht sauber verifiziert werden, weil `luaotfload` keinen schreibbaren Cache-Pfad hatte. Das ist hier kein belastbarer Projekt-Finding.
