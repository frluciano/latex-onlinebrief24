# TODO

## Dokumentation

- [ ] CHANGELOG.md anlegen (Änderungshistorie bisher nur über Git-Log)

## Versionierung & Releases

- [ ] Semantic Versioning einführen (z.B. `v1.0.0` zusätzlich zum LaTeX-Datumsstempel)
- [ ] GitHub-Releases mit Tags erstellen (nach erstem CTAN-Release)
- [ ] Versions-/Datumspflege in `\ProvidesClass` automatisieren

## Testing

- [ ] LaTeX3 `l3build`-Testframework evaluieren (aktuell nur PDF-Output-Regression via `pdftotext`)

## Mögliche Erweiterungen (niedrige Priorität)

- [ ] pdfLaTeX-Support via Engine-Weiche (`fontspec` vs. `fontenc`/`tgheros`) -- Kalibrierung müsste separat validiert werden
- [ ] Internationalisierung -- `babel ngerman` ist aktuell hardcodiert; bei Bedarf konfigurierbar machen
