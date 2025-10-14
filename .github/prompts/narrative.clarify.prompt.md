---
description: Identify underspecified areas in the current narrative spec by asking up to 5 highly targeted clarification questions and encoding answers back into the spec.
---

## User Input

```text
$ARGUMENTS

You MUST consider the user input before proceeding (if not empty).

Outline

Goal: Detect and reduce ambiguity or missing decision points in the active narrative specification and record the clarifications directly in the spec file.

Note: This clarification workflow is expected to run (and be completed) BEFORE invoking /narrative.plan. If the user explicitly states they are skipping clarification (e.g., exploratory spike), you may proceed, but must warn that downstream rework risk increases.

Execution steps:

    Run .specify/scripts/powershell/check-prerequisites.ps1 -Json -PathsOnly from repo root once (combined --json --paths-only mode / -Json -PathsOnly). Parse minimal JSON payload fields:

        NARRATIVE_DIR

        NARRATIVE_SPEC

        (Optionally capture NARRATIVE_OUTLINE, SCENES for future chained flows.)

        If JSON parsing fails, abort and instruct user to re-run /narrative.specify or verify narrative branch environment.

        For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'''m Groot' (or double-quote if possible: "I'm Groot").

    Load the current spec file. Perform a structured ambiguity & coverage scan using this taxonomy. For each category, mark status: Clear / Partial / Missing. Produce an internal coverage map used for prioritization (do not output raw map unless no questions will be asked).

    Plot & Pacing:

        Core reader goals & success criteria

        Explicit out-of-scope declarations

        Character roles / archetypes differentiation

    Domain & Character Model:

        Characters, relationships, motivations

        Consistency & uniqueness rules

        Character arc transitions

        Scope / scale assumptions (e.g., number of characters, world details)

    Interaction & Narrative Flow:

        Critical plot points / sequences

        Conflict / resolution states

        Pacing or tone notes

    Narrative Quality Attributes:

        Tone (style, mood, voice)

        Pacing (rate of plot progression)

        Consistency & reliability (point of view, character traits)

        Readability (prose complexity, sentence length)

        Authenticity (historical or domain-specific accuracy)

        Thematic constraints (if any)

    Integration & External Dependencies:

        External source material (e.g., historical documents, research)

        Data import/export formats (e.g., character sheets)

        Research/versioning assumptions

    Edge Cases & Failure Handling:

        Plot holes or contradictions

        Character inconsistencies

        Unresolved conflict / loose ends

    Constraints & Tradeoffs:

        Word count / chapter length

        Explicit tradeoffs or rejected alternatives

    Terminology & Consistency:

        Canonical glossary terms

        Avoided synonyms / deprecated terms

    Completion Signals:

        Acceptance criteria testability

        Measurable 'Definition of Done' style indicators

    Misc / Placeholders:

        TODO markers / unresolved decisions

        Ambiguous adjectives ("gripping", "intuitive") lacking quantification

    For each category with Partial or Missing status, add a candidate question opportunity unless:

        Clarification would not materially change narrative or validation strategy

        Information is better deferred to outlining phase (note internally)

    Generate (internally) a prioritized queue of candidate clarification questions (maximum 5). Do NOT output them all at once. Apply these constraints:

        Maximum of 10 total questions across the whole session.

        Each question must be answerable with EITHER:

            A short multiple‑choice selection (2–5 distinct, mutually exclusive options), OR

            A one-word / short‑phrase answer (explicitly constrain: "Answer in <=5 words").

        Only include questions whose answers materially impact plot, character development, scene decomposition, draft design, reader experience, world-building, or thematic consistency.

        Ensure category coverage balance: attempt to cover the highest impact unresolved categories first; avoid asking two low-impact questions when a single high-impact area (e.g., thematic consistency) is unresolved.

        Exclude questions already answered, trivial stylistic preferences, or outline-level execution details (unless blocking correctness).

        Favor clarifications that reduce downstream rework risk or prevent misaligned plot points.

        If more than 5 categories remain unresolved, select the top 5 by (Impact * Uncertainty) heuristic.

    Sequential questioning loop (interactive):

        Present EXACTLY ONE question at a time.

        For multiple‑choice questions:

            Analyze all options and determine the most suitable option based on:

                Best practices for the narrative type

                Common patterns in similar narratives

                Risk reduction (plot holes, inconsistencies, thematic drift)

                Alignment with any explicit project goals or constraints visible in the spec

            Present your recommended option prominently at the top with clear reasoning (1-2 sentences explaining why this is the best choice).

            Format as: **Recommended:** Option [X] - <reasoning>

            Then render all options as a Markdown table:
        Option	Description
        A	<Option A description>
        B	<Option B description>
        C	<Option C description>
        Short	Provide a different short answer (<=5 words)

            After the table, add: You can reply with the option letter (e.g., "A"), accept the recommendation by saying "yes" or "recommended", or provide your own short answer.

        For short‑answer style (no meaningful discrete options):

            Provide your suggested answer based on best practices and context.

            Format as: **Suggested:** <your proposed answer> - <brief reasoning>

            Then output: Format: Short answer (<=5 words). You can accept the suggestion by saying "yes" or "suggested", or provide your own answer.

        After the user answers:

            If the user replies with "yes", "recommended", or "suggested", use your previously stated recommendation/suggestion as the answer.

            Otherwise, validate the answer maps to one option or fits the <=5 word constraint.

            If ambiguous, ask for a quick disambiguation (count still belongs to same question; do not advance).

            Once satisfactory, record it in working memory (do not yet write to disk) and move to the next queued question.

        Stop asking further questions when:

            All critical ambiguities resolved early (remaining queued items become unnecessary), OR

            User signals completion ("done", "good", "no more"), OR

            You reach 5 asked questions.

        Never reveal future queued questions in advance.

        If no valid questions exist at start, immediately report no critical ambiguities.

    Integration after EACH accepted answer (incremental update approach):

        Maintain in-memory representation of the spec (loaded once at start) plus the raw file contents.

        For the first integrated answer in this session:

            Ensure a ## Clarifications section exists (create it just after the highest-level contextual/overview section per the spec template if missing).

            Under it, create (if not present) a ### Session YYYY-MM-DD subheading for today.

        Append a bullet line immediately after acceptance: - Q: <question> → A: <final answer>.

        Then immediately apply the clarification to the most appropriate section(s):

            Plot ambiguity → Update or add a bullet in Plot Points.

            Character / relationship distinction → Update Character Arcs or Actors subsection (if present) with clarified role, constraint, or scenario.

            Domain/data shape → Update Character/Entity Model (add traits, relationships) preserving ordering; note added constraints succinctly.

            Narrative constraint → Add/modify measurable criteria in Narrative Quality section (convert vague adjective to metric or explicit target).

            Edge case / failure handling → Add a new bullet under Edge Cases / Plot Holes (or create such subsection if template provides placeholder for it).

            Terminology conflict → Normalize term across spec; retain original only if necessary by adding (formerly referred to as "X") once.

        If the clarification invalidates an earlier ambiguous statement, replace that statement instead of duplicating; leave no obsolete contradictory text.

        Save the spec file AFTER each integration to minimize risk of context loss (atomic overwrite).

        Preserve formatting: do not reorder unrelated sections; keep heading hierarchy intact.

        Keep each inserted clarification minimal and testable (avoid narrative drift).

    Validation (performed after EACH write plus final pass):

        Clarifications session contains exactly one bullet per accepted answer (no duplicates).

        Total asked (accepted) questions ≤ 5.

        Updated sections contain no lingering vague placeholders the new answer was meant to resolve.

        No contradictory earlier statement remains (scan for now-invalid alternative choices removed).

        Markdown structure valid; only allowed new headings: ## Clarifications, ### Session YYYY-MM-DD.

        Terminology consistency: same canonical term used across all updated sections.

    Write the updated spec back to NARRATIVE_SPEC.

    Report completion (after questioning loop ends or early termination):

        Number of questions asked & answered.

        Path to updated spec.

        Sections touched (list names).

        Coverage summary table listing each taxonomy category with Status: Resolved (was Partial/Missing and addressed), Deferred (exceeds question quota or better suited for outlining), Clear (already sufficient), Outstanding (still Partial/Missing but low impact).

        If any Outstanding or Deferred remain, recommend whether to proceed to /narrative.plan or run /narrative.clarify again later post-plan.

        Suggested next command.

Behavior rules:

    If no meaningful ambiguities found (or all potential questions would be low-impact), respond: "No critical ambiguities detected worth formal clarification." and suggest proceeding.

    If spec file missing, instruct user to run /narrative.specify first (do not create a new spec here).

    Never exceed 5 total asked questions (clarification retries for a single question do not count as new questions).

    Avoid speculative tech stack questions unless the absence blocks functional clarity.

    Respect user early termination signals ("stop", "done", "proceed").

    If no questions asked due to full coverage, output a compact coverage summary (all categories Clear) then suggest advancing.

    If quota reached with unresolved high-impact categories remaining, explicitly flag them under Deferred with rationale.

Context for prioritization: $ARGUMENTS