# Source change inventory

Compared on 25 September 2026 against the supplied source copy:

- Original: `C:/Users/ahmed/Downloads/connect-smarter1-main/connect-smarter1-main`
- Refined: `outputs/connect-smarter` in this task's workspace (the project root, one level above this document)

Neither project folder contains a `.git` directory. This is a file-path and content comparison with the original copy, not a Git diff, commit log, or attribution of individual edits. The original folder was read only for this comparison. A modified entry means the file's bytes differ; this includes formatting changes as well as behavior changes. Removed entries mean absent from the refined copy, not deleted from the original.

## Scope

The inventory covers application/backend source, maintained project configuration, dependency manifests/locks, tests, documentation and the reusable verification script. It excludes caches, build products, installed dependencies/runtimes, logs, analysis output, shortcuts, editor-local settings, generated plugin registrants and machine-local SDK configuration such as `local.properties`, `Generated.xcconfig`, ephemeral directories and Flutter plugin metadata. Binary artwork, fonts and screenshots are not inventoried or individually hashed here. Application Firebase options remain in scope because the app imports that configuration.

`docs/SOURCE_CHANGES.md` includes itself as an added document. Unchanged source files are omitted. Test results and deployment/platform limits are recorded separately in [VALIDATION.md](VALIDATION.md).

## Major changes

- **Account and profile flows:** added recovery for incomplete signup, explicit account settings and private practice history; revised session clearing, profile restoration, save behavior and ownership boundaries.
- **CV analysis:** replaced the monolithic API implementation with FastAPI extraction/analysis modules, bounded uploads, explicit PDF/DOCX/TXT validation and evidence-based skill extraction; separated Flutter networking from presentation.
- **Jobs and applications:** connected candidate browsing and company listing management to owned/public Firestore records; added consent-based applications, duplicate prevention, employer status updates and defensive parsing of old or malformed records.
- **Interview practice:** replaced camera/voice-scoring paths and unsupported outcome claims with written questions, deterministic concept coverage, timers, private saved results and clear limitations.
- **Executable screens and copy:** removed obsolete mock routes, fabricated listings and delivery/result screens; revised navigation, visible errors, job preparation questions and mail drafting.
- **Verification and handoff:** added backend/domain/widget/security regressions, local emulator fixtures, verification commands, CI configuration, setup documentation, portfolio wording and the refined prompt. Updated dependencies, web metadata and Firestore rules/configuration.

The removed-file list includes obsolete or duplicate screens and synthetic data/scoring helpers. This inventory is historical; the later local release cleanup moved maintained screens out of `lib/demo/` and removed that directory.

## Inventory totals

| Status | Files |
| --- | ---: |
| Added | 37 |
| Modified | 46 |
| Removed from refined copy | 25 |

## Added

```text
.github/workflows/verify.yml
backend/__init__.py
backend/analysis.py
backend/app.py
backend/limits.py
backend/skills.json
backend/tests/test_api.py
backend/tests/test_documents.py
docs/ARCHITECTURE.md
docs/PORTFOLIO.md
docs/REFINEMENT_PROMPT.md
docs/SOURCE_CHANGES.md
docs/START_HERE_AR.md
docs/VALIDATION.md
docs/sample-cv.txt
lib/account_settings_screen.dart
lib/applications_screen.dart
lib/complete_profile_screen.dart
lib/models/cv_analysis.dart
lib/practice_history_screen.dart
lib/services/application_service.dart
lib/services/cv_service.dart
lib/services/interview_questions.dart
lib/services/interview_scoring.dart
lib/services/job_matching.dart
lib/services/record_parser.dart
pytest.ini
requirements-dev.txt
requirements-lock.txt
rules-tests/package.json
rules-tests/rules.test.cjs
rules-tests/seed-demo.cjs
scripts/verify.ps1
test/domain_test.dart
test/practice_flow_test.dart
test/profile_recovery_test.dart
test/record_parser_test.dart
```

## Modified

