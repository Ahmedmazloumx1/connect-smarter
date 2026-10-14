# Portfolio and CV wording

**Connect Smarter — Flutter recruitment workflow and interview practice**

Suggested CV bullets (use only after you can explain the implementation):

- Refactored a Flutter application with Firebase Authentication and Firestore into tested services for CV analysis, job publishing, applications and candidate review.
- Built a stateless FastAPI service extracting explicit skills from PDF, DOCX and TXT resumes, with upload limits, document validation and actionable errors.
- Implemented deterministic interview practice feedback, required-skill coverage and private per-user results; replaced randomized scores and fabricated fallback data.
- Enforced role and ownership checks with Firestore rules and automated emulator tests; verified Flutter analysis, widget tests and a release web build.

## Application walkthrough

1. Sign in with your own candidate account and complete the profile.
2. Analyze a CV you have permission to use with the Python service running.
3. Complete a practice interview and explain the keyword-coverage rubric and its limitations.
4. Browse published company listings and review the application sharing confirmation.
5. In a company account, publish a genuine opening and review applications submitted to that company.
6. Show the tests and explain why users cannot read another user's profile or practice answers. Use the isolated emulator instructions in `DEVELOPMENT.md` for reproducible test scenarios.

## Be precise in interviews

This version uses deterministic keyword extraction and practice scoring, not an LLM. It does not evaluate emotions, body language, intelligence or hiring suitability. It does not send email: it opens a draft in the user's mail client. No actual job offer or employer decision is generated automatically.

Possible future work: validated semantic answer feedback, OCR, server-side application workflows, deployment with authenticated/rate-limited API access, and native-device testing. Do not describe these as completed features.

## Verified migration addition — 14 October 2026

- Migrated 26 Firestore documents and eight Firebase Auth users into an independently owned project; preserved UIDs/password hashes, verified copied fields, deployed ownership rules, and validated live client workflows with synthetic accounts.

The frontend still runs locally. Do not describe a public production deployment or native mobile release as completed.
