$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceDir = Join-Path $ScriptDir "pets"
$CodexRoot = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$TargetDir = Join-Path $CodexRoot "pets"

if (-not (Test-Path -LiteralPath $SourceDir -PathType Container)) {
    throw "Pet source directory not found: $SourceDir"
}

New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
$Installed = 0

Get-ChildItem -LiteralPath $SourceDir -Directory | ForEach-Object {
    $PetDir = $_.FullName
    $PetId = $_.Name
    $PetJson = Join-Path $PetDir "pet.json"
    $Spritesheet = Join-Path $PetDir "spritesheet.webp"

    if (-not (Test-Path -LiteralPath $PetJson -PathType Leaf) -or
        -not (Test-Path -LiteralPath $Spritesheet -PathType Leaf)) {
        throw "Incomplete pet package: $PetDir"
    }

    $Destination = Join-Path $TargetDir $PetId
    New-Item -ItemType Directory -Force -Path $Destination | Out-Null
    Copy-Item -LiteralPath $PetJson -Destination (Join-Path $Destination "pet.json") -Force
    Copy-Item -LiteralPath $Spritesheet -Destination (Join-Path $Destination "spritesheet.webp") -Force
    Write-Host "Installed $PetId"
    $Installed++
}

if ($Installed -eq 0) {
    throw "No pet packages were found in $SourceDir"
}

Write-Host "Installed $Installed Codex pets into $TargetDir"
Write-Host "Restart Codex to reload the custom-pet list."

