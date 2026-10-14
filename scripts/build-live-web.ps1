param([switch]$CheckToolsOnly)

$ErrorActionPreference = 'Stop'
$taskProjectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$taskBundledWork = Join-Path (Split-Path $taskProjectRoot -Parent) '2026-09-16\ah-2\work'

# A normal PowerShell window does not inherit Codex's bundled Git PATH.
if (-not (Get-Command git -CommandType Application -ErrorAction SilentlyContinue)) {
    $taskGitCandidates = @(
        "$env:ProgramFiles\Git\cmd\git.exe",
        "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe",
        "$env:USERPROFILE\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\git\cmd\git.exe",
        (Join-Path $taskBundledWork 'flutter-3.44.1\bin\mingit\cmd\git.exe')
    )
    foreach ($taskGitCandidate in $taskGitCandidates) {
        if (Test-Path -LiteralPath $taskGitCandidate -PathType Leaf) {
            $env:PATH = (Split-Path $taskGitCandidate -Parent) + ';' + $env:PATH
            break
        }
    }
}
$taskGit = Get-Command git -CommandType Application -ErrorAction SilentlyContinue
if (-not $taskGit) {
    throw 'Git was not found. Install Git for Windows, reopen PowerShell, then run this script again.'
}
& $taskGit.Source --version
if ($LASTEXITCODE) { throw 'Git was found but could not run.' }

$taskFlutter = Get-Command flutter -ErrorAction SilentlyContinue
if ($taskFlutter) {
    $taskFlutterPath = $taskFlutter.Source
} elseif (Test-Path (Join-Path $taskBundledWork 'flutter-3.44.1\bin\flutter.bat')) {
    $taskFlutterPath = Join-Path $taskBundledWork 'flutter-3.44.1\bin\flutter.bat'
    $env:GIT_CONFIG_COUNT = '1'
    $env:GIT_CONFIG_KEY_0 = 'safe.directory'
    $env:GIT_CONFIG_VALUE_0 = Join-Path $taskBundledWork 'flutter-3.44.1'
    $env:PUB_CACHE = Join-Path $taskBundledWork 'pub-cache'
    $env:APPDATA = Join-Path $taskBundledWork 'appdata'
} else {
    throw 'Install Flutter 3.44.1 and add flutter to PATH first.'
}
$env:FLUTTER_SUPPRESS_ANALYTICS = 'true'
Write-Host ('Git: ' + $taskGit.Source)
Write-Host ('Flutter: ' + $taskFlutterPath)
if ($CheckToolsOnly) { return }
Start-Transcript -LiteralPath (Join-Path $taskProjectRoot 'build-live-web.log') -Append | Out-Null
Push-Location $taskProjectRoot
try {
    & $taskFlutterPath pub get
    if ($LASTEXITCODE) { throw 'Dependency setup failed.' }
    $taskDartPath = Join-Path (Split-Path $taskFlutterPath -Parent) 'cache\dart-sdk\bin\dart.exe'
    if (Test-Path -LiteralPath $taskDartPath) {
        & $taskDartPath format lib test
        if ($LASTEXITCODE) { throw 'Dart formatting failed.' }
    }
    & $taskFlutterPath analyze --no-pub
    if ($LASTEXITCODE) { throw 'Flutter analysis failed.' }
    & $taskFlutterPath test --no-pub
    if ($LASTEXITCODE) { throw 'Flutter tests failed.' }
    & $taskFlutterPath build web --no-pub --no-web-resources-cdn
    if ($LASTEXITCODE) { throw 'Web build failed.' }
    Set-Content -LiteralPath (Join-Path $taskProjectRoot 'build\live-verification.txt') -Value @(
        'Firebase project: connect-smarter-ahmed-2026',
        'Emulators: disabled (default build)',
        'Product experience: account-only; sample accounts and listings removed',
        'Flutter analyze, tests and release web build: passed',
        ('Verified at: ' + (Get-Date).ToString('o'))
    )
    Write-Host 'Live Firebase web build completed. Build output: build/web'
} finally {
    Pop-Location
    Stop-Transcript | Out-Null
}
