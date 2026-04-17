# TODO

## Offen ausserhalb des Repos


## Für nächsten CTAN-Release

Release-blockierende Korrektur-Items (mit sichtbarer Auswirkung auf Nutzer-Kompilate oder CTAN-Paket).

### Branch 1 — `release/next-ctan` (maß-neutral, sofort mergbar)

- **US-R02** Als Nutzer möchte ich, dass `\begin{letter}[opts]{...}` die optionalen KOMA-Per-Letter-Options respektiert, damit die dokumentierte `scrlttr2`-Schnittstelle eingehalten wird. [onlinebrief24.cls:304-315 — P1]
- **US-R03** Als Dokumentations-Leser möchte ich, dass das `\addfooteritem`-Beispiel in der CTAN-Doku ein in `fontawesome5` existierendes Icon verwendet (`\faTwitter` statt `\faXTwitter`), damit kopierter Beispiel-Code kompiliert. [ctan/onlinebrief24-doc.tex:254 — P1]
- **US-R04** Als Nutzer möchte ich, dass die Klasse `sourcesans` statt des deprecated Alias `sourcesanspro` lädt, damit bei jedem Modern-Mode-Kompilat keine Package-Warning mehr erscheint. [onlinebrief24.cls:319 — P2, ersetzt US-A01]

### Branch 2 — `release/fix-modern-header` (visuelle Regression nötig, allein)

- **US-R01** Als Nutzer möchte ich, dass der Modern-Mode-Header die korrekte Breite (160 mm) verwendet, damit der Sender-Name-Block nicht über den rechten Seitenrand läuft. Fix: `\parbox{\paperwidth-50mm}` → `\parbox{\dimexpr\paperwidth-50mm\relax}`. [onlinebrief24.cls:508 — P1] **Vor Merge: Modern-Beispiele rendern, PDF-Diff gegen onlinebrief24.de-Preview.**

## Queued

### Branch 4 — `cls/refactor-and-api-tests` (maß-erhaltende Klassen-Cleanups + neue Fixtures für Public-API)

- **US-C01** Als Nutzer möchte ich, dass `\addinfoblockrow` auch dann gerendert wird, wenn keines der eingebauten Infoblock-Felder gesetzt ist, damit eigene Zeilen nicht verloren gehen. [onlinebrief24.cls:436-456 — P2]
- **US-Q01** Als Klassen-Autor möchte ich die doppelte Breitenmessung der Rücksendeadresse (Validator vs. Renderer) konsolidieren, damit Error- und Clamp-Verhalten übereinstimmen. [onlinebrief24.cls:281-295,486-487 — P1]
- **US-Q02** Als Klassen-Autor möchte ich die fünf kopierten Footer-Separator-Blöcke über `\addfooteritem` vereinheitlichen, damit Änderungen nur an einer Stelle nötig sind. [onlinebrief24.cls:527-545 — P2]
- **US-Q04** Als Klassen-Autor möchte ich `\addfooteritem` im Basic-Mode mit einer Class-Warning versehen (oder es hinter `\if@modernstyle` verschieben), damit Nutzer keinen stillen Fehler wegen fehlendem fontawesome erhalten. [onlinebrief24.cls:347-360 — P2, eskaliert]
- **US-Q05** Als Klassen-Autor möchte ich Magic-Numbers für Header/Footer-Positionen (270, 5, 25, 50mm, 18pt, 20pt) durch benannte Konstanten ersetzen, damit die Modern-Mode-Kalibrierung konsistent mit den DIN-Konstanten wird. [onlinebrief24.cls — P2]
- **US-Q06** Als Klassen-Autor möchte ich `\setfromname` dokumentieren oder eine Deprecation-Warning ausgeben, damit der Legacy-Alias sauber abgekündigt werden kann. [onlinebrief24.cls:257 — P3]
- **US-A05** Als Klassen-Autor möchte ich `\g@addto@macro` durch das dokumentierte `\gappto` (etoolbox) ersetzen, damit keine Kernel-Internals genutzt werden. [onlinebrief24.cls:353,413 — P3]
- **US-T01** Als Klassen-Autor möchte ich eine Regression-Fixture für `\addfooteritem`, damit die Public-Extension-API abgedeckt ist. [tests/fixtures/ — P1]
- **US-T02** Als Klassen-Autor möchte ich eine Regression-Fixture für `\addinfoblockrow`, damit die Public-Extension-API abgedeckt ist. [tests/fixtures/ — P1] (Pair mit US-C01)
- **US-T03** Als Klassen-Autor möchte ich Regression-Fixtures für `\setinfoblocktopoffset`, `\setinfoblockrightedge` und `\setinfoblockcolwidths`, damit die Layout-Tuning-API abgedeckt ist. [tests/fixtures/ — P1]
- **US-T04** Als Klassen-Autor möchte ich eine Regression-Fixture für `modern + infoblock` mit Assertion auf den farbigen Label-Rendering-Path, damit Style-konditionale Farben getestet werden. [tests/fixtures/ — P1]
- **US-T07** Als Klassen-Autor möchte ich einen Test für die Nähe des 72-mm-Limits von `\@obb@validatereturnaddresswidth`, damit der Boundary-Path und die Clamp-Logik geprüft werden. [onlinebrief24.cls:284 — P2] (Pair mit US-Q01)

