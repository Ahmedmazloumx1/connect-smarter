# Push the reviewed main branch using the user's normal Windows credential store.
$ErrorActionPreference = 'Stop'
$taskProjectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$taskBundledWork = Join-Path (Split-Path $taskProjectRoot -Parent) '2026-09-16\ah-2\work'
$taskRepo = 'Ahmedmazloumx1/connect-smarter'
$taskRepoUrl = 'https://github.com/' + $taskRepo
$taskExpectedRemote = $taskRepoUrl + '.git'

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
    throw 'Install the official GitHub CLI from https://cli.github.com/ first.'
}
if (Test-Path -LiteralPath (Join-Path $taskBundledWork 'github-auth\hosts.yml')) {
    $env:GH_CONFIG_DIR = Join-Path $taskBundledWork 'github-auth'
}
$taskBuildDirectory = Join-Path $taskProjectRoot 'build'
New-Item -ItemType Directory -Path $taskBuildDirectory -Force | Out-Null
Start-Transcript -LiteralPath (Join-Path $taskBuildDirectory 'github-publish.log') -Append | Out-Null
Push-Location $taskProjectRoot
try {
    $taskLogin = & $taskGhPath api user --jq '.login'
    if ($LASTEXITCODE) {
        throw 'GitHub authentication could not be read. Run scripts/connect-github.ps1 in this PowerShell window first.'
    }
    if ($taskLogin.Trim() -cne 'Ahmedmazloumx1') {
        throw 'The signed-in account is not the approved repository owner Ahmedmazloumx1.'
    }
    $taskVisibility = & $taskGhPath api ('repos/' + $taskRepo) --jq '.visibility'
    if ($LASTEXITCODE -or $taskVisibility.Trim() -ne 'public') {
        throw 'The expected public repository could not be verified.'
    }
    $taskBranch = git branch --show-current
    if ($LASTEXITCODE -or $taskBranch.Trim() -ne 'main') {
        throw 'The reviewed main branch is not checked out. Return to the chat before publishing.'
    }
    $taskRemote = git remote get-url origin
    if ($LASTEXITCODE -or $taskRemote.Trim() -ne $taskExpectedRemote) {
        throw 'The origin remote differs from the approved repository. Nothing was pushed.'
    }
    $taskChanges = git status --porcelain
    if ($LASTEXITCODE) { throw 'Git status failed.' }
    if ($taskChanges) {
        throw 'Uncommitted changes were found. Return to the chat so they can be reviewed before publishing.'
    }
    $taskLocalHead = git rev-parse HEAD
    if ($LASTEXITCODE) { throw 'The prepared local commit was not found.' }

    # Use GitHub CLI credentials for this push only; do not change global Git settings.
    $taskPreviousPath = $env:PATH
    try {
        $env:PATH = (Split-Path $taskGhPath -Parent) + ';' + $env:PATH
        git -c credential.helper= -c 'credential.helper=!gh auth git-credential' push --set-upstream origin main
        $taskPushExitCode = $LASTEXITCODE
    } finally {
        $env:PATH = $taskPreviousPath
    }
    if ($taskPushExitCode) { throw 'Git push failed. Inspect build/github-publish.log.' }
    $taskRemoteHead = & $taskGhPath api ('repos/' + $taskRepo + '/commits/main') --jq '.sha'
    if ($LASTEXITCODE -or $taskRemoteHead.Trim() -ne $taskLocalHead.Trim()) {
        throw 'The remote commit could not be matched to the reviewed local commit.'
    }
    @{
        repository = $taskRepoUrl
        visibility = 'public'
        branch = 'main'
        commit = $taskLocalHead.Trim()
        verifiedAt = (Get-Date).ToString('o')
    } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $taskBuildDirectory 'github-publication.json')
    Write-Host ('GitHub publication completed: ' + $taskRepoUrl)
    Write-Host ('Verified commit: ' + $taskLocalHead.Trim())
    Write-Host 'Return to the chat so the source and GitHub Actions results can be checked.'
} finally {
    Pop-Location
    Stop-Transcript | Out-Null
}
