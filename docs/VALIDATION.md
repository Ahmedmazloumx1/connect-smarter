# Verification record

Verified locally during the September 2026 refinement, with the browser CV smoke test completed on 25 September and the account-recovery browser check completed on 1 October. This records checks actually performed; it does not guarantee the absence of every possible defect.

| Check | Result | Coverage |
| --- | --- | --- |
| Flutter analyzer | Passed, no issues | All application and test Dart source |
| Flutter tests | 18 passed | Welcome screen, scoring/word boundaries, unique question bank, skill matching, session clearing, practice completion/timeouts/disposal, small viewport, malformed Firestore records, profile setup retry/validation/disposal |
| Python tests | 17 passed | PDF/DOCX/TXT extraction, valid/invalid/empty/encrypted/oversized input, expanded document limits, deterministic skills, CORS, request size limits including chunked bodies |
| Firestore emulator tests | 10 passed | Authentication, private profiles/practice, immutable roles and legacy profile completion, ownership, public/private job queries, application consent boundaries/duplicates/forgery, employer-only status updates, malformed document schemas |
| Release web build | Passed | `flutter build web --no-pub --dart-define=FIREBASE_EMULATORS=true --no-web-resources-cdn` |

Toolchain: Flutter 3.44.1, Dart 3.12.1, Python 3.12.14, Firebase CLI 15.30.1, Firestore emulator 1.22.0, Java 21. Production and test Python dependency versions are captured in `requirements-lock.txt`; Flutter versions are captured in `pubspec.lock`.

The Python test run reports two upstream deprecation warnings from the Starlette/httpx test client and its AnyIO alias. Tests pass; these are not application exceptions. A future dependency refresh should recheck this test-client combination. The web build's Wasm dry run passed; the delivered build uses the standard JavaScript target.

## Browser checks actually performed

Using the local release web app, Python API and disposable Firebase emulators:

- Guest interview practice accepted a typed answer, advanced with timers and displayed actual concept coverage with unanswered questions scored zero.
- Selected `docs/sample-cv.txt` through the browser file picker and submitted it to FastAPI. The result displayed Flutter Developer and the seven explicit skills: dart, fastapi, firebase, flutter, git, python and sql. The result correctly said it was session-only for a guest.
- Candidate sign-in restored its saved CV fixture and displayed the real emulator job with required-skill coverage.
- Candidate explicitly confirmed sharing an application. The UI displayed “Application submitted”.
- After sign-out, company sign-in displayed the submitted applicant; shortlisting persisted and the profile displayed “Application: shortlisted”.
- Created a disposable Auth-only account with no Firestore profile, signed in through the release web app, and verified that “Finish account setup” opened. Saving the synthetic profile persisted it in Firestore and navigated to “Upload Your CV”. This verifies recovery through the actual Auth/Firestore services as well as the widget retry tests.

The initial candidate/company journey described above used synthetic local fixtures. See the 14 October live verification below for the subsequent Firebase migration.

## Remaining external verification

- Android, iOS and desktop platform builds/device behavior require their native SDKs and were not tested here.
- The Firebase migration and Auth/rules deployment are complete. Public frontend/API hosting, production security review, release signing and distribution remain separate work.
- GitHub Actions configuration is included, but no remote workflow run was performed. Local checks above are the evidence.
- Password-reset email delivery and the installed mail application's draft UI were not exercised against real services.
- Document extraction does not include OCR. Interview scores measure reference-concept mentions, not answer correctness or employability.
- The CV API is intended for local use. Public operation needs authenticated access, rate limits, HTTPS and document-processing isolation.

## Source preservation

The supplied Downloads folder and the working project contain no `.git` directory. Consequently there was no Git status/diff or commit history to inspect. Work continued by comparing source paths and file contents with the original copy, reviewing partial changes and running the checks above. The original was left intact during refinement; old local copies were later recycled at the user's explicit request. The source Firebase project was not changed during migration. `SOURCE_CHANGES.md` lists source additions, changes and removals.

Use the commands in `README.md` to reproduce verification. `scripts/verify.ps1` runs the Flutter/Python checks and web build once dependencies and `.venv` are installed; the Firestore emulator suite is a separate documented command.

## Live Firebase migration — 14 October 2026

- Destination: `connect-smarter-ahmed-2026`, created through the user's authorized Google account.
- Copied 26 Firestore documents; all fields and counts compared successfully. The source was re-read and document update times were unchanged.
- Imported eight Auth accounts. UIDs, emails and decoded password hash/salt bytes were verified. Actual old-user passwords were not supplied or manually tested.
- Deployed reviewed Firestore rules and configured Email/Password, Google and Phone providers. No SMS or reset email was sent.
- Ten SDK/API checks passed against the live destination, including synthetic signup/sign-in, profile/CV persistence, private data access rejection, role escalation rejection, job publishing/unpublishing, applications/duplicate prevention and employer status updates. CV upload was tested against the actual FastAPI route through its in-process HTTP test client.
- User-run Flutter validation completed successfully outside the tool sandbox: analyzer reported no issues; 18 tests passed; release web build succeeded. `build/live-verification.txt` recorded completion. The compiled JS contains the new project ID and does not contain the old project ID.
- The preview startup script confirmed the local web server and API were reachable on ports 3000 and 8000. Browser verification then passed: live sign-in, restored CV metadata, job list, and persisted application status. Details are recorded in `FIREBASE_MIGRATION.md`.

The initial tool-side Flutter execution was blocked by Windows path canonicalization restrictions. The user ran the supplied verification script locally. This is not recorded as a successful tool-side build.

## Account-based local release — 14 October 2026

- Removed guest/sample entry points and replaced the start page with sign-in and candidate/company registration. Maintained screens now live outside the removed `lib/demo/` directory. Unused visual references were recycled.
- Removed two temporary live verification accounts and five associated documents. A post-cleanup comparison confirmed all 26 migrated documents and eight original Auth accounts remain unchanged.
- Excluded ownerless legacy listings from the job browser and added Auth session reload before restoring cached profile data.
- The first new small-screen regression exposed overflowing text and a privacy-button visibility issue in the test. Flexible text layout and explicit button visibility were corrected; the failing regression was retained.
- The user reran `scripts/build-live-web.ps1` successfully. Formatting, analyzer, all 19 Flutter tests and the live-configuration release web build passed. The updated marker records completion at **2026-10-14T03:18:02+03:00** and explicitly identifies the account-only experience. Compiled JS contains the new home text and Firebase project ID; the old home text and old Firebase project ID are absent.
- Browser checks loaded the new home on `http://localhost:3000/`, confirmed candidate/company registration controls and absence of guest entry points, opened public privacy/terms pages and reached the live Firebase sign-in form. No new synthetic accounts or live application records were created for this final interface check.
- An older browser cache at the `127.0.0.1` origin still showed the preceding interface. Local startup instructions now direct users to the verified localhost origin. Existing local services continue to run on ports 3000/8000.

Backend code and Firestore rules were unchanged by this interface cleanup; their earlier 17 Python and 10 emulator test results remain recorded above. Public hosting and GitHub publication are deferred at the user's request.
