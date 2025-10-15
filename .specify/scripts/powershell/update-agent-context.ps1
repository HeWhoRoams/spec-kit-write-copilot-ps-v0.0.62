#!/usr/bin/env pwsh
<#!
.SYNOPSIS
Update agent context files with information from narrative-outline.md (PowerShell version)

.DESCRIPTION
This script maintains AI agent context files by parsing narrative specifications 
and updating agent-specific configuration files with project information.
#>
param(
    [Parameter(Position=0)]
    [ValidateSet('claude','gemini','copilot','cursor-agent','qwen','opencode','codex','windsurf','kilocode','auggie','roo','codebuddy','q')]
    [string]$AgentType
)

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

$envData = Get-NarrativePathsEnv
$PROJECT_ROOT       = $envData.PROJECT_ROOT
$CURRENT_NARRATIVE  = $envData.CURRENT_NARRATIVE
$HAS_GIT            = $envData.HAS_GIT
$NARRATIVE_OUTLINE  = $envData.NARRATIVE_OUTLINE
$NEW_OUTLINE = $NARRATIVE_OUTLINE

$CLAUDE_FILE   = Join-Path $PROJECT_ROOT 'CLAUDE.md'
$GEMINI_FILE   = Join-Path $PROJECT_ROOT 'GEMINI.md'
$COPILOT_FILE  = Join-Path $PROJECT_ROOT '.github/copilot-instructions.md'
$CURSOR_FILE   = Join-Path $PROJECT_ROOT '.cursor/rules/specify-rules.mdc'
$QWEN_FILE     = Join-Path $PROJECT_ROOT 'QWEN.md'
$AGENTS_FILE   = Join-Path $PROJECT_ROOT 'AGENTS.md'
$WINDSURF_FILE = Join-Path $PROJECT_ROOT '.windsurf/rules/specify-rules.md'
$KILOCODE_FILE = Join-Path $PROJECT_ROOT '.kilocode/rules/specify-rules.md'
$AUGGIE_FILE   = Join-Path $PROJECT_ROOT '.augment/rules/specify-rules.md'
$ROO_FILE      = Join-Path $PROJECT_ROOT '.roo/rules/specify-rules.md'
$CODEBUDDY_FILE = Join-Path $PROJECT_ROOT '.codebuddy/rules/specify-rules.md'
$Q_FILE        = Join-Path $PROJECT_ROOT 'AGENTS.md'

$TEMPLATE_FILE = Join-Path $PROJECT_ROOT '.specify/templates/agent-file-template.md'

$script:NEW_GENRE = ''
$script:NEW_VOICE = ''
$script:NEW_PACING = ''
$script:NEW_AUDIENCE = ''

function Write-Info { param([string]$Message) Write-Host "INFO: $Message" }
function Write-Success { param([string]$Message) Write-Host "$([char]0x2713) $Message" }
function Write-WarningMsg { param([string]$Message) Write-Warning $Message }
function Write-Err { param([string]$Message) Write-Host "ERROR: $Message" -ForegroundColor Red }

function Validate-Environment {
    if (-not $CURRENT_NARRATIVE) {
        Write-Err 'Unable to determine current narrative'
        if ($HAS_GIT) { Write-Info "Make sure you're on a narrative branch" } else { Write-Info 'Set SDW_NARRATIVE environment variable or create a narrative first' }
        exit 1
    }
    if (-not (Test-Path $NEW_OUTLINE)) {
        Write-Err "No narrative-outline.md found at $NEW_OUTLINE"
        Write-Info 'Ensure you are working on a narrative with a corresponding spec directory'
        if (-not $HAS_GIT) { Write-Info 'Use: $env:SDW_NARRATIVE=your-narrative-name or create a new narrative first' }
        exit 1
    }
    if (-not (Test-Path $TEMPLATE_FILE)) {
        Write-Err "Template file not found at $TEMPLATE_FILE"
        Write-Info 'Run specify init to scaffold .specify/templates, or add agent-file-template.md there.'
        exit 1
    }
}

function Extract-OutlineField {
    param([string]$FieldPattern, [string]$OutlineFile)
    if (-not (Test-Path $OutlineFile)) { return '' }
    $regex = "^\*\*$([Regex]::Escape($FieldPattern))\*\*: (.+)$"
    Get-Content -LiteralPath $OutlineFile -Encoding utf8 | ForEach-Object {
        if ($_ -match $regex) { 
            $val = $Matches[1].Trim()
            if ($val -notin @('NEEDS CLARIFICATION','N/A')) { return $val }
        }
    } | Select-Object -First 1
}

