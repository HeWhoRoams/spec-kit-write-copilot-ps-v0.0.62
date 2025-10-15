#!/usr/bin/env pwsh
# Setup narrative outline for a project

[CmdletBinding()]
param(
    [switch]$Json,
    [switch]$Help
)

$ErrorActionPreference = 'Stop'

if ($Help) {
    Write-Output "Usage: ./setup-outline.ps1 [-Json] [-Help]"
    Write-Output "  -Json     Output results in JSON format"
    Write-Output "  -Help     Show this help message"
    exit 0
}

. "$PSScriptRoot/common.ps1"

$paths = Get-NarrativePathsEnv

if (-not (Test-NarrativeBranch -Narrative $paths.CURRENT_NARRATIVE -HasGit:$paths.HAS_GIT)) { 
    exit 1 
}

New-Item -ItemType Directory -Path $paths.NARRATIVE_DIR -Force | Out-Null

$template = Join-Path $paths.PROJECT_ROOT '.specify/templates/narrative.plan-template.md'
if (Test-Path $template) { 
    Copy-Item $template $paths.NARRATIVE_OUTLINE -Force
    Write-Output "Copied narrative outline template to $($paths.NARRATIVE_OUTLINE)"
} else {
    Write-Warning "Narrative outline template not found at $template"
    New-Item -ItemType File -Path $paths.NARRATIVE_OUTLINE -Force | Out-Null
}

if ($Json) {
    $result = [PSCustomObject]@{ 
        NARRATIVE_SPEC = $paths.NARRATIVE_SPEC
        NARRATIVE_OUTLINE = $paths.NARRATIVE_OUTLINE
        NARRATIVES_DIR = $paths.NARRATIVE_DIR
        NARRATIVE = $paths.CURRENT_NARRATIVE
        HAS_GIT = $paths.HAS_GIT
    }
    $result | ConvertTo-Json -Compress
} else {
    Write-Output "NARRATIVE_SPEC: $($paths.NARRATIVE_SPEC)"
    Write-Output "NARRATIVE_OUTLINE: $($paths.NARRATIVE_OUTLINE)"
    Write-Output "NARRATIVES_DIR: $($paths.NARRATIVES_DIR)"
    Write-Output "NARRATIVE: $($paths.CURRENT_NARRATIVE)"
    Write-Output "HAS_GIT: $($paths.HAS_GIT)"
}
