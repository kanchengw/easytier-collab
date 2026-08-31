[CmdletBinding()]
param(
    [string]$RuntimeDirectory = (Join-Path $PSScriptRoot '..\..\artifacts\easytier-windows-x86_64-v2.6.4-collab.1\easytier-windows-x86_64'),
    [string]$Dumpbin = 'dumpbin.exe'
)

$ErrorActionPreference = 'Stop'
$runtimeDirectory = (Resolve-Path $RuntimeDirectory).Path
if (Test-Path -LiteralPath (Join-Path $runtimeDirectory 'Packet.dll')) {
    throw 'Packet.dll must not be distributed with the Collab no-TUN runtime'
}

foreach ($name in @('easytier-core.exe', 'easytier-cli.exe')) {
    $executable = Join-Path $runtimeDirectory $name
    if (-not (Test-Path -LiteralPath $executable -PathType Leaf)) {
        throw "Missing runtime executable: $name"
    }

    $dependencies = & $Dumpbin /nologo /dependents $executable 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "dumpbin failed for $name with exit code $LASTEXITCODE"
    }
    if (($dependencies | Out-String) -match '(?i)Packet\.dll') {
        throw "$name still imports Packet.dll"
    }

    $version = & $executable --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "$name failed without Packet.dll with exit code $LASTEXITCODE"
    }
    Write-Output "$name`t$version"
}
