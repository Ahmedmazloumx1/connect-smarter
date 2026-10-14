# Complete GitHub's official browser/device login on the user's PC.
param([switch]$CheckToolsOnly)

$ErrorActionPreference = 'Stop'
$taskProjectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$taskBundledWork = Join-Path (Split-Path $taskProjectRoot -Parent) '2026-09-16\ah-2\work'

# A normal PowerShell window does not inherit the bundled Git PATH.
if (-not (Get-Command git -CommandType Application -ErrorAction SilentlyContinue)) {
    $taskGitCandidates = @(
        "$env:ProgramFiles\Git\cmd\git.exe",
        "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe",
        "$env:USERPROFILE\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\git\cmd\git.exe"
    )
    foreach ($taskGitCandidate in $taskGitCandidates) {
        if (Test-Path -LiteralPath $taskGitCandidate -PathType Leaf) {
            $env:PATH = (Split-Path $taskGitCandidate -Parent) + ';' + $env:PATH
            break
        }
    }
}
if (-not (Get-Command git -CommandType Application -ErrorAction SilentlyContinue)) {
    throw 'Git was not found. Install Git for Windows and reopen PowerShell.'
}

$taskGhCommand = Get-Command gh -CommandType Application -ErrorAction SilentlyContinue
$taskGhPath = if ($taskGhCommand) { $taskGhCommand.Source } else {
    Join-Path $taskBundledWork 'github-cli\bin\gh.exe'
}
if (-not (Test-Path -LiteralPath $taskGhPath -PathType Leaf)) {
    throw 'Install the official GitHub CLI from https://cli.github.com/ and reopen PowerShell.'
}
if (Test-Path -LiteralPath (Join-Path $taskBundledWork 'github-cli\bin\gh.exe')) {
    $env:GH_CONFIG_DIR = Join-Path $taskBundledWork 'github-auth'
}
if ($CheckToolsOnly) {
    git --version
    if ($LASTEXITCODE) { throw 'Git was found but could not run.' }
    & $taskGhPath --version
    if ($LASTEXITCODE) { throw 'GitHub CLI was found but could not run.' }
    Write-Host 'Git and GitHub CLI are ready.'
    return
}
& $taskGhPath auth login --hostname github.com --git-protocol https --web --scopes workflow
if ($LASTEXITCODE) { throw 'GitHub login did not complete.' }
& $taskGhPath auth status --hostname github.com
if ($LASTEXITCODE) { throw 'GitHub authentication could not be verified.' }
Write-Host 'GitHub login completed. Return to the chat to finish publishing connect-smarter.'
