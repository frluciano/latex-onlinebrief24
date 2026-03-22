# GitHub Environment Setup fuer den CTAN Release

Diese Datei beschreibt die **offenen Restarbeiten ausserhalb des Repos**.

Ziel ist, den neuen Release-Flow auch auf GitHub so zu konfigurieren, dass:

- waehrend des Freigabe-Gates kein CTAN-Submit moeglich ist
- CTAN-Credentials nur im dedizierten Publish-Kontext verfuegbar sind
- der manuelle Approval-Schritt sichtbar und technisch erzwungen ist

Diese Datei ist bewusst als Arbeitsdokument formuliert, damit Kommentare direkt
an den einzelnen Punkten moeglich sind.

## Zielzustand

Der neue Workflow im Repository geht davon aus:

- Es gibt ein GitHub Environment `ctan-release`
- Nur dieses Environment enthaelt `CTAN_EMAIL`
- Der Job `publish-to-ctan` in `Release CTAN` laeuft in diesem Environment
- Das Environment verlangt explizite menschliche Freigabe
- Ohne diese Freigabe bekommt der Job keine Publish-Credentials

## Wichtiger Sicherheitshinweis

`Release CTAN` darf **nicht** gestartet werden, bevor `ctan-release` sauber
eingerichtet ist.

Grund:

- GitHub kann ein referenziertes Environment automatisch anlegen
- ein automatisch angelegtes Environment hat aber nicht automatisch die
  gewuenschten Schutzregeln
- dadurch waere die technische Trennung zwar im Workflow angelegt, aber auf
  GitHub noch nicht wirksam

Deshalb gilt:

1. zuerst Environment sauber konfigurieren
2. dann Secret sauber verschieben
3. dann Freigaberegeln testen
4. erst danach den neuen Release-Workflow produktiv verwenden

## Schritt 1: Pruefen, ob Environments und Required Reviewers verfuegbar sind

Vor dem eigentlichen Setup bitte pruefen:

- Ist das Repository public oder private? -> public
- Welcher GitHub-Plan ist aktiv? -> GitHub Pro wwurde aber gekündigt
- Unterstuetzt dieser Plan GitHub Environments fuer dieses Repo? -> Ja
- Unterstuetzt dieser Plan Required Reviewers fuer dieses Repo? -> Ja

Hinweis:

- Laut GitHub sind Environments in privaten oder internen Repositories nicht in
  jedem Plan verfuegbar
- Required Reviewers sind ebenfalls plan- und sichtbarkeitsabhaengig

Wenn diese Funktionalitaet im aktuellen Repo nicht verfuegbar ist, muss das
vorher geklaert werden. Sonst fehlt die eigentliche Approval-Schranke.

## Schritt 2: Environment `ctan-release` anlegen

Navigation in GitHub:

- `Repository`
- `Settings`
- `Environments`
- `New environment`

Anlage:

- Name: `ctan-release`

Danach:

- `Configure environment`

## Schritt 3: Schutzregeln fuer `ctan-release` setzen

Empfohlene Konfiguration:

- `Required reviewers` aktivieren -> Habe mich dort eingetragen.
- 1 oder 2 konkrete Personen oder ein Team eintragen -> gibt keine weiteren Personen
- `Prevent self-review` aktivieren -> Es gibt keine weietren Personen
- `Allow administrators to bypass configured protection rules` deaktivieren -> Gemacht
- `Deployment branches and tags` auf `Selected branches and tags` setzen -> gemacht
- `main` freigeben

### Statusbewertung zu Schritt 3

Hier gibt es einen wichtigen Punkt:

- Wenn `Required reviewers` aktiv ist
- und nur du als Reviewer eingetragen bist
- und `Prevent self-review` ebenfalls aktiv ist

dann kannst du einen von dir gestarteten Release nicht selbst freigeben.

Das fuehrt praktisch zu einem Deadlock:

- der Job `publish-to-ctan` wartet auf Freigabe
- du bist der einzige Reviewer
- du darfst aber nicht selbst reviewen
- damit kann der Release nie weiterlaufen

### Empfehlung fuer ein Solo-Repository

Wenn es aktuell keine zweite reale Person als Reviewer gibt, ist die
pragmatische und weiterhin sichere Konfiguration:

- `Required reviewers` aktiviert lassen
- `Prevent self-review` deaktivieren
- `Allow administrators to bypass configured protection rules` deaktiviert
  lassen

