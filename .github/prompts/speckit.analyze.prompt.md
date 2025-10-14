---
description: Perform a non-destructive cross-artifact consistency and quality analysis across narrative-spec.md, narrative-outline.md, and scenes.md after task generation.
scripts:
  sh: scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
  ps: scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks
---

## User Input

```text
$ARGUMENTS

You MUST consider the user input before proceeding (if not empty).

Goal

Identify inconsistencies, duplications, ambiguities, and underspecified items across the three core artifacts (narrative-spec.md, narrative-outline.md, scenes.md) before writing. This command MUST run only after /narrative.tasks has successfully produced a complete scenes.md.

Operating Constraints

STRICTLY READ-ONLY: Do not modify any files. Output a structured analysis report.

Narrative Constitution Authority: The project constitution (/memory/constitution.md) is non-negotiable within this analysis scope. Constitution conflicts are automatically CRITICAL and require adjustment of the spec, outline, or scenes—not dilution, reinterpretation, or silent ignoring of the principle.

Execution Steps

1. Initialize Analysis Context

Run {SCRIPT} once from project root and parse JSON for NARRATIVE_DIR and AVAILABLE_DOCS. Derive absolute paths:

    SPEC = NARRATIVE_DIR/narrative-spec.md

    OUTLINE = NARRATIVE_DIR/narrative-outline.md

    SCENES = NARRATIVE_DIR/scenes.md

Abort with an error message if any required file is missing (instruct the user to run missing prerequisite command).
For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'''m Groot' (or double-quote if possible: "I'm Groot").

2. Load Artifacts (Progressive Disclosure)

Load only the minimal necessary context from each artifact:

From narrative-spec.md:

    Overview/Context

    Plot Points

    Thematic Elements

    Character Arcs

    Edge Cases (if present)

From narrative-outline.md:

    Pacing/Style choices

    Character Model references

    Plot Phases

    Narrative constraints

From scenes.md:

    Scene IDs

    Descriptions

    Chapter/Plot grouping

    Parallel markers [P]

    Referenced character/setting names

From constitution:

    Load /memory/constitution.md for principle validation

3. Build Semantic Models

Create internal representations (do not include raw artifacts in output):

    Plot inventory: Each plot point with a stable key (derive slug based on imperative phrase; e.g., "Hero meets mentor" → hero-meets-mentor)

    Character arc/action inventory: Discrete character actions with acceptance criteria

    Scene coverage mapping: Map each scene to one or more plot points or character arcs (inference by keyword / explicit reference patterns like IDs or key phrases)

    Constitution rule set: Extract principle names and MUST/SHOULD normative statements

4. Detection Passes (Token-Efficient Analysis)

Focus on high-signal findings. Limit to 50 findings total; aggregate remainder in overflow summary.

A. Duplication Detection

    Identify near-duplicate scenes or plot points

    Mark lower-quality phrasing for consolidation

B. Ambiguity Detection

    Flag vague adjectives (gripping, beautiful, fast-paced, emotionally resonant) lacking measurable criteria

    Flag unresolved placeholders (TODO, TKTK, ???, <placeholder>, etc.)

C. Underspecification

    Plot points with verbs but missing object or measurable outcome

    Character arcs missing acceptance criteria alignment

    Scenes referencing characters or settings not defined in spec/outline

D. Narrative Constitution Alignment

    Any plot point or outline element conflicting with a MUST principle

    Missing mandated sections or quality gates from constitution

E. Coverage Gaps

    Plot points with zero associated scenes

    Scenes with no mapped plot point/character arc

    Thematic elements not reflected in scenes (e.g., a theme of "loss" that never appears in a scene)

F. Inconsistency

    Terminology drift (same concept named differently across files)

    Character traits referenced in outline but absent in spec (or vice versa)

    Scene ordering contradictions (e.g., a reveal scene before the setup scene)

    Conflicting narrative requirements (e.g., one requires first-person while other specifies third-person)

5. Severity Assignment

Use this heuristic to prioritize findings:

    CRITICAL: Violates constitution MUST, missing core narrative artifact, or plot point with zero coverage that blocks baseline functionality

    HIGH: Duplicate or conflicting plot point, ambiguous emotional/thematic attribute, untestable acceptance criterion

    MEDIUM: Terminology drift, missing thematic coverage, underspecified subplot

    LOW: Style/wording improvements, minor redundancy not affecting execution order

6. Produce Compact Analysis Report

Output a Markdown report (no file writes) with the following structure:

Narrative Analysis Report

ID	Category	Severity	Location(s)	Summary	Recommendation
A1	Duplication	HIGH	narrative-spec.md:L120-134	Two similar plot points...	Merge phrasing; keep clearer version

Coverage Summary Table:
Plot Key	Has Scene?	Scene IDs	Notes

Narrative Constitution Alignment Issues: (if any)

Unmapped Scenes: (if any)

Metrics:

    Total Plot Points

    Total Scenes

    Coverage % (plot points with >=1 scene)

    Ambiguity Count

    Duplication Count

    Critical Issues Count

7. Provide Next Actions

At end of report, output a concise Next Actions block:

    If CRITICAL issues exist: Recommend resolving before /narrative.write

    If only LOW/MEDIUM: Author may proceed, but provide improvement suggestions

    Provide explicit command suggestions: e.g., "Run /narrative.specify with refinement", "Run /narrative.plan to adjust plot structure", "Manually edit scenes.md to add coverage for 'protagonist-realization'"

8. Offer Remediation

Ask the user: "Would you like me to suggest concrete remediation edits for the top N issues?" (Do NOT apply them automatically.)

Operating Principles

Context Efficiency

    Minimal high-signal tokens: Focus on actionable findings, not exhaustive documentation

    Progressive disclosure: Load artifacts incrementally; don't dump all content into analysis

    Token-efficient output: Limit findings table to 50 rows; summarize overflow

    Deterministic results: Rerunning without changes should produce consistent IDs and counts

Analysis Guidelines

    NEVER modify files (this is read-only analysis)

    NEVER hallucinate missing sections (if absent, report them accurately)

    Prioritize constitution violations (these are always CRITICAL)

    Use examples over exhaustive rules (cite specific instances, not generic patterns)

    Report zero issues gracefully (emit success report with coverage statistics)