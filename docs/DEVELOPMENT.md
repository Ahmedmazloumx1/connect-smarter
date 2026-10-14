# Development and isolated tests

Normal application builds connect to `connect-smarter-ahmed-2026` and require the user's own account. Development fixtures must stay inside local Firebase emulators.

## Flutter and Python checks

```powershell
flutter analyze
flutter test
flutter build web --no-web-resources-cdn
.\.venv\Scripts\python.exe -m pip install -r requirements-dev.txt
.\.venv\Scripts\python.exe -m pytest backend/tests -q
```

On the original PC, `scripts/build-live-web.ps1` runs the Flutter checks and writes a completion marker. Python test dependencies are separate from runtime dependencies.

## Firestore security tests

Install Node.js 22+ and Java 21, then:

```powershell
cd rules-tests
npm install
npx firebase emulators:exec --only firestore --project demo-connect-smarter --config ../firebase.json "node --test rules.test.cjs"
```

The reserved `demo-` project ID prevents accidental access to live Firebase services. Tests clear their disposable emulator database. Do not substitute the real project ID.

## Optional local workflow fixtures

For development only, start Auth and Firestore emulators:

```powershell
cd rules-tests
npx firebase emulators:start --only auth,firestore --project demo-connect-smarter --config ../firebase.json
```

In another terminal in `rules-tests`, run `node seed-demo.cjs`. Run the app from the project root with:

```powershell
flutter run -d chrome --web-port 3000 --dart-define=FIREBASE_EMULATORS=true
```

The seed script creates `candidate@example.test` and `company@example.test`, password `LocalDemo123!`, and a labeled test listing only in the emulators. These accounts do not exist in the live project. `docs/sample-cv.txt` is synthetic extraction test input, not a user's CV or application data. Emulator data is disposable. Default release builds do not opt into these services or seed any records.
