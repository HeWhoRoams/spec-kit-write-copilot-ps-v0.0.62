***

### 2. `narrative.checklist.md`
This command is rewritten to generate a checklist that acts as a quality-control document for your narrative. It can be used to validate everything from character consistency to thematic resonance.

```markdown
---
description: Generate a custom checklist for the current narrative based on author requirements.
scripts:
  sh: scripts/bash/check-prerequisites.sh --json
  ps: scripts/powershell/check-prerequisites.ps1 -Json
---

## Checklist Purpose: "Narrative Quality Check"

**CRITICAL CONCEPT**: Checklists are **UNIT TESTS FOR NARRATIVE REQUIREMENTS** - they validate the quality, clarity, and completeness of narrative points in a given domain.

**NOT for drafting/writing**:
- ❌ NOT "Draft the scene where the hero meets the villain"
- ❌ NOT "Write dialogue for the final confrontation"
- ❌ NOT "Confirm the final chapter has a word count of 5,000"

**FOR narrative quality validation**:
- ✅ "Are motivations defined for all major characters?" (completeness)
- ✅ "Is 'suspenseful' quantified with specific pacing cues?" (clarity)
- ✅ "Are character traits consistent across all scenes?" (consistency)
- ✅ "Are all subplots resolved by the end of the narrative?" (coverage)
- ✅ "Does the outline define what happens when a character's core belief is challenged?" (edge cases)

**Metaphor**: If your narrative spec is an outline written in English, the checklist is its unit test suite. You're testing whether the outline is well-written, complete, unambiguous, and ready for drafting - NOT whether the draft works.

## User Input

```text
$ARGUMENTS

You MUST consider the user input before proceeding (if not empty).

