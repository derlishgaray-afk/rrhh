param(
    [string]$Version = "",
    [string]$Publisher = "RRHH App Team",
    [string]$DbHost = "192.168.108.200",
    [int]$Port = 5432,
    [string]$Database = "rrhh",
    [string]$User = "rrhh_app",
    [string]$Password = "rrhh2026",
    [string]$SslMode = "disable"
)

$ErrorActionPreference = "Stop"

function Resolve-ProjectVersion {
    param([string]$PubspecPath)

    $line = Select-String -Path $PubspecPath -Pattern '^\s*version:\s*([0-9]+\.[0-9]+\.[0-9]+)' | Select-Object -First 1
    if (-not $line) {
        throw "No se pudo leer la version desde pubspec.yaml."
    }

    return $line.Matches[0].Groups[1].Value
}

function Resolve-IsccPath {
    $cmd = Get-Command iscc -ErrorAction SilentlyContinue
    if ($cmd) {
        return $cmd.Source
    }

    $candidates = @(
        (Join-Path $env:LOCALAPPDATA "Programs\Inno Setup 6\ISCC.exe"),
        (Join-Path $env:ProgramFiles "Inno Setup 6\ISCC.exe"),
        (Join-Path ${env:ProgramFiles(x86)} "Inno Setup 6\ISCC.exe")
    )

    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path $candidate)) {
            return $candidate
        }
    }

    return $null
}

$projectRoot = Split-Path -Parent $PSScriptRoot
$pubspecPath = Join-Path $projectRoot "pubspec.yaml"
$resolvedVersion = if ([string]::IsNullOrWhiteSpace($Version)) { Resolve-ProjectVersion -PubspecPath $pubspecPath } else { $Version }
$distDir = Join-Path $projectRoot "dist"
$issPath = Join-Path $projectRoot "installer\rrhh_app.iss"
$outputName = "rrhh_app_setup_server_$resolvedVersion"

Push-Location $projectRoot
try {
    Write-Host "==> Building Windows release (server mode)..."
    $flutterArgs = @(
        "build",
        "windows",
        "--release",
        "--build-name=$resolvedVersion",
        "--dart-define=DB_MODE=postgres",
        "--dart-define=DB_HOST=$DbHost",
        "--dart-define=DB_PORT=$Port",
        "--dart-define=DB_NAME=$Database",
        "--dart-define=DB_USER=$User",
        "--dart-define=DB_PASSWORD=$Password",
        "--dart-define=DB_SSL_MODE=$SslMode"
    )
    & flutter @flutterArgs

    if (-not (Test-Path $distDir)) {
        New-Item -ItemType Directory -Path $distDir | Out-Null
    }

    $iscc = Resolve-IsccPath
    if (-not $iscc) {
        throw "No se encontro ISCC.exe. Instala Inno Setup para generar el instalador .exe."
    }

    Write-Host "==> Generating server installer with Inno Setup..."
    & $iscc $issPath "/DMyAppVersion=$resolvedVersion" "/DMyAppPublisher=$Publisher" "/DMyOutputBaseFilename=$outputName"
    Write-Host "Instalador generado en: $distDir"
}
finally {
    Pop-Location
}
