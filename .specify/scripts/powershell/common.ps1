#!/usr/bin/env pwsh
# Common PowerShell functions for Spec-Driven Writing

function Get-ProjectRoot {
    try {
        $result = git rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -eq 0) {
            return $result
        }
    } catch {
        # Git command failed
    }
    
    return (Resolve-Path (Join-Path $PSScriptRoot "../../..")).Path
}

function Get-CurrentNarrative {
    if ($env:SDW_NARRATIVE) {
        return $env:SDW_NARRATIVE
    }
    
    $projectRoot = Get-ProjectRoot
    $narrativesDir = Join-Path $projectRoot "narratives"
    
    if (Test-Path $narrativesDir) {
        $latestNarrative = ""
        $highest = 0
        
        Get-ChildItem -Path $narrativesDir -Directory | ForEach-Object {
            if ($_.Name -match '^(\d{3})-') {
                $num = [int]$matches[1]
                if ($num -gt $highest) {
                    $highest = $num
                    $latestNarrative = $_.Name
                }
            }
        }
        
        if ($latestNarrative) {
            return $latestNarrative
        }
    }
    
    return "main"
}

function Test-HasGit {
    try {
        git rev-parse --show-toplevel 2>$null | Out-Null
        return ($LASTEXITCODE -eq 0)
    } catch {
        return $false
    }
}

function Test-NarrativeBranch {
    param(
        [string]$Narrative,
        [bool]$HasGit = $true
    )
    
    if (-not $HasGit) {
        Write-Warning "[specify] Warning: Git repository not detected; skipped branch validation"
        return $true
    }
    
    if ($Narrative -notmatch '^[0-9]{3}-') {
        Write-Output "ERROR: Not on a narrative branch. Current branch: $Narrative"
        Write-Output "Narrative branches should be named like: 001-narrative-name"
        return $false
    }
    return $true
}

function Get-NarrativeDir {
    param([string]$ProjectRoot, [string]$Narrative)
    Join-Path $ProjectRoot "narratives/$Narrative"
}

function Get-NarrativePathsEnv {
    $projectRoot = Get-ProjectRoot
    $currentNarrative = Get-CurrentNarrative
    $hasGit = Test-HasGit
    $narrativeDir = Get-NarrativeDir -ProjectRoot $projectRoot -Narrative $currentNarrative
    
    [PSCustomObject]@{
        PROJECT_ROOT       = $projectRoot
        CURRENT_NARRATIVE  = $currentNarrative
        HAS_GIT            = $hasGit
        NARRATIVE_DIR      = $narrativeDir
        NARRATIVE_SPEC     = Join-Path $narrativeDir 'narrative-spec.md'
        NARRATIVE_OUTLINE  = Join-Path $narrativeDir 'narrative-outline.md'
        SCENES             = Join-Path $narrativeDir 'scenes.md'
        RESEARCH_NOTES     = Join-Path $narrativeDir 'research-notes.md'
        CHARACTER_MODEL    = Join-Path $narrativeDir 'character-model.md'
        QUICKSTART         = Join-Path $narrativeDir 'quickstart.md'
        CONTRACTS_DIR      = Join-Path $narrativeDir 'contracts'
    }
}

function Test-FileExists {
    param([string]$Path, [string]$Description)
    if (Test-Path -Path $Path -PathType Leaf) {
        Write-Output "  ✓ $Description"
        return $true
    } else {
        Write-Output "  ✗ $Description"
        return $false
    }
}

function Test-DirHasFiles {
    param([string]$Path, [string]$Description)
    if ((Test-Path -Path $Path -PathType Container) -and (Get-ChildItem -Path $Path -ErrorAction SilentlyContinue | Where-Object { -not $_.PSIsContainer } | Select-Object -First 1)) {
        Write-Output "  ✓ $Description"
        return $true
    } else {
        Write-Output "  ✗ $Description"
        return $false
    }
}
