<#
.SYNOPSIS
Run the IMS API locally on SQL Server LocalDB in one command: create the djdpatricio_ims database if it is missing,
print a development token, start the API and open Swagger.

.PARAMETER ResetDatabase  Drop djdpatricio_ims and recreate it from Database/djdpatricio_ims.sql first.
.PARAMETER Port           HTTP port for the API. Default 5212.
.PARAMETER NoBrowser      Do not open Swagger in the browser.

.EXAMPLE
pwsh scripts/run-local.ps1
pwsh scripts/run-local.ps1 -ResetDatabase
#>
param(
    [switch] $ResetDatabase,
    [int] $Port = 5212,
    [switch] $NoBrowser
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$server = '(localdb)\MSSQLLocalDB'
$database = 'djdpatricio_ims'

foreach ($tool in 'dotnet', 'sqlcmd', 'sqllocaldb') {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        throw "$tool was not found. Install the .NET SDK, Sqlcmd and SQL Server LocalDB first (see README Requirements)."
    }
}

& sqllocaldb start MSSQLLocalDB | Out-Null

if ($ResetDatabase) {
    Write-Host "Dropping $database"
    & sqlcmd -S $server -E -b -Q "IF DB_ID('$database') IS NOT NULL BEGIN ALTER DATABASE [$database] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [$database]; END" | Out-Null
}

$exists = (& sqlcmd -S $server -E -h -1 -W -Q "SET NOCOUNT ON; SELECT CASE WHEN DB_ID('$database') IS NULL THEN 0 ELSE 1 END" | Out-String).Trim()
if ($exists -ne '1') {
    Write-Host "Creating $database from Database\djdpatricio_ims.sql"
    & sqlcmd -S $server -E -b -I -i (Join-Path $repo 'Database\djdpatricio_ims.sql') | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'The database script failed. Run it by hand to see the error.' }
}

$env:ConnectionStrings__DefaultConnection = "Server=$server;Database=$database;Trusted_Connection=True;TrustServerCertificate=True;"
$env:DOTNET_ROLL_FORWARD = 'Major'
$env:ASPNETCORE_ENVIRONMENT = 'Development'

$swagger = "http://localhost:$Port/swagger"
$token = & (Join-Path $PSScriptRoot 'new-dev-token.ps1')

Write-Host ''
Write-Host "Swagger:  $swagger"
Write-Host 'Token (valid 7 days). In Swagger click Authorize and paste it without the word Bearer:'
Write-Host $token
Write-Host ''

if (-not $NoBrowser) {
    Start-Job -ScriptBlock { param($url) Start-Sleep -Seconds 10; Start-Process $url } -ArgumentList $swagger | Out-Null
}

dotnet run --project (Join-Path $repo 'DJDPatricio.IMS.API') --urls "http://localhost:$Port"
