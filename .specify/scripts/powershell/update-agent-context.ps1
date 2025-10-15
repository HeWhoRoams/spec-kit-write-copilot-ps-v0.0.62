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
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent }
    Set-Content -LiteralPath $TargetFile -Value $content -NoNewline -Encoding utf8
    Remove-Item $temp -Force
    return $true
}

function Update-ExistingAgentFile {
    param([string]$TargetFile, [datetime]$Date)
    if (-not (Test-Path $TargetFile)) { return (New-AgentFile -TargetFile $TargetFile -ProjectName (Split-Path $PROJECT_ROOT -Leaf) -Date $Date) }

    $narrativeDetails = Format-NarrativeDetails -Genre $NEW_GENRE -Voice $NEW_VOICE
    $newDetailsEntries = @()
    if ($narrativeDetails) {
        $escapedDetails = [Regex]::Escape($narrativeDetails)
        if (-not (Select-String -Pattern $escapedDetails -Path $TargetFile -Quiet)) { 
            $newDetailsEntries += "- $narrativeDetails ($CURRENT_NARRATIVE)" 
        }
    }
    
    $newChangeEntry = ''
    if ($narrativeDetails) { $newChangeEntry = "- ${CURRENT_NARRATIVE}: Added ${narrativeDetails}" }

    $lines = Get-Content -LiteralPath $TargetFile -Encoding utf8
    $output = New-Object System.Collections.Generic.List[string]
    $inDetails = $false; $inChanges = $false; $detailsAdded = $false; $changeAdded = $false; $existingChanges = 0

    for ($i=0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -eq '## Active Technologies') { $output.Add('## Active Narratives'); $inDetails = $true; continue }
        if ($inDetails -and $line -match '^##\s') {
            if (-not $detailsAdded -and $newDetailsEntries.Count -gt 0) { $newDetailsEntries | ForEach-Object { $output.Add($_) }; $detailsAdded = $true }
            $output.Add($line); $inDetails = $false; continue
        }
        if ($inDetails -and [string]::IsNullOrWhiteSpace($line)) {
            if (-not $detailsAdded -and $newDetailsEntries.Count -gt 0) { $newDetailsEntries | ForEach-Object { $output.Add($_) }; $detailsAdded = true }
            $output.Add($line); continue
        }
        if ($line -eq '## Recent Changes') {
            $output.Add($line)
            if ($newChangeEntry) { $output.Add($newChangeEntry); $changeAdded = $true }
            $inChanges = $true
            continue
        }
        if ($inChanges -and $line -match '^- ') {
            if ($existingChanges -lt 2) { $output.Add($line); $existingChanges++ }
            continue
        }
        if ($line -match '\*\*Last updated\*\*: .*\d{4}-\d{2}-\d{2}') {
            $output.Add(($line -replace '\d{4}-\d{2}-\d{2}',$Date.ToString('yyyy-MM-dd')))
            continue
        }
        $output.Add($line)
    }

    if ($inDetails -and -not $detailsAdded -and $newDetailsEntries.Count -gt 0) { $newDetailsEntries | ForEach-Object { $output.Add($_) } }

    Set-Content -LiteralPath $TargetFile -Value ($output -join [Environment]::NewLine) -Encoding utf8
    return $true
}

function Update-AgentFile {
    param([string]$TargetFile, [string]$AgentName)
    if (-not $TargetFile -or -not $AgentName) { Write-Err 'Update-AgentFile requires TargetFile and AgentName'; return $false }
    Write-Info "Updating $AgentName context file: $TargetFile"
    $projectName = Split-Path $PROJECT_ROOT -Leaf
    $date = Get-Date

    $dir = Split-Path -Parent $TargetFile
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }

    if (-not (Test-Path $TargetFile)) {
        if (New-AgentFile -TargetFile $TargetFile -ProjectName $projectName -Date $date) { Write-Success "Created new $AgentName context file" } else { Write-Err 'Failed to create new agent file'; return $false }
    } else {
        try {
            if (Update-ExistingAgentFile -TargetFile $TargetFile -Date $date) { Write-Success "Updated existing $AgentName context file" } else { Write-Err 'Failed to update agent file'; return $false }
        } catch {
            Write-Err "Cannot access or update existing file: $TargetFile. $_"
            return $false
        }
    }
    return $true
}

function Update-SpecificAgent {
    param([string]$Type)
    switch ($Type) {
        'claude'   { Update-AgentFile -TargetFile $CLAUDE_FILE   -AgentName 'Claude Code' }
        'gemini'   { Update-AgentFile -TargetFile $GEMINI_FILE   -AgentName 'Gemini CLI' }
        'copilot'  { Update-AgentFile -TargetFile $COPILOT_FILE  -AgentName 'GitHub Copilot' }
        'cursor-agent' { Update-AgentFile -TargetFile $CURSOR_FILE   -AgentName 'Cursor IDE' }
        'qwen'     { Update-AgentFile -TargetFile $QWEN_FILE     -AgentName 'Qwen Code' }
        'opencode' { Update-AgentFile -TargetFile $AGENTS_FILE   -AgentName 'opencode' }
        'codex'    { Update-AgentFile -TargetFile $AGENTS_FILE   -AgentName 'Codex CLI' }
        'windsurf' { Update-AgentFile -TargetFile $WINDSURF_FILE -AgentName 'Windsurf' }
        'kilocode' { Update-AgentFile -TargetFile $KILOCODE_FILE -AgentName 'Kilo Code' }
        'auggie'   { Update-AgentFile -TargetFile $AUGGIE_FILE   -AgentName 'Auggie CLI' }
        'roo'      { Update-AgentFile -TargetFile $ROO_FILE      -AgentName 'Roo Code' }
        'codebuddy' { Update-AgentFile -TargetFile $CODEBUDDY_FILE -AgentName 'CodeBuddy' }
        'q'        { Update-AgentFile -TargetFile $Q_FILE        -AgentName 'Amazon Q Developer CLI' }
        default { Write-Err "Unknown agent type '$Type'"; Write-Err 'Expected: claude|gemini|copilot|cursor-agent|qwen|opencode|codex|windsurf|kilocode|auggie|roo|codebuddy|q'; return $false }
    }
}

function Update-AllExistingAgents {
    $found = $false; $ok = $true
    if (Test-Path $CLAUDE_FILE) { if (-not (Update-AgentFile -TargetFile $CLAUDE_FILE -AgentName 'Claude Code')) { $ok = false }; $found = true }
    if (Test-Path $GEMINI_FILE) { if (-not (Update-AgentFile -TargetFile $GEMINI_FILE -AgentName 'Gemini CLI')) { $ok = false }; $found = true }
    if (Test-Path $COPILOT_FILE) { if (-not (Update-AgentFile -TargetFile $COPILOT_FILE -AgentName 'GitHub Copilot')) { $ok = false }; $found = true }
    if (Test-Path $CURSOR_FILE) { if (-not (Update-AgentFile -TargetFile $CURSOR_FILE -AgentName 'Cursor IDE')) { $ok = false }; $found = true }
    if (Test-Path $QWEN_FILE) { if (-not (Update-AgentFile -TargetFile $QWEN_FILE -AgentName 'Qwen Code')) { $ok = false }; $found = true }
    if (Test-Path $AGENTS_FILE) { if (-not (Update-AgentFile -TargetFile $AGENTS_FILE -AgentName 'Codex/opencode')) { $ok = false }; $found = true }
    if (Test-Path $WINDSURF_FILE) { if (-not (Update-AgentFile -TargetFile $WINDSURF_FILE -AgentName 'Windsurf')) { $ok = false }; $found = true }
    if (Test-Path $KILOCODE_FILE) { if (-not (Update-AgentFile -TargetFile $KILOCODE_FILE -AgentName 'Kilo Code')) { $ok = false }; $found = true }
    if (Test-Path $AUGGIE_FILE) { if (-not (Update-AgentFile -TargetFile $AUGGIE_FILE -AgentName 'Auggie CLI')) { $ok = false }; $found = true }
    if (Test-Path $ROO_FILE) { if (-not (Update-AgentFile -TargetFile $ROO_FILE -AgentName 'Roo Code')) { $ok = false }; $found = true }
    if (Test-Path $CODEBUDDY_FILE) { if (-not (Update-AgentFile -TargetFile $CODEBUDDY_FILE -AgentName 'CodeBuddy')) { $ok = false }; $found = true }
    if (Test-Path $Q_FILE) { if (-not (Update-AgentFile -TargetFile $Q_FILE -AgentName 'Amazon Q Developer CLI')) { $ok = false }; $found = true }
    if (-not $found) {
        Write-Info 'No existing agent files found, creating default Claude file...'
        if (-not (Update-AgentFile -TargetFile $CLAUDE_FILE -AgentName 'Claude Code')) { $ok = false }
    }
    return $ok
}

function Print-Summary {
    Write-Host ''
    Write-Info 'Summary of changes:'
    if ($NEW_GENRE) { Write-Host "  - Added genre: $NEW_GENRE" }
    if ($NEW_VOICE) { Write-Host "  - Added voice: $NEW_VOICE" }
    if ($NEW_PACING) { Write-Host "  - Added pacing: $NEW_PACING" }
    Write-Host ''
    Write-Info 'Usage: ./update-agent-context.ps1 [-AgentType claude|gemini|copilot|cursor-agent|qwen|opencode|codex|windsurf|kilocode|auggie|roo|codebuddy|q]'
}

function Main {
    Validate-Environment
    Write-Info "=== Updating agent context files for narrative $CURRENT_NARRATIVE ==="
    if (-not (Parse-OutlineData -OutlineFile $NEW_OUTLINE)) { Write-Err 'Failed to parse outline data'; exit 1 }
    $success = $true
    if ($AgentType) {
        Write-Info "Updating specific agent: $AgentType"
        if (-not (Update-SpecificAgent -Type $AgentType)) { $success = false }
    } else {
        Write-Info 'No agent specified, updating all existing agent files...'
        if (-not (Update-AllExistingAgents)) { $success = false }
    }
    Print-Summary
    if ($success) { Write-Success 'Agent context update completed successfully'; exit 0 } else { Write-Err 'Agent context update completed with errors'; exit 1 }
}

Main
}

{
type: uploaded file
fileName: hewhoroams/spec-kit-write-copilot-ps-v0.0.62/spec-kit-write-copilot-ps-v0.0.62-64d7735a6b0daa0c36bebb58a847fc1ad2b31243/.specify/scripts/powershell/create-new-narrative.ps1
fullContent:
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

$template = Join-Path $projectRoot '.specify/templates/spec-template.md'
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

}

{
type: uploaded file
fileName: hewhoroams/spec-kit-write-copilot-ps-v0.0.62/spec-kit-write-copilot-ps-v0.0.62-64d7735a6b0daa0c36bebb58a847fc1ad2b31243/.specify/templates/narrative-specify-template.md
fullContent:
---
description: Create or update the narrative specification from a natural language narrative description.
scripts:
  sh: scripts/bash/create-new-narrative.sh --json "{ARGS}"
  ps: scripts/powershell/create-new-narrative.ps1 -Json "{ARGS}"
---

## User Input

```text
$ARGUMENTS
