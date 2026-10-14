# Architecture and data contract

`lib/main.dart` provides sign-in, candidate registration and company registration. Privacy policy and terms are accessible before account setup. Firebase initializes when account access is requested; initialization/configuration failures are visible and retryable. Resuming a session reloads the Auth user and signs out invalid/deleted sessions before profile restoration.

`lib/services/` separates CV networking, authentication/session state, job persistence, application persistence, question selection and deterministic scoring. `lib/models/cv_analysis.dart` is independent of screens. The original package name `grad_project` remains for import compatibility.

Auth account creation and Firestore profile creation are separate operations. When the profile write fails, the signed-in user can retry the original profile from a recovery screen. Login/resume also routes missing profiles to setup; it never assumes a missing role means candidate. Profile completion uses a transaction and preserves an existing valid role. Owners may fill an absent legacy role once, but cannot switch a valid role. Profile editors require a successful load before enabling save.

External job/application documents are normalized in `record_parser.dart` before UI rendering. Firestore validates displayed field types and caps list sizes; the client also filters list entries to strings so old or malformed records cannot break a whole list. Employer preparation questions are displayed on listings; scored practice uses the app's separate question bank.

`api.py` is a compatibility entry point to `backend/app.py`. `backend/analysis.py` extracts text and matches explicit skills using `backend/skills.json`. PDF, DOCX and UTF-8 TXT are supported; legacy DOC, encrypted/scanned PDFs without extractable text and oversized documents receive errors. The service closes uploaded files and does not keep CVs or log their contents. Multipart parsing may temporarily spool data before extraction. The total request limit includes 64 KB multipart overhead; extracted text and DOCX expansion also have limits.

## Firestore collections

| Collection | Identity / access | Contents |
| --- | --- | --- |
| `users/{uid}` | Private to that user | Immutable `userType`, profile fields, optional CV analysis, optional bounded profile photo |
| `jobs/{id}` | Signed-in users can read public jobs; owner can read private jobs | `ownerId`, title, company, location, skills, education, questions, experience, publication state |
| `applications/{jobId}_{uid}` | Candidate and recipient employer only | Explicitly shared name/email/skills/profile, job snapshot, status |
| `interviews/{id}` | Candidate only | Written practice answers, reference-concept coverage, timestamp, scoring method |
| `notifications/{id}` | Recipient only | Reserved for trusted server-generated notices; clients cannot create notices |

The candidate submits an application only after confirming the data shared with the employer. A deterministic document ID and transaction reject duplicate submissions. Employer status changes are restricted to `submitted`, `shortlisted` and `rejected`. A candidate's self-reported skills are not independently verified.

Private jobs are queried by owner ID; public jobs by `isPublic == true`. Applications are queried by candidate or employer ID. These queries match the security rules and need no compound index. Existing legacy jobs without an owner or `isPublic` are intentionally not exposed; migrate them deliberately or recreate them through the company UI.

## Scope and limitations

- Practice feedback measures presence of reference words. It does not check semantic correctness or determine suitability for employment.
- No camera/microphone scoring or LLM provider is connected.
- Mail is drafted through `mailto`; delivery is performed by the user's mail application.
- CV metadata and practice results are saved privately to the signed-in user's Firestore records; the original CV file is not stored. There is no guest entry point in the delivered application.
- Account deletion performs several bounded operations and is not atomic across Auth and Firestore. A recently authenticated session is required; connection failures must be surfaced and retried. For a public production service, move cleanup into a trusted, idempotent backend job.
- The Python service is intended for localhost development. A public deployment requires authentication, rate limiting, hardened document-processing isolation and HTTPS. CORS is not authentication.
- The release web build and live Firebase Auth/Firestore workflows are validated for `connect-smarter-ahmed-2026`. Android/iOS/native device builds and public hosting are separate verification steps. See `FIREBASE_MIGRATION.md`.