### Branch 5 — `cls/din-geometry` (visuelle Regression nötig, allein)

- **US-Q03** Als Klassen-Autor möchte ich die DIN-Fenster-Geometrie an einer Stelle definieren (Picture-Modus vs. TikZ-Guides), damit beide Darstellungen nicht auseinanderdriften können. [onlinebrief24.cls — P2] **Vor Merge: Pixel-Diff gegen aktuelle Renderings sämtlicher Examples und Fixtures.**

### Branch 6 — `tests/coverage-gaps` (unabhängige Fixture/Assertion-Verbesserungen)

- **US-C02** Als verify-CI möchte ich deterministische Assertions für französische Infoblock-Labels (ASCII-Referenzwert statt UTF-8 `Vos références`), damit die Prüfung unter pdflatex+T1 robust ist. [scripts/verify.sh:153 — P1]
- **US-C03** Als verify-CI möchte ich Assertions für `\setfromphone` und `\setfromlandline` im `footercenter`-Fixture, damit Regressionen in Phone/Landline erkannt werden. [scripts/verify.sh:243 — P2]
- **US-C04** Als verify-CI möchte ich mindestens eine Text-Assertion für `guides-regression.tex`, damit grobe Rendering-Regressionen nicht unbemerkt bleiben. [tests/fixtures/guides-regression.tex — P3]
- **US-Q07** Als Test-Autor möchte ich die fünf minimalen Locale-Fixtures auf die volle Feld-Abdeckung der italienischen Fixture bringen (`\setplace`, `\setourref`, `\setourmessage`, `\setcontactname`, `\setcontactphone`, `\setcontactfax`), damit Regressionen in allen Sprachen erkannt werden. [tests/fixtures/infoblock-*-regression.tex — P1]
- **US-Q08** Als Test-Autor möchte ich eine einheitliche Zeichen-Kodierungs-Konvention in allen Fixtures (ASCII-Escapes vs. UTF-8), damit die Tests einheitlich lesbar sind. [tests/fixtures/ — P2]
- **US-Q09** Als Test-Autor möchte ich Fixtures für `modern` ohne `footercenter` und für `guides + infoblock`, damit alle unterstützten Option-Kombinationen abgedeckt sind. [tests/fixtures/ — P2]
- **US-T05** Als Test-Autor möchte ich eine bbox-basierte Assertion für die `footercenter`-Zentrierung, damit die Layout-Eigenschaft überhaupt geprüft wird (pdftotext erkennt keine Zentrierung). [scripts/verify.sh — P2]
- **US-T06** Als Test-Autor möchte ich eine negative Assertion für den Basic-Mode (Abwesenheit von Modern-Elementen wie `\faMobile`), damit ein versehentlich weggefallener `\if@modernstyle`-Guard erkannt wird. [tests/fixtures/ — P2]
- **US-T08** Als Klassen-Autor möchte ich einen Test für den `lang`-Fallback auf Deutsch, wenn eine nicht registrierte Babel-Sprache verwendet wird. [onlinebrief24.cls — P2]

