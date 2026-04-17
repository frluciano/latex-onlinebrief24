# TODO

## Für nächstes Release

### Queued

#### cls/feature

- **US-C01** `\addinfoblockrow` ohne eingebaute Felder — bereits behoben in 2026-04-17; Regression-Fixture in `tests/fixtures/addinfoblockrow-regression.tex` vorhanden
- **US-Q08** Einheitliche Zeichen-Kodierungs-Konvention in allen Fixtures (ASCII-Escapes vs. UTF-8) [tests/fixtures/ — P2]

#### scripts/consolidation

- **US-C05** `build-ctan.sh` bricht bei leerem Version-String nicht ab → produziert `onlinebrief24-.zip` [scripts/build-ctan.sh — P2]
- **US-C06** `isinstance(bool, int)` in `release_validation.py` nicht abgefangen; `prepare_run_id: true` wird als Integer akzeptiert [scripts/lib/release_validation.py — P2]
- **US-A02** `bump-version.sh` portabel ohne GNU `sed -i` umschreiben [scripts/bump-version.sh — P2]
- **US-A03** `sha256sum` durch portablen Hash-Aufruf ersetzen (macOS-Kompatibilität) [scripts/ — P2]
- **US-S02** `eval "$metadata_values"`-Muster durch explizite Per-Feld-Extraktion ersetzen (Injection-Risiko) [release-ctan.sh, validate-release-inputs.sh, sync-github-release.sh — P1]

#### ci-and-tooling

- **US-D01** `actions/upload-artifact` in allen Workflows von v6 auf v7 aktualisieren [.github/workflows/*.yml — P2]
- **US-TL02** Python-Linter (ruff) für `scripts/lib/` einbinden [repo — P2]
- **US-TL04** `dependabot.yml` mit `package-ecosystem: github-actions` anlegen [repo — P3]
- **US-AG01** `AGENTS.md` anlegen (oder Symlink auf `CLAUDE.md`) [repo root — P1]

## Zu diskutieren

- **US-C08** Einzeilige Empfänger in Locale-Fixtures — Absicht oder Multi-Line-Path fehlt? [tests/fixtures/infoblock-*-regression.tex — P2]
- **US-A06** Fehlendes `\@mkboth` in `\opening`-Override — degradiert Multi-Page unter `headings`-Pagestyle? [onlinebrief24.cls — P3]
- **US-D02** Migration `fontawesome5` → `fontawesome6` (breaking API) [onlinebrief24.cls — P3]

## Done

### 2026-04-17 — CTAN-Release

- Release `2026-04-17` vorbereitet und committed
- `\addinfoblockrow` Token-Leak (`\ifdefempty` mit Literaltext) behoben
- Modern-Header-Breite korrigiert (`\dimexpr\paperwidth-50mm\relax`)
- `\addinfoblockrow` ohne eingebaute Felder repariert
- `\addfooteritem` Warning im Basic-Mode
- `\setfromname` Deprecation-Warning
- DIN-Geometrie, Named Constants, Footer-Helper konsolidiert
- READMEs, CHANGELOG, Doku, Announcement aktualisiert

### 2026-04-16 — Branch 3 `security/supply-chain`

- `ctan-o-mat` und GitHub Actions auf unveränderliche Commit-SHAs gepinnt
- Release-Workflow-Inputs über `env:`-Variablen weitergeleitet

### Alle Branches 1–8 gemergt (2026-04-15/16)

- Branch 1 `release/next-ctan` (PR #32)
- Branch 2 `release/fix-modern-header` (PR #33)
- Branch 4 `cls/refactor-and-api-tests` (PR #34)
- Branch 5 `cls/din-geometry` (PR #35)
- Branch 6 `tests/coverage-gaps` (PR #36)
- Branch 7 `scripts/consolidation` (PR #30)
- Branch 8 `ci-and-tooling` (PR #31)
- Branch 9 `fix/ci-detect-changes-force-push` (PR #39)