Warum das trotzdem sinnvoll ist:

- der Freigabeschritt bleibt sichtbar
- der Publish-Job bleibt ans Environment gebunden
- das Secret bleibt nur im Environment
- es gibt weiterhin keinen automatischen CTAN-Submit

Was dabei schwächer wird:

- die Vier-Augen-Freigabe existiert dann nicht

Was trotzdem erhalten bleibt:

- kein automatischer Publish
- kein Prepare-Workflow mit Publish-Rechten
- keine Secrets im Build-/Prepare-Pfad
- sichtbarer manueller Review-Punkt im Actions-Flow

### TODO zu Schritt 3

- [ ] Entscheiden: `Prevent self-review` deaktivieren, solange es keinen zweiten
      Reviewer gibt

### Warum diese Einstellungen sinnvoll sind

`Required reviewers`

- erzwingt den sichtbaren manuellen Freigabeschritt
- ohne Freigabe bleibt der Publish-Job blockiert

`Prevent self-review`

- verhindert, dass dieselbe Person den Release startet und direkt selbst
  freigibt
- das ist fuer einen sicherheitskritischen Publish-Pfad sinnvoll

`Allow administrators to bypass configured protection rules` deaktivieren

- verhindert einen stillen Bypass der Schutzregeln
- wenn dieser Schalter aktiv bleibt, ist das Sicherheitsmodell weicher als
  geplant

`Deployment branches and tags = Selected branches and tags`

- haertet den Publish-Kontext zusaetzlich
- der Release-Workflow validiert zwar bereits, dass der Prepare-Run von `main`
  kommt
- die Environment-Regel soll diese Erwartung dennoch auch auf GitHub-Ebene
  abbilden

## Schritt 4: `CTAN_EMAIL` als Environment-Secret anlegen

Im Environment `ctan-release`:

- Bereich `Environment secrets`
- `Add secret`

Wert:

- Name: `CTAN_EMAIL`
- Value: die bei CTAN registrierte Upload-E-Mail-Adresse

Danach:

- `Add secret`

Alles soweit gemacht.

## Schritt 5: Repository- oder Organisationsebenen bereinigen

Das Sicherheitsziel lautet:

- `CTAN_EMAIL` existiert **nur** im Environment `ctan-release`

Deshalb bitte pruefen:

### Repository-Secrets

Navigation:

- `Settings`
- `Secrets and variables`
- `Actions`

Pruefen:

- Gibt es dort bereits ein Secret `CTAN_EMAIL`?

Wenn ja:

- loeschen

Habe ich gemacht.

### Organisationsebene

Falls das Repository Organisations-Secrets verwendet:

- pruefen, ob dort ebenfalls `CTAN_EMAIL` existiert
- falls ja, fuer dieses Repo entfernen oder umbenennen

WO finde ich das?

### Antwort: Wo finde ich Organisations-Secrets?

Das haengt davon ab, ob dieses Repository:

- in deinem persoenlichen GitHub-Account liegt -> Persönlich
- oder Teil einer GitHub-Organisation ist

#### Fall A: persoenliches Repository

Wenn das Repository in deinem persoenlichen Account liegt, ist dieser Punkt in
der Regel **nicht zutreffend**.

Dann gibt es fuer dieses Repo normalerweise:

- Repository-Secrets
- Environment-Secrets

aber keine Organisations-Secrets.

In diesem Fall kannst du hier notieren:

Nicht zutreffend, da persoenliches Repository



### TODO zu Schritt 5

- [ x] Klaeren: ist dieses Repo ein persoenliches Repo oder ein Organisations-Repo?
- [x ] Falls persoenliches Repo: Organisations-Secrets als `nicht zutreffend`
      markieren
### Warum das wichtig ist

Der Workflow ist absichtlich so gebaut, dass `CTAN_EMAIL` nur im
geschuetzten Environment bereitgestellt werden soll.

Auch wenn GitHub bei Namensgleichheit ein Environment-Secret bevorzugt, ist die
sicherste Konfiguration:

- kein gleichnamiges Repository-Secret
- kein gleichnamiges Org-Secret fuer dieses Repo

Damit bleibt klar:

- kein Prepare-Workflow
- kein anderer Workflow
- kein anderer Job

kann versehentlich auf dieselben CTAN-Credentials zugreifen.

## Schritt 6: Sicheren Testlauf durchfuehren

Ziel des Testlaufs:

- pruefen, dass der Workflow sichtbar auf Freigabe wartet
- pruefen, dass der Publish-Job ohne Environment-Freigabe nicht weiterlaeuft
- pruefen, dass der neue Ablauf wirklich nur vorbereitete Artefakte verwendet

### Testablauf

1. `Prepare CTAN Release` auf `main` laufen lassen
2. sicherstellen, dass das Artifact `onlinebrief24-ctan-release-bundle`
   erzeugt wurde
3. Artifact oeffnen und pruefen:
   - `onlinebrief24-YYYY-MM-DD.zip`
   - `onlinebrief24-YYYY-MM-DD.zip.sha256`
   - `announcement-draft.txt`
   - `release-metadata.json`
4. die `prepare_run_id` des Runs notieren
5. `Release CTAN` manuell starten
6. `prepare_run_id` eintragen
7. beobachten, dass `validate-release-inputs` durchlaeuft
8. beobachten, dass `publish-to-ctan` auf das Environment-Gate wartet
9. im UI pruefen, dass ein sichtbarer Review-Schritt vorhanden ist

### Erwartetes Verhalten

Vor Freigabe:

- kein Zugriff auf `CTAN_EMAIL`
- kein CTAN-Submit
- kein automatischer Fortschritt in den Publish-Job

Nach Freigabe:

- Publish-Job kann starten
- erst dann steht das Secret zur Verfuegung

## Schritt 7: Operativer Freigabeprozess im Alltag

Wenn spaeter ein echter CTAN-Release gemacht wird, soll der Ablauf so sein:

1. Aenderungen nach `main` mergen
2. erfolgreichen `Prepare CTAN Release` Run abwarten
3. Prepare-Bundle pruefen
4. `Release CTAN` manuell mit der passenden `prepare_run_id` starten
5. Freigabeschritt in `ctan-release` bewusst reviewen
6. `Approve and deploy`
7. erst danach erfolgt der eigentliche CTAN-Submit

## Empfohlene Abnahme-Checkliste

Diese Checkliste sollte vor dem ersten produktiven Release vollstaendig
abgehakt sein:

- [ ] Environment `ctan-release` existiert
- [ ] `Required reviewers` ist aktiv
- [ ] `Prevent self-review` ist aktiv
- [ ] Admin-Bypass ist deaktiviert
- [ ] Deployment-Regel ist auf `main` begrenzt
- [ ] `CTAN_EMAIL` existiert nur im Environment `ctan-release`
- [ ] Es gibt kein Repository-Secret `CTAN_EMAIL`
- [ ] Es gibt kein relevantes Organisations-Secret `CTAN_EMAIL` fuer dieses Repo
- [ ] Ein Testlauf von `Release CTAN` bleibt sichtbar auf Freigabe stehen
- [ ] Das Prepare-Bundle enthaelt ZIP, SHA256, Announcement-Draft und Metadata

## Dinge, die ich aus dem Repo heraus nicht selbst setzen kann

Diese Punkte muessen in der GitHub-Oberflaeche oder per Admin-Rechten erledigt
werden:

- Environment `ctan-release` anlegen
- Required Reviewers konfigurieren
- Self-review verbieten
- Admin-Bypass deaktivieren
- Deployment-Branch-Regeln setzen
- `CTAN_EMAIL` als Environment-Secret anlegen
- ggf. gleichnamige Repository-/Org-Secrets entfernen

## Kommentarbereich

Hier kannst du bei Bedarf direkt Punkte ergaenzen oder Fragen notieren:

- [ ] Ist `main` als einzige freigegebene Branch-Regel korrekt?
- [ ] Soll `Prevent self-review` zwingend sein?
- [ ] Wer soll Required Reviewer sein?
- [ ] Gibt es bereits ein Repo- oder Org-Secret `CTAN_EMAIL`?
- [ ] Sollen wir die GitHub-Oberflaechen-Schritte spaeter noch in `ctan/RELEASE.md`
      verlinken?

## Quellen

- GitHub Docs: Managing environments
  https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments
- GitHub Docs: Deployments and environments
  https://docs.github.com/en/actions/reference/workflows-and-actions/deployments-and-environments
- GitHub Docs: Reviewing deployments
  https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/review-deployments
- GitHub Docs: Using secrets in GitHub Actions
  https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets
- GitHub Docs: Secrets reference
  https://docs.github.com/en/actions/reference/security/secrets