### Branch 7 — `scripts/consolidation` (Fixes + Dedup + Portabilität + eval-Refactor + Tests)

- **US-C05** Als Release-Build möchte ich, dass `build-ctan.sh` bei leerem Version-String abbricht statt `onlinebrief24-.zip` zu produzieren, damit Build-Fehler sichtbar werden. [scripts/build-ctan.sh:9,61 — P2]
- **US-C06** Als Metadata-Validator möchte ich, dass `isinstance(bool, int)` in `release_validation.py` abgefangen wird, damit `prepare_run_id: true` nicht als gültige Integer akzeptiert wird. [scripts/lib/release_validation.py:70-74 — P2]
- **US-C07** Als Metadata-Generator möchte ich `$prepare_run_id` und `$version` im JSON-Heredoc validieren und quotieren, damit ungültige Env-Overrides kein korruptes JSON erzeugen. [scripts/generate-release-metadata.sh:35-55 — P2]
- **US-A02** Als Maintainer möchte ich `bump-version.sh` portabel ohne `sed -i` umschreiben (oder den POSIX-`sh`-Anspruch aufgeben), damit das Skript nicht an GNU/BSD-Extensions hängt. [scripts/bump-version.sh:30,34 — P2]
- **US-A03** Als Release-Skript möchte ich `sha256sum` durch einen portablen Hash-Aufruf ersetzen, damit lokale Dev-Läufe auf macOS funktionieren. [validate-release-inputs.sh:52, generate-release-metadata.sh:31 — P2]
- **US-A04** Als Change-Detection möchte ich `gh api compare` nicht mehr als vollständige Diff-Quelle behandeln, damit große Pushes (>300 Dateien) nicht stillschweigend Jobs überspringen. [scripts/ci-detect-changes.sh:54-65 — P2]
- **US-Q10** Als Release-Skript möchte ich die Resolved-Metadata-Validierung aus dem Inline-Python in `sync-github-release.sh` nach `release_workflow.py` heben, damit keine duplizierte Validierungslogik existiert. [sync-github-release.sh:34-92 ↔ lib/release_workflow.py — P1]
- **US-Q11** Als Release-Skript möchte ich den Inline-Python-Block in `release-ctan.sh` durch einen Aufruf der kanonischen `release_validation.py`-Funktionen ersetzen, damit Metadata nicht zweimal parallel gelesen wird. [scripts/release-ctan.sh:27-41 — P1]
- **US-Q12** Als Maintainer möchte ich die GH_TOKEN/GITHUB_TOKEN-Aliasing-Logik in eine Funktion `normalize_gh_token` in `lib/common.sh` auslagern, damit sie nicht in zwei Skripten dupliziert ist. [ci-detect-changes.sh ↔ sync-github-release.sh — P2]
- **US-Q13** Als Release-Skript möchte ich den Inline-Python-Block in `generate-announcement-draft.sh` durch `cmd_read_announcement` aus `release_validation.py` ersetzen, damit keine parallele Implementierung existiert. [scripts/generate-announcement-draft.sh:20-26 — P2]
- **US-Q14** Als Maintainer möchte ich `cmd_validate_prepare_run_provenance` und `cmd_validate_release_run_provenance` um einen gemeinsamen Helper `_validate_run_provenance(repo, run_id, expected_name, expected_event)` reduzieren, damit die Logik nur einmal existiert. [scripts/lib/release_workflow.py:109-125,281-297 — P2]
- **US-Q15** Als Maintainer möchte ich einen Helper `read_cls_version` in `lib/common.sh`, damit `build-ctan.sh` und `bump-version.sh` die Version nicht über zwei divergente sed-Patterns extrahieren. [build-ctan.sh ↔ bump-version.sh — P3]
- **US-S02** Als Release-Skript möchte ich das `eval "$metadata_values"`-Muster durch explizite Per-Feld-Extraktion (python3 -c / jq) ersetzen, damit künftige Schema-Änderungen nicht zur Injection-Quelle werden. [release-ctan.sh:43, validate-release-inputs.sh:24,75, sync-github-release.sh:94 — P1, architektonisch] (Eng mit Q10/Q11/Q13/Q14 gekoppelt — in einem Zug)
- **US-T09** Als Maintainer möchte ich Tests für `bump-version.sh` mit ungültigen Datums-Inputs (z.B. `2026-00-01`), damit Parsing-Edgecases erkannt werden. [scripts/bump-version.sh — P2]
- **US-T10** Als Maintainer möchte ich einen Test für den Epoch-Fallback in `generate-release-metadata.sh`, damit die Non-CI-Execution-Path validiert wird. [scripts/generate-release-metadata.sh — P2]

