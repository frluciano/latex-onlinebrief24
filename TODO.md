# TODO

## Offen ausserhalb des Repos

- [ ] Beim naechsten absichtlich freigegebenen echten CTAN-Release den
      End-to-End-Pfad live verifizieren:
      `Prepare CTAN Release` -> `Release CTAN` -> Approval ->
      erfolgreicher CTAN-Submit -> automatischer `Sync GitHub Release`
- [ ] Dabei konkret pruefen:
      Git-Tag entspricht der Version, Tag zeigt auf `source_commit_sha`,
      GitHub Release enthaelt ZIP, SHA256, `announcement-draft.txt`,
      `release-metadata.json` und `resolved-release-metadata.json`
- [ ] Falls der GitHub-Release-Sync nach erfolgreichem CTAN-Submit einmal
      fehlschlaegt, den dokumentierten Retry-Fall praktisch durchspielen:
      nur `Sync GitHub Release` erneut starten, niemals `Release CTAN`
