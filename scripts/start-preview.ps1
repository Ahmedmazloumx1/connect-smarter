$ErrorActionPreference = 'Stop'
$taskRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$taskWeb = Join-Path $taskRoot 'build\web'
$taskWork = Join-Path (Split-Path $taskRoot -Parent) '2026-09-16\ah-2\work'
if (!(Test-Path -LiteralPath (Join-Path $taskWeb 'main.dart.js'))) {
    throw 'Run scripts/build-live-web.ps1 successfully first.'
}
$taskPython = Join-Path $taskRoot '.venv\Scripts\python.exe'
if (!(Test-Path -LiteralPath $taskPython)) {
    $taskPython = Join-Path $taskWork 'venv\Scripts\python.exe'
}
if (!(Test-Path -LiteralPath $taskPython)) {
    throw 'Create the Python .venv and install requirements.txt as described in README.md.'
}
$taskLogs = Join-Path $taskRoot 'build\preview-logs'
New-Item -ItemType Directory -Path $taskLogs -Force | Out-Null
$taskOwnedProcesses = @()
try {
    foreach ($taskPort in @(3000,8000)) {
        if (Get-NetTCPConnection -LocalPort $taskPort -State Listen -ErrorAction SilentlyContinue) {
            throw "Port $taskPort is already in use. Close its existing preview/service and rerun."
        }
    }
    $taskApi = Start-Process -FilePath $taskPython -ArgumentList @('-m','uvicorn','api:app','--host','127.0.0.1','--port','8000') -WorkingDirectory $taskRoot -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $taskLogs 'api.out.log') -RedirectStandardError (Join-Path $taskLogs 'api.err.log')
    $taskOwnedProcesses += $taskApi
    $taskServer = Start-Process -FilePath $taskPython -ArgumentList @('-m','http.server','3000','--bind','127.0.0.1','--directory',('"' + $taskWeb + '"')) -WorkingDirectory $taskRoot -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $taskLogs 'web.out.log') -RedirectStandardError (Join-Path $taskLogs 'web.err.log')
    $taskOwnedProcesses += $taskServer
    $taskReady = $false
    for ($taskAttempt=0; $taskAttempt -lt 30; $taskAttempt++) {
        try {
            $taskHealth = Invoke-RestMethod 'http://127.0.0.1:8000/health' -TimeoutSec 2
            $taskPage = Invoke-WebRequest 'http://127.0.0.1:3000/' -UseBasicParsing -TimeoutSec 2
            if ($taskHealth.status -eq 'ok' -and $taskPage.StatusCode -eq 200) { $taskReady = $true; break }
        } catch { Start-Sleep -Milliseconds 500 }
    }
    if (!$taskReady) { throw 'Preview did not start. Inspect build/preview-logs for errors.' }
    @{
        project='connect-smarter-ahmed-2026'
        url='http://localhost:3000/'
        api='http://127.0.0.1:8000/health'
        processIds=@($taskApi.Id,$taskServer.Id)
        startedAt=(Get-Date).ToString('o')
    } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $taskRoot 'build\preview-ready.json')
    Write-Host 'Connect Smarter is running: http://localhost:3000/'
    Write-Host 'CV API is running: http://127.0.0.1:8000/health'
    Write-Host 'The two local services run in the background. Sign in or create your own account to get started.'
} catch {
    foreach ($taskProcess in $taskOwnedProcesses) {
        if (!$taskProcess.HasExited) { $taskProcess.Kill() }
    }
    throw
}