### Branch 8 — `ci-and-tooling` (Workflows + Linter + Dependabot + Agentic)

- **US-Q16** Als Maintainer möchte ich den duplizierten Change-Detection-Block als Composite Action `.github/actions/detect-changes/action.yml` extrahieren, damit die drei Workflows synchron bleiben. [.github/workflows/{build-verify,validate-tooling,build-ctan}.yml — P1]
- **US-Q17** Als Maintainer möchte ich den TeX-Live-Install-Block als Composite Action mit optionalen Paket-Inputs extrahieren, damit die divergenten Paketlisten bewusst statt latent sind. [.github/workflows/{build-verify,build-ctan}.yml — P1]
- **US-Q18** Als Maintainer möchte ich das Artifact-Bundle-Download-Pattern als Composite Action extrahieren, damit die drei kopierten Blöcke in den Release-Workflows nur an einer Stelle gepflegt werden. [.github/workflows/{release-ctan,sync-github-release}.yml — P1]
- **US-Q19** Als Release-Pipeline möchte ich den "Upload rendered CTAN submission input"-Step nach dem CTAN-Publish non-blocking machen, damit ein fehlschlagender Audit-Upload den sync-github-release-Trigger nicht suppressed. [.github/workflows/release-ctan.yml — P2]
- **US-Q20** Als Maintainer möchte ich die redundante zweite `checkout@v6`-Action in `release-ctan.yml` entfernen, damit der Job nicht unnötig zweimal auscheckt. [.github/workflows/release-ctan.yml — P3]
- **US-T11** Als Release-Build möchte ich, dass `build-ctan.sh` die Doku auch mit xelatex und lualatex kompiliert (oder zumindest eine cross-engine-Smoke-Verifikation), damit das ausgelieferte Artifact zur User-Empfehlung passt. [.github/workflows/build-ctan.yml — P3]
- **US-D01** Als Maintainer möchte ich `actions/upload-artifact` in allen Workflows von v6 auf v7 aktualisieren, damit wir aktuelle Features (`archive: false`) nutzen können. [.github/workflows/*.yml — P2]
- **US-TL01** Als Maintainer möchte ich `shfmt -d` in `check-tooling.sh` und CI einbinden, damit Shell-Format-Drift verhindert wird. [repo — P2]
- **US-TL02** Als Maintainer möchte ich einen Python-Linter (ruff) mit minimaler Konfiguration für `scripts/lib/`, damit Style- und Common-Bug-Checks über `py_compile` hinausgehen. [repo — P2]
- **US-TL03** Als Maintainer möchte ich einen Pre-Commit-Hook (`.pre-commit-config.yaml`), der `check-tooling.sh` lokal ausführt, damit CI-Fehler vor dem Push erkannt werden. [repo — P2]
- **US-TL04** Als Maintainer möchte ich `.github/dependabot.yml` mit `package-ecosystem: github-actions`, damit Action-Updates automatisch als PRs auftauchen. [repo — P3]
- **US-AG01** Als Codex-CLI-Nutzer möchte ich ein `AGENTS.md` (oder Symlink auf `CLAUDE.md`), damit die Agent-Anweisungen Tool-übergreifend geladen werden. [repo root — P1]
- **US-AG02** Als Claude-Code-Nutzer möchte ich, dass `CLAUDE.md` die zehn `agent-rules/*.md`-Dateien per `@agent-rules/`-Import lädt, damit die Regeln auch wirklich in den Agent-Kontext kommen. [CLAUDE.md — P1]
- **US-AG03** Als Maintainer möchte ich projekt-level Skills für CTAN-Build, Release-Tagging und Changelog-Update, damit wiederkehrende Workflows nicht bei jeder Session neu aus der Doku rekonstruiert werden. [repo — P2]
- **US-AG04** Als Agent möchte ich, dass `CLAUDE.md` explizit auf `TODO.md` und `LESSONS-LEARNED.md` verweist, damit das Session-Start-Protocol selbsttragend ist. [CLAUDE.md — P2]

## Zu diskutieren (kein Branch bis geklärt)

- **US-C08** Sind die einzeiligen Empfänger in den fünf Locale-Fixtures (dutch/french/german/spanish/polish) Absicht, oder sollten alle mit `\\`-getrennten Adressen die Multi-Line-Parse-Path testen? [tests/fixtures/infoblock-*-regression.tex — P2]
- **US-A06** Ist das Fehlen von `\@mkboth` im `\opening`-Override beabsichtigt, oder degradiert es Multi-Page-Briefe unter `headings`-Pagestyle? [onlinebrief24.cls — P3]
- **US-D02** Migration `fontawesome5` → `fontawesome6` sinnvoll? Command-Namen ändern sich (breaking API). [onlinebrief24.cls — P3]

## Empfohlene Merge-Reihenfolge

1. ~~**Branch 3** `security/supply-chain`~~ — ✓ erledigt
2. ~~**Branch 1** `release/next-ctan`~~ — PR #32 offen
3. ~~**Branch 2** `release/fix-modern-header`~~ — PR #33 offen, nach visueller Verifikation
4. ~~**Branch 7** `scripts/consolidation`~~ — PR #30 erledigt
5. ~~**Branch 8** `ci-and-tooling`~~ — PR #31 offen
6. ~~**Branch 4** `cls/refactor-and-api-tests`~~ — PR #34 offen
7. ~~**Branch 5** `cls/din-geometry`~~ — PR #35 offen, nach visueller Verifikation
8. ~~**Branch 6** `tests/coverage-gaps`~~ — PR #36 offen

## Done

### Branch 3 — `security/supply-chain` (2026-04-16)

- **US-S01** `ctan-o-mat` an Tag `1.2` + Commit-SHA `58889f86` gepinnt; SHA-Verifikation vor `sudo install`. [.github/workflows/release-ctan.yml:182-192]
- **US-S03** `actions/checkout` und `actions/upload-artifact` in allen 5 Workflows auf unveränderliche Commit-SHAs gepinnt. [.github/workflows/*.yml]
- **US-S04** `inputs.prepare_run_id` und `steps.source_run.outputs.release_run_id` in Release-Workflows über `env:`-Variablen weitergeleitet statt direkt in Shell interpoliert. [release-ctan.yml:56-58,103-109,112-122 · sync-github-release.yml:73-86,95-105]
