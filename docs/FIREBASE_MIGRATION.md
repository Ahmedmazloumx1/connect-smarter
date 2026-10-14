# Firebase migration — 14 October 2026

The default application connection now uses the user's new project **`connect-smarter-ahmed-2026`**. The source was **`cvdatabase-b992c`**. Migration used the user's explicitly authorized Firebase CLI login; source data and settings were not modified.

## What was copied and verified

| Source collection | Documents copied |
| --- | ---: |
| users | 15 |
| jobs | 6 |
| ai_interviews | 1 |
| companies | 1 |
| cv | 1 |
| interview_questions | 1 |
| job_application | 1 |
| **Total** | **26** |

Every copied field was compared against the source snapshot. A second source read confirmed unchanged document contents and update times. The new Firestore database uses the same `eur3` location. There were no composite indexes to copy. The source Realtime Database contained no data, and no Cloud Storage buckets were returned; neither service was provisioned in the destination. The refined application uses Firestore and Auth.

Eight Authentication accounts were imported with their original UIDs, emails, password hash bytes and salts preserved. The source SCRYPT parameters were used for import. Real users' passwords were not requested or changed, and no manual sign-in with an old user's password was performed. Email/Password, Google and Phone providers were configured in the destination. The current app exposes Email/Password; no Google/Phone UI integration, SMS delivery or reset-email delivery is claimed as newly tested.

Web, Android and iOS apps were registered with matching SDK configuration. The web app now has a real `:web:` App ID. `.firebaserc` selects the new project; Firebase configuration files and Dart options point to it. The misplaced iOS plist under `android/app` was removed. Reviewed Firestore rules were deployed to the destination instead of copying any potentially permissive legacy rules. No billing account was linked or paid service enabled as part of migration.

## Verification

Ten checks passed using Firebase's client SDK/API against the live destination: synthetic account creation/sign-in, profile/CV persistence, private profile access rejection, role escalation rejection, anonymous query rejection, company job publication, application/duplicate prevention, employer status updates, private practice records, publication visibility, and subsequent sign-in. Some checks group related assertions. The CV result used the actual FastAPI upload route via its in-process HTTP test client.

Two additional synthetic accounts and five associated documents were created temporarily in the destination for verification. On 14 October, both accounts and all five verification documents were removed. The obsolete credentials file was recycled. A subsequent comparison confirmed exactly 26 documents and eight Auth accounts remain, with all original migrated data preserved. Private pre-cleanup backups remain outside the source package.

The user ran `scripts/build-live-web.ps1`: Flutter analyzer reported no issues, all 18 tests passed, and the release web build completed. The default build uses live Firebase rather than emulators. Compiled JS was checked for the new project ID and absence of the old project ID. `scripts/start-preview.ps1` verified local web/API responses on ports 3000 and 8000.

Browser smoke tests also passed: the rebuilt Flutter app signed in to the live destination with a synthetic candidate, restored seven CV skills, displayed migrated listings and the synthetic demo listing, and showed the persisted application status `shortlisted`. Hosting remains local; no public frontend/API deployment is claimed. Android/iOS native builds remain unverified.

## Legacy records and compatibility

The clone preserves the original records rather than guessing missing ownership or rewriting history. Seven of the 15 profile documents do not correspond to the eight exported Auth UIDs. Five of six legacy jobs lack `ownerId`; they are now excluded from the application job browser. Ownership was not assigned to arbitrary users. Valid opportunities should be published through the owning company's account.

Legacy `ai_interviews`, `companies`, `cv`, `interview_questions` and `job_application` collections are retained in the clone. The refined app uses private `interviews` and consent-based `applications`; it does not convert old scores into new practice results or expose old applications automatically. Existing legacy collections without a matching allow rule remain inaccessible to client apps. Any future conversion should resolve account/ownership references explicitly.

## Private backup location

Migration snapshots, exported Auth hashes and hash parameters are under the task's private tooling folder `C:/Users/ahmed/Documents/Codex/2026-09-16/ah-2/work/firebase-migration`. CLI credentials are under its separate `work/firebase-config` folder. These folders are outside the final project and ZIP. Keep them private; do not upload them to GitHub or share them with the source archive.

## Run on this PC

```powershell
powershell -ExecutionPolicy Bypass -File "C:\Users\ahmed\Documents\Codex\Connect-Smarter-Final\scripts\start-preview.ps1"
```

Open `http://127.0.0.1:3000/`. The Python service runs locally on port 8000. For a fresh build use `scripts/build-live-web.ps1`. Sign in or create your own account. Disposable emulator fixtures are documented separately in `DEVELOPMENT.md` and are never seeded into the default live connection.
