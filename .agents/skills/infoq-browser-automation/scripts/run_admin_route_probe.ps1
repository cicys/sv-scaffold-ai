param(
    [string]$FrontendOrigin,
    [string]$Route = "/index",
    [string]$BackendUrl = "http://127.0.0.1:8080",
    [string]$ClientId = "e5cd7e4891bf95d1d19206ce24a7b32e",
    [string]$Username = "",
    [string]$Password = "",
    [string]$WaitForText = "",
    [string]$ScreenshotPath = "",
    [string]$ConsoleLogPath = "",
    [int]$TimeoutMs = 45000,
    [switch]$ListRoutes,
    [switch]$Headed,
    [switch]$AllowConsoleErrors
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$pnpmCommand = Get-Command pnpm.cmd -ErrorAction SilentlyContinue
if (-not $pnpmCommand) {
    throw "pnpm.cmd is required but was not found in PATH."
}

if (-not $ListRoutes -and -not $FrontendOrigin) {
    throw "FrontendOrigin is required unless -ListRoutes is used."
}

$arguments = @(
    "run", "playwright-cli", "admin-route-probe",
    "--backend-url", $BackendUrl,
    "--client-id", $ClientId,
    "--route", $Route,
    "--timeout-ms", [string]$TimeoutMs
)

if ($FrontendOrigin) {
    $arguments += @("--frontend-origin", $FrontendOrigin)
}
if ($Username) {
    $arguments += @("--username", $Username)
}
if ($Password) {
    $arguments += @("--password", $Password)
}
if ($WaitForText) {
    $arguments += @("--wait-for-text", $WaitForText)
}
if ($ScreenshotPath) {
    $arguments += @("--screenshot-path", $ScreenshotPath)
}
if ($ConsoleLogPath) {
    $arguments += @("--console-log-path", $ConsoleLogPath)
}
if ($ListRoutes) {
    $arguments += "--list-routes"
}
if ($Headed) {
    $arguments += "--headed"
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
    throw "Admin route probe failed."
}
