$ErrorActionPreference = 'Stop'
Push-Location (Join-Path $PSScriptRoot '..')
try {
    flutter pub get
    if ($LASTEXITCODE) { throw 'Dependency installation failed.' }
    flutter analyze
    if ($LASTEXITCODE) { throw 'Flutter analysis failed.' }
    flutter test
    if ($LASTEXITCODE) { throw 'Flutter tests failed.' }
    & .\.venv\Scripts\python.exe -m pytest backend/tests -q
    if ($LASTEXITCODE) { throw 'Python tests failed.' }
    flutter build web --no-web-resources-cdn
    if ($LASTEXITCODE) { throw 'Web build failed.' }
    Write-Host 'Analysis, Flutter/Python tests and web build passed. Run emulator rule tests separately as documented.'
} finally { Pop-Location }
