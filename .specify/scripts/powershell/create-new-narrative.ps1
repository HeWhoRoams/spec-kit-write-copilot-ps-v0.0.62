#!/usr/bin/env pwsh
# Create a new narrative project
[CmdletBinding()]
param(
    [switch]$Json,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$NarrativeDescription
)
$ErrorActionPreference = 'Stop'

if (-not $NarrativeDescription -or $NarrativeDescription.Count -eq 0) {
    Write-Error "Usage: ./create-new-narrative.ps1 [-Json] <narrative description>"
    exit 1
}
$narrativeDesc = ($NarrativeDescription -join ' ').Trim()

# Resolve project root.
function Find-ProjectRoot {
    param(
        [string]$StartDir,
        [string[]]$Markers = @('.git', '.specify')
    )
    $current = Resolve-Path $StartDir
    while ($true) {
        foreach ($marker in $Markers) {
            if (Test-Path (Join-Path $current $marker)) {
                return $current
            }
        }
        $parent = Split-Path $current -Parent
        if ($parent -eq $current) {
            # Reached filesystem root without finding markers
            return $null
        }
        $current = $parent
    }
}
$fallbackRoot = (Find-ProjectRoot -StartDir $PSScriptRoot)
if (-not $fallbackRoot) {
    Write-Error "Error: Could not determine project root. Please run this script from within the project."
    exit 1
}

try {
    $projectRoot = git rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -eq 0) {
        $hasGit = $true
    } else {
        throw "Git not available"
    }
} catch {
    $projectRoot = $fallbackRoot
    $hasGit = $false
}

Set-Location $projectRoot

$narrativesDir = Join-Path $projectRoot 'narratives'
New-Item -ItemType Directory -Path $narrativesDir -Force | Out-Null

$highest = 0
if (Test-Path $narrativesDir) {
    Get-ChildItem -Path $narrativesDir -Directory | ForEach-Object {
        if ($_.Name -match '^(\d{3})') {
            $num = [int]$matches[1]
            if ($num -gt $highest) { $highest = $num }
        }
    }
}
$next = $highest + 1
$narrativeNum = ('{0:000}' -f $next)

$branchName = $narrativeDesc.ToLower() -replace '[^a-z0-9]', '-' -replace '-{2,}', '-' -replace '^-', '' -replace '-$', ''
$words = ($branchName -split '-') | Where-Object { $_ } | Select-Object -First 3
$narrativeName = "$narrativeNum-$([string]::Join('-', $words))"

if ($hasGit) {
    try {
        git checkout -b $narrativeName | Out-Null
    } catch {
        Write-Warning "Failed to create git branch: $narrativeName"
    }
} else {
    Write-Warning "[specify] Warning: Git repository not detected; skipped branch creation for $narrativeName"
}

$narrativeDir = Join-Path $narrativesDir $narrativeName
New-Item -ItemType Directory -Path $narrativeDir -Force | Out-Null

$template = Join-Path $projectRoot '.specify/templates/narrative-spec-template.md'
$specFile = Join-Path $narrativeDir 'narrative-spec.md'
if (Test-Path $template) { 
    Copy-Item $template $specFile -Force 
} else { 
    New-Item -ItemType File -Path $specFile | Out-Null 
}

# Set the SDW_NARRATIVE environment variable for the current session
$env:SDW_NARRATIVE = $narrativeName

if ($Json) {
    $obj = [PSCustomObject]@{ 
        NARRATIVE_NAME = $narrativeName
        SPEC_FILE = $specFile
        NARRATIVE_NUM = $narrativeNum
        HAS_GIT = $hasGit
    }
    $obj | ConvertTo-Json -Compress
} else {
    Write-Output "NARRATIVE_NAME: $narrativeName"
    Write-Output "SPEC_FILE: $specFile"
    Write-Output "NARRATIVE_NUM: $narrativeNum"
    Write-Output "HAS_GIT: $hasGit"
    Write-Output "SDW_NARRATIVE environment variable set to: $narrativeName"
}
