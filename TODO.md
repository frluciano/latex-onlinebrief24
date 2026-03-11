# TODO

## Active Task

> **Goal:** —
> **Status:** Idle
> **Current Step:** —
> **Last Modified:** —
> **Next Action:** Pick next item from Queued
> **Context:** Project is stable, both CTAN releases (2026-03-10, 2026-03-11) are published
> **Blockers:** None

## Queued

- [ ] `bump-version.sh` auf Datumsversierung umstellen — Script referenziert noch Semver-Logik
- [ ] GitHub Secret `CTAN_EMAIL` setzen — wird vom Release-Workflow für den CTAN-Upload benötigt

## Done

- [x] GitHub-Releases mit Tags erstellen — Tags `2026-03-10` und `2026-03-11`, Releases auf GitHub angelegt
- [x] pdfLaTeX-Support — engine-abhängiges Font-Loading in `onlinebrief24.cls`
- [x] `lang=` Option — konfigurierbare Babel-Sprache via `kvoptions`
- [x] CI-Pipeline umbenannt — `verify.yml` → `build-verify.yml`, Name: `LaTeX Build Verification`
- [x] CTAN-Doku aktualisiert — pdfLaTeX, lang=, Installation via tlmgr
- [x] Versioniertes CTAN-Artefakt — ZIP-Dateiname enthält Versionsdatum
- [x] Semver-Referenzen entfernt — CHANGELOG.md auf Datumsversierung umgestellt
- [x] CTAN-Update 2026-03-11 hochgeladen — ZIP `onlinebrief24-2026-03-11.zip` bei CTAN eingereicht