Execution Steps

    Setup: Run {SCRIPT} from repo root and parse JSON for NARRATIVE_DIR and AVAILABLE_DOCS list.

        All file paths must be absolute.

        For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'''m Groot' (or double-quote if possible: "I'm Groot").

    Clarify intent (dynamic): Derive up to THREE initial contextual clarifying questions (no pre-baked catalog). They MUST:

        Be generated from the user's phrasing + extracted signals from spec/outline/scenes

        Only ask about information that materially changes checklist content

        Be skipped individually if already unambiguous in $ARGUMENTS

        Prefer precision over breadth

    Generation algorithm:

        Extract signals: narrative domain keywords (e.g., plot, character, theme, style), risk indicators ("critical", "must", "thematic"), author hints ("editor", "reviewer", "beta reader"), and explicit deliverables ("climax", "subplot", "resolution").

        Cluster signals into candidate focus areas (max 4) ranked by relevance.

        Identify probable audience & timing (author, editor, beta reader) if not explicit.

        Detect missing dimensions: plot breadth, depth/rigor, thematic emphasis, exclusion boundaries, measurable acceptance criteria.

        Formulate questions chosen from these archetypes:

            Scope refinement (e.g., "Should this include a subplot about X or stay limited to the main plot?")

            Risk prioritization (e.g., "Which of these potential plot holes should receive mandatory checks?")

            Depth calibration (e.g., "Is this a lightweight sanity check or a formal manuscript gate?")

            Audience framing (e.g., "Will this be used by the author only or peers during editing?")

            Boundary exclusion (e.g., "Should we explicitly exclude world-building items this round?")

            Scenario class gap (e.g., "No recovery flows detected—are redemption / partial failure paths in scope?")

    Question formatting rules:

        If presenting options, generate a compact table with columns: Option | Candidate | Why It Matters

        Limit to A–E options maximum; omit table if a free-form answer is clearer

        Never ask the user to restate what they already said

        Avoid speculative categories (no hallucination). If uncertain, ask explicitly: "Confirm whether X belongs in scope."

    Defaults when interaction impossible:

        Depth: Standard

        Audience: Reviewer if narrative-related; Author otherwise

        Focus: Top 2 relevance clusters

    Output the questions (label Q1/Q2/Q3). After answers: if ≥2 scenario classes (Alternate / Exception / Recovery / Non-Functional domain) remain unclear, you MAY ask up to TWO more targeted follow‑ups (Q4/Q5) with a one-line justification each (e.g., "Unresolved plot hole risk"). Do not exceed five total questions. Skip escalation if user explicitly declines more.

    Understand user request: Combine $ARGUMENTS + clarifying answers:

        Derive checklist theme (e.g., pacing, character, theme, consistency)

        Consolidate explicit must-have items mentioned by user

        Map focus selections to category scaffolding

        Infer any missing context from spec/outline/scenes (do NOT hallucinate)

    Load narrative context: Read from NARRATIVE_DIR:

        narrative-spec.md: Narrative requirements and scope

        narrative-outline.md (if exists): Plot details, dependencies

        scenes.md (if exists): Writing tasks

    Context Loading Strategy:

        Load only necessary portions relevant to active focus areas (avoid full-file dumping)

        Prefer summarizing long sections into concise plot/character bullets

        Use progressive disclosure: add follow-on retrieval only if gaps detected

        If source docs are large, generate interim summary items instead of embedding raw text

    Generate checklist - Create "Unit Tests for Narrative":

        Create NARRATIVE_DIR/checklists/ directory if it doesn't exist

        Generate unique checklist filename:

            Use short, descriptive name based on domain (e.g., pacing.md, character.md, theme.md)

            Format: [domain].md

            If file exists, append to existing file

        Number items sequentially starting from CHK001

        Each /narrative.checklist run creates a NEW file (never overwrites existing checklists)

    CORE PRINCIPLE - Test the Outline, Not the Prose:
    Every checklist item MUST evaluate the NARRATIVE ITSELF for:

        Completeness: Are all necessary narrative elements present?

        Clarity: Are plot points and character arcs unambiguous and specific?

        Consistency: Do elements align with each other?

        Measurability: Can requirements be objectively verified?

        Coverage: Are all scenarios/edge cases addressed?

    Category Structure - Group items by narrative quality dimensions:

        Narrative Completeness (Are all necessary plot points documented?)

        Narrative Clarity (Are requirements specific and unambiguous?)

        Narrative Consistency (Do plot points align without conflicts?)

        Acceptance Criteria Quality (Are success criteria measurable?)

        Scenario Coverage (Are all flows/cases addressed?)

        Edge Case Coverage (Are boundary conditions defined?)

        Thematic Requirements (Theme, tone, style, etc. - are they specified?)

        Dependencies & Assumptions (Are they documented and validated?)

        Ambiguities & Conflicts (What needs clarification?)

    HOW TO WRITE CHECKLIST ITEMS - "Unit Tests for Narrative":

    ❌ WRONG (Testing prose):

        "Verify that Chapter 3 is well-written"

        "Test that the climax is emotionally impactful"

        "Confirm the dialogue sounds natural"

    ✅ CORRECT (Testing narrative quality):

        "Are the motivations for all major characters explicitly specified?" [Completeness]

        "Is 'suspenseful pacing' quantified with specific scene lengths or information reveals?" [Clarity]

        "Are character traits consistent across all plot points?" [Consistency]

        "Are character redemption arcs defined for all key villains?" [Coverage]

        "Is the resolution defined for all major conflicts?" [Edge Cases]

        "Are the emotional beats defined for the climactic scene?" [Completeness]

        "Does the spec define the purpose of all subplots?" [Clarity]

    ITEM STRUCTURE:
    Each item should follow this pattern:

        Question format asking about narrative quality

        Focus on what's WRITTEN (or not written) in the spec/outline

        Include quality dimension in brackets [Completeness/Clarity/Consistency/etc.]

        Reference spec section [Spec §X.Y] when checking existing requirements

        Use [Gap] marker when checking for missing requirements

    EXAMPLES BY QUALITY DIMENSION:

    Completeness:

        "Are motivations defined for all key supporting characters? [Gap]"

        "Are the emotional beats for the final chapter specified? [Completeness]"

    Clarity:

        "Is 'fast-paced' quantified with specific word counts per scene? [Clarity]"

        "Are 'key relationships' explicitly defined for each character? [Clarity]"

    Consistency:

        "Do character descriptions align with their actions in the outline? [Consistency]"

    Coverage:

        "Are resolutions defined for all subplots? [Coverage, Edge Case]"

        "Are secondary character arcs addressed? [Coverage, Gap]"

    Measurability:

        "Are thematic requirements measurable/testable? [Acceptance Criteria]"

    Traceability Requirements:

        MINIMUM: ≥80% of items MUST include at least one traceability reference

        Each item should reference: spec section [Spec §X.Y], or use markers: [Gap], [Ambiguity], [Conflict], [Assumption]

    Surface & Resolve Issues (Narrative Quality Problems):
    Ask questions about the narrative itself:

        Ambiguities: "Is the term 'emotional journey' quantified with specific plot points? [Ambiguity]"

        Conflicts: "Do character traits conflict between Chapter 3 and Chapter 10? [Conflict]"

        Assumptions: "Is the assumption that 'magic works in a certain way' validated by the world-building? [Assumption]"

        Missing definitions: "Is 'gripping' defined with measurable criteria? [Gap]"

    Structure Reference: Generate the checklist following the canonical template in templates/checklist-template.md for title, meta section, category headings, and ID formatting.

    Report: Output full path to created checklist, item count, and remind user that each run creates a new file. Summarize:

        Focus areas selected

        Depth level

        Actor/timing

        Any explicit user-specified must-have items incorporated