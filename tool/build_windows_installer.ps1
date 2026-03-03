param(
    [string]$Version = "",
    [string]$Publisher = "RRHH App Team"
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
$releaseDir = Join-Path $projectRoot "build\windows\x64\runner\Release"
$distDir = Join-Path $projectRoot "dist"
$issPath = Join-Path $projectRoot "installer\rrhh_app.iss"

Push-Location $projectRoot
try {
    Write-Host "==> Building Windows release..."
    $flutterArgs = @("build", "windows", "--release", "--build-name=$resolvedVersion")
    & flutter @flutterArgs

    if (-not (Test-Path $releaseDir)) {
        throw "No se encontro la carpeta de build: $releaseDir"
    }

    if (-not (Test-Path $distDir)) {
        New-Item -ItemType Directory -Path $distDir | Out-Null
    }

    $iscc = Resolve-IsccPath
    if ($iscc) {
        Write-Host "==> Generating installer with Inno Setup..."
        & $iscc $issPath "/DMyAppVersion=$resolvedVersion" "/DMyAppPublisher=$Publisher"
        Write-Host "Instalador generado en: $distDir"
    }
    else {
        $zipPath = Join-Path $distDir "rrhh_app_windows_portable_$resolvedVersion.zip"
        if (Test-Path $zipPath) {
            Remove-Item $zipPath -Force
        }

        Write-Host "==> Inno Setup no esta instalado. Generating portable ZIP..."
        Compress-Archive -Path (Join-Path $releaseDir '*') -DestinationPath $zipPath -CompressionLevel Optimal
        Write-Host "ZIP portable generado en: $zipPath"
        Write-Host "Para instalador .exe, instala Inno Setup y vuelve a ejecutar este script."
    }
}
finally {
    Pop-Location
}