```text
.gitignore
README.md
api.py
firebase.json
firestore.rules
lib/ai_interview_screen.dart
lib/ai_interview_setup_screen.dart
lib/api_constants.dart
lib/candidate_profile_screen.dart
lib/company_bottom_nav_bar.dart
lib/company_dashboard_screen.dart
lib/company_notifications_screen.dart
lib/company_profile_editor_screen.dart
lib/company_settings_screen.dart
lib/create_company_account_screen.dart
lib/cv_analyze_screen.dart
lib/cv_upload_screen.dart
lib/demo/email_details.dart
lib/demo/post_new_job_screen.dart
lib/demo/terms_of_service_screen.dart
lib/demo/user_settings.dart
lib/edit_profile_screen.dart
lib/firebase_options.dart
lib/forgot_password_screen.dart
lib/interview_result_screen.dart
lib/job_details_screen.dart
lib/login_screen.dart
lib/main.dart
lib/manage_active_jobs_screen.dart
lib/privacy_policy_screen.dart
lib/recommended_jobs_screen.dart
lib/send_email_screen.dart
lib/services/auth_service.dart
lib/services/cv_analysis_store.dart
lib/services/firebase_service.dart
lib/services/interview_store.dart
lib/services/job_service.dart
lib/services/profile_image_manager.dart
lib/top_matched_candidates_screen.dart
lib/user_sign_up_screen.dart
lib/widgets/safe_asset_image.dart
pubspec.lock
pubspec.yaml
requirements.txt
web/index.html
web/manifest.json
```

## Removed from refined copy

```text
lib/accepted_email_screen.dart
lib/company_home_screen.dart
lib/company_profile_screen.dart
lib/create_company_screen.dart
lib/demo/ai_interview_details_screen.dart
lib/demo/create_new_password.dart
lib/demo/cv_pdf_viewer_screen.dart
lib/demo/learning_path.dart
lib/demo/new_suggested_job.dart
lib/demo/not_accepted_email_screen.dart
lib/demo/response_delivered.dart
lib/demo/terms_conditions_screen.dart
lib/email_details_screen.dart
lib/interview_voice_stub.dart
lib/interview_voice_web.dart
lib/job_notification_screen.dart
lib/office_location_map_screen.dart
lib/result_interview_screen.dart
lib/services/database_seeder.dart
lib/suggestion_job_screen.dart
lib/verify_identity_screen.dart
lib/web_camera_signal_stub.dart
lib/web_camera_signal_web.dart
lib/welcome_page.dart
web_entrypoint.dart
```

## Later Firebase migration — 14 October 2026

The inventory above is the earlier refinement snapshot. Subsequent migration added `.firebaserc`, `docs/FIREBASE_MIGRATION.md`, `scripts/build-live-web.ps1` and `scripts/start-preview.ps1`; reconfigured `firebase.json`, `lib/firebase_options.dart`, Android/iOS SDK config and the Firebase initialization error text; removed the misplaced iOS plist from `android/app`; and updated README, location, architecture, portfolio and verification documents. Private migration backups remain outside the distributable source. `FIREBASE_MIGRATION.md` contains the current migration evidence.

## Local release cleanup — 14 October 2026

- Replaced the guest/portfolio start screen with candidate/company registration and sign-in; added public privacy and terms links with service-specific text.
- Moved maintained job publication and terms screens to the `lib/` root, replaced settings/application wrappers with their actual screens, and removed `lib/demo/` and unused visual reference files.
- Removed the unused fallback jobs constant, excluded ownerless legacy listings from browsing, and validated cached Auth sessions before restoring profiles.
- Removed the two temporary live verification accounts and five associated records; original migrated data remains unchanged. Recycled the obsolete credentials file.
- Updated local-use documentation and separated emulator-only fixtures into `DEVELOPMENT.md`. Added a small-screen privacy-navigation regression and corrected text wrapping on narrow viewports.
- Extended the build script with Dart formatting, transcript output and a completion marker that identifies the account-only experience. Public hosting and GitHub publication remain deferred at the user's request.
