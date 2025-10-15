#!/usr/bin/env pwsh

# Consolidated prerequisite checking script (PowerShell) for Spec-Driven Writing
[CmdletBinding()]
param(
    [switch]$Json,
    [switch]$RequireScenes,
    [switch]$IncludeScenes,
    [switch]$PathsOnly,
    [switch]$Help
)
$ErrorActionPreference = 'Stop'

if ($Help) {
    Write-Output @"
Usage: check-prerequisites.ps1 [OPTIONS]

Consolidated prerequisite checking for Spec-Driven Writing workflow.

OPTIONS:
  -Json               Output in JSON format
  -RequireScenes      Require scenes.md to exist (for writing phase)
  -IncludeScenes      Include scenes.md in AVAILABLE_DOCS list
  -PathsOnly          Only output path variables (no prerequisite validation)
  -Help, -h           Show this help message
"@
    exit 0
}

. "$PSScriptRoot/common.ps1"

$paths = Get-NarrativePathsEnv

if (-not (Test-NarrativeBranch -Narrative $paths.CURRENT_NARRATIVE -HasGit:$paths.HAS_GIT)) { 
    exit 1 
}

if ($PathsOnly) {
    if ($Json) {
        [PSCustomObject]@{
            PROJECT_ROOT       = $paths.PROJECT_ROOT
            NARRATIVE_NAME     = $paths.CURRENT_NARRATIVE
            NARRATIVE_DIR      = $paths.NARRATIVE_DIR
            NARRATIVE_SPEC     = $paths.NARRATIVE_SPEC
            NARRATIVE_OUTLINE  = $paths.NARRATIVE_OUTLINE
            SCENES             = $paths.SCENES
        } | ConvertTo-Json -Compress
    } else {
        Write-Output "PROJECT_ROOT: $($paths.PROJECT_ROOT)"
        Write-Output "NARRATIVE_NAME: $($paths.CURRENT_NARRATIVE)"
        Write-Output "NARRATIVE_DIR: $($paths.NARRATIVE_DIR)"
        Write-Output "NARRATIVE_SPEC: $($paths.NARRATIVE_SPEC)"
        Write-Output "NARRATIVE_OUTLINE: $($paths.NARRATIVE_OUTLINE)"
        Write-Output "SCENES: $($paths.SCENES)"
    }
    exit 0
}

if (-not (Test-Path $paths.NARRATIVE_DIR -PathType Container)) {
    Write-Output "ERROR: Narrative directory not found: $($paths.NARRATIVE_DIR)"
    Write-Output "Run /narrative.specify first to create the narrative structure."
    exit 1
}

if (-not (Test-Path $paths.NARRATIVE_OUTLINE -PathType Leaf)) {
    Write-Output "ERROR: narrative-outline.md not found in $($paths.NARRATIVE_DIR)"
    Write-Output "Run /narrative.plan first to create the outline."
    exit 1
}

if ($RequireScenes -and -not (Test-Path $paths.SCENES -PathType Leaf)) {
    Write-Output "ERROR: scenes.md not found in $($paths.NARRATIVE_DIR)"
    Write-Output "Run /narrative.tasks first to create the scene list."
    exit 1
}

$docs = @()
if (Test-Path $paths.RESEARCH_NOTES) { $docs += 'research-notes.md' }
if (Test-Path $paths.CHARACTER_MODEL) { $docs += 'character-model.md' }
if (Test-Path $paths.QUICKSTART) { $docs += 'quickstart.md' }
if ($IncludeScenes -and (Test-Path $paths.SCENES)) { 
    $docs += 'scenes.md' 
}

if ($Json) {
    [PSCustomObject]@{ 
        NARRATIVE_DIR = $paths.NARRATIVE_DIR
        AVAILABLE_DOCS = $docs 
    } | ConvertTo-Json -Compress
} else {
    Write-Output "NARRATIVE_DIR:$($paths.NARRATIVE_DIR)"
    Write-Output "AVAILABLE_DOCS:"
    Test-FileExists -Path $paths.RESEARCH_NOTES -Description 'research-notes.md' | Out-Null
    Test-FileExists -Path $paths.CHARACTER_MODEL -Description 'character-model.md' | Out-Null
    Test-FileExists -Path $paths.QUICKSTART -Description 'quickstart.md' | Out-Null
    
    if ($IncludeScenes) {
        Test-FileExists -Path $paths.SCENES -Description 'scenes.md' | Out-Null
    }
}
