[CmdletBinding()]
param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '..\..\artifacts')
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$target = 'x86_64-pc-windows-msvc'
$features = @(
    'wireguard',
    'websocket',
    'smoltcp',
    'socks5',
    'kcp',
    'quic',
    'magic-dns',
    'zstd',
    'mimalloc'
) -join ','

Push-Location $repositoryRoot
try {
    $dependencyTree = cargo tree --locked --target $target --package easytier --no-default-features --features $features --prefix none --format '{p}' 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "EasyTier dependency tree failed with exit code $LASTEXITCODE"
    }
    if (($dependencyTree | Out-String) -match '(?m)^pnet(?:_datalink)? v') {
        throw 'Collab Windows no-TUN dependency graph must not contain pnet or pnet_datalink'
    }

    cargo build --locked --release --target $target --package easytier --bins --no-default-features --features $features
    if ($LASTEXITCODE -ne 0) {
        throw "EasyTier build failed with exit code $LASTEXITCODE"
    }

    $artifactName = 'easytier-windows-x86_64-v2.6.4-collab.1'
    $stagingDirectory = Join-Path $OutputDirectory $artifactName
    $runtimeDirectory = Join-Path $stagingDirectory 'easytier-windows-x86_64'
    New-Item -ItemType Directory -Path $runtimeDirectory -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $repositoryRoot "target\$target\release\easytier-core.exe") -Destination $runtimeDirectory
    Copy-Item -LiteralPath (Join-Path $repositoryRoot "target\$target\release\easytier-cli.exe") -Destination $runtimeDirectory

    $archivePath = Join-Path $OutputDirectory "$artifactName.zip"
    Compress-Archive -LiteralPath $runtimeDirectory -DestinationPath $archivePath -CompressionLevel Optimal -Force
    Write-Output $archivePath
}
finally {
    Pop-Location
}
