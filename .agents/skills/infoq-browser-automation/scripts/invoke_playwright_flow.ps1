param(
    [Parameter(Mandatory = $true)]
    [string]$Url,
    [string]$StorageKey = "Admin-Token",
    [string]$StorageValue = "",
    [string]$WaitForText = "",
    [string]$WaitForUrl = "",
    [string]$ScreenshotPath = "",
    [string]$ConsoleLogPath = "",
    [int]$TimeoutMs = 45000,
    [switch]$Headed,
    [switch]$IgnoreHttpsErrors,
    [switch]$AllowConsoleErrors
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $scriptDir "..\..\..\.."))

$pnpmCommand = Get-Command pnpm.cmd -ErrorAction SilentlyContinue
if (-not $pnpmCommand) {
    throw "pnpm.cmd is required but was not found in PATH."
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
if (-not $ScreenshotPath) {
    $ScreenshotPath = Join-Path $repoRoot "test-results\browser-automation\$timestamp.png"
}
if (-not $ConsoleLogPath) {
    $ConsoleLogPath = Join-Path $repoRoot "test-results\browser-automation\$timestamp.console.json"
}

Write-Host "[browser-flow] url: $Url"
Write-Host "[browser-flow] screenshot: $ScreenshotPath"
Write-Host "[browser-flow] console log: $ConsoleLogPath"

$arguments = @(
    "run", "playwright-cli", "flow",
    "--url", $Url,
    "--storage-key", $StorageKey,
    "--timeout-ms", [string]$TimeoutMs,
    "--screenshot-path", $ScreenshotPath,
    "--console-log-path", $ConsoleLogPath
)

if ($StorageValue) {
    $arguments += @("--storage-value", $StorageValue)
}
if ($WaitForText) {
    $arguments += @("--wait-for-text", $WaitForText)
}
if ($WaitForUrl) {
    $arguments += @("--wait-for-url", $WaitForUrl)
}
if ($Headed) {
    $arguments += "--headed"
}
if ($IgnoreHttpsErrors) {
    $arguments += "--ignore-https-errors"
}
if ($AllowConsoleErrors) {
    $arguments += "--allow-console-errors"
}

Push-Location $scriptDir
try {
    & $pnpmCommand.Source @arguments
}
finally {
    Pop-Location
}

if ($LASTEXITCODE -ne 0) {
    throw "Playwright flow failed with exit code $LASTEXITCODE. Ensure dependencies are installed via 'pnpm --dir .agents/skills/infoq-browser-automation/scripts install' and install Chromium via 'pnpm --dir .agents/skills/infoq-browser-automation/scripts exec playwright install chromium'."
}

Write-Host "[browser-flow] completed successfully"
