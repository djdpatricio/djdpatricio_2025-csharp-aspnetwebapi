<#
.SYNOPSIS
Create a JWT for local development, signed with the Authentication settings in DJDPatricio.IMS.API/appsettings.Development.json.

.PARAMETER Days     How long the token stays valid. Default 7.
.PARAMETER UserId   The sub claim, read by the API as the user id. Default 500329.
.PARAMETER Name     The name claim. Default John Doe.
.PARAMETER Role     The role claim. Default Sales Agent.

.EXAMPLE
pwsh scripts/new-dev-token.ps1
pwsh scripts/new-dev-token.ps1 -Days 30 -Name "Maria Santos"
#>
param(
    [int] $Days = 7,
    [string] $UserId = '500329',
    [string] $Name = 'John Doe',
    [string] $Role = 'Sales Agent'
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$settingsPath = Join-Path $repo 'DJDPatricio.IMS.API\appsettings.Development.json'
$auth = (Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json).Authentication

function ConvertTo-Base64Url {
    param([byte[]] $Bytes)
    [Convert]::ToBase64String($Bytes).TrimEnd('=').Replace('+', '-').Replace('/', '_')
}

$header = [ordered]@{ alg = 'HS256'; typ = 'JWT' } | ConvertTo-Json -Compress
$payload = [ordered]@{
    sub  = $UserId
    name = $Name
    role = $Role
    iss  = $auth.Issuer
    aud  = $auth.Audience
    exp  = [DateTimeOffset]::UtcNow.AddDays($Days).ToUnixTimeSeconds()
} | ConvertTo-Json -Compress

$encodedHeader = ConvertTo-Base64Url ([Text.Encoding]::UTF8.GetBytes($header))
$encodedPayload = ConvertTo-Base64Url ([Text.Encoding]::UTF8.GetBytes($payload))
$unsigned = "$encodedHeader.$encodedPayload"

$hmac = [Security.Cryptography.HMACSHA256]::new([Text.Encoding]::UTF8.GetBytes($auth.JwtKey))
$signature = ConvertTo-Base64Url $hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($unsigned))
$hmac.Dispose()

"$unsigned.$signature"