function Parse-OutlineData {
    param([string]$OutlineFile)
    if (-not (Test-Path $OutlineFile)) { Write-Err "Outline file not found: $OutlineFile"; return $false }
    Write-Info "Parsing outline data from $OutlineFile"
    $script:NEW_GENRE    = Extract-OutlineField -FieldPattern 'Genre/Style' -OutlineFile $OutlineFile
    $script:NEW_VOICE    = Extract-OutlineField -FieldPattern 'Narrative Voice' -OutlineFile $OutlineFile
    $script:NEW_PACING   = Extract-OutlineField -FieldPattern 'Pacing' -OutlineFile $OutlineFile
    $script:NEW_AUDIENCE = Extract-OutlineField -FieldPattern 'Target Audience' -OutlineFile $OutlineFile

    if ($NEW_GENRE) { Write-Info "Found genre: $NEW_GENRE" } else { Write-WarningMsg 'No genre information found in outline' }
    if ($NEW_VOICE) { Write-Info "Found voice: $NEW_VOICE" }
    if ($NEW_PACING) { Write-Info "Found pacing: $NEW_PACING" }
    if ($NEW_AUDIENCE) { Write-Info "Found audience: $NEW_AUDIENCE" }
    return $true
}

function Format-NarrativeDetails {
    param([string]$Genre, [string]$Voice)
    $parts = @()
    if ($Genre -and $Genre -ne 'NEEDS CLARIFICATION') { $parts += $Genre }
    if ($Voice -and $Voice -notin @('NEEDS CLARIFICATION','N/A')) { $parts += $Voice }
    if (-not $parts) { return '' }
    return ($parts -join ' + ')
}

function Get-NarrativeStructure { 
    return "src/`n├── part_1/`n├── part_2/`n└── part_3/"
}

function Get-WritingConventions { 
    param([string]$Genre)
    if ($Genre) { "${Genre}: Follow established conventions" } else { 'General: Follow established conventions' } 
}

function New-AgentFile {
    param([string]$TargetFile, [string]$ProjectName, [datetime]$Date)
    if (-not (Test-Path $TEMPLATE_FILE)) { Write-Err "Template not found at $TEMPLATE_FILE"; return $false }
    $temp = New-TemporaryFile
    Copy-Item -LiteralPath $TEMPLATE_FILE -Destination $temp -Force

    $narrativeStructure = Get-NarrativeStructure
    $writingConventions = Get-WritingConventions -Genre $NEW_GENRE

    $escaped_genre = $NEW_GENRE
    $escaped_voice = $NEW_VOICE
    $escaped_narrative = $CURRENT_NARRATIVE

    $content = Get-Content -LiteralPath $temp -Raw -Encoding utf8
    $content = $content -replace '\[PROJECT NAME\]',$ProjectName
    $content = $content -replace '\[DATE\]',$Date.ToString('yyyy-MM-dd')
    
    $narrativeDetailsForTemplate = ""
    if ($escaped_genre -and $escaped_voice) {
        $narrativeDetailsForTemplate = "- $escaped_genre + $escaped_voice ($escaped_narrative)"
    } elseif ($escaped_genre) {
        $narrativeDetailsForTemplate = "- $escaped_genre ($escaped_narrative)"
    } elseif ($escaped_voice) {
        $narrativeDetailsForTemplate = "- $escaped_voice ($escaped_narrative)"
    }
    
    $content = $content -replace '\[EXTRACTED FROM ALL PLAN.MD FILES\]',$narrativeDetailsForTemplate
    $escapedStructure = [Regex]::Escape($narrativeStructure)
    $content = $content -replace '\[ACTUAL STRUCTURE FROM PLANS\]',$escapedStructure
    $content = $content -replace '\[ONLY COMMANDS FOR ACTIVE TECHNOLOGIES\]',"# Add narrative-specific writing commands"
    $content = $content -replace '\[LANGUAGE-SPECIFIC, ONLY FOR LANGUAGES IN USE\]',$writingConventions
    
    $recentChangesForTemplate = ""
    if ($escaped_genre -and $escaped_voice) {
        $recentChangesForTemplate = "- ${escaped_narrative}: Added ${escaped_genre} + ${escaped_voice}"
    } elseif ($escaped_genre) {
        $recentChangesForTemplate = "- ${escaped_narrative}: Added ${escaped_genre}"
    } elseif ($escaped_voice) {
        $recentChangesForTemplate = "- ${escaped_narrative}: Added ${escaped_voice}"
    }
    
    $content = $content -replace '\[LAST 3 FEATURES AND WHAT THEY ADDED\]',$recentChangesForTemplate
    $content = $content -replace '\\n',[Environment]::NewLine

    $parent = Split-Path -Parent $TargetFile
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent
