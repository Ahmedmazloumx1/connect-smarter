# Complete GitHub's official browser/device login on the user's PC.
$ErrorActionPreference = 'Stop'
$taskProjectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$taskBundledWork = Join-Path (Split-Path $taskProjectRoot -Parent) '2026-09-16\ah-2\work'
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
& $taskGhPath auth login --hostname github.com --git-protocol https --web --scopes workflow
if ($LASTEXITCODE) { throw 'GitHub login did not complete.' }
& $taskGhPath auth status --hostname github.com
if ($LASTEXITCODE) { throw 'GitHub authentication could not be verified.' }
Write-Host 'GitHub login completed. Return to the chat to finish publishing connect-smarter.'
