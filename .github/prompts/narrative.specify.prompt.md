---
description: Create or update the narrative specification from a natural language narrative description.
scripts:
  sh: scripts/bash/create-new-feature.sh --json "{ARGS}"
  ps: scripts/powershell/create-new-feature.ps1 -Json "{ARGS}"
---

## User Input

```text
$ARGUMENTS

You MUST consider the user input before proceeding (if not empty).

Outline

The text the user typed after /narrative.specify in the triggering message is the narrative description. Assume you always have it available in this conversation even if {ARGS} appears literally below. Do not ask the user to repeat it unless they provided an empty command.

Given that narrative description, do this:

    Run the script {SCRIPT} from project root and parse its JSON output for NARRATIVE_NAME and SPEC_FILE. All file paths must be absolute.
    IMPORTANT You must only ever run this script once. The JSON is provided in the terminal as output - always refer to it to get the actual content you're looking for. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'''m Groot' (or double-quote if possible: "I'm Groot").

    Load templates/narrative-spec-template.md to understand required sections.

    Follow this execution flow:

        Parse user description from Input
        If empty: ERROR "No narrative description provided"

        Extract key concepts from description
        Identify: characters, plot points, themes, conflicts

        For unclear aspects:

            Make informed guesses based on context and genre conventions

            Only mark with [NEEDS CLARIFICATION: specific question] if:

                The choice significantly impacts narrative scope or reader experience

                Multiple reasonable interpretations exist with different implications

                No reasonable default exists

            LIMIT: Maximum 3 [NEEDS CLARIFICATION] markers total

            Prioritize clarifications by impact: plot > character/theme > style > world-building details

        Fill Plot Points & Character Arcs section
        If no clear plot flow: ERROR "Cannot determine plot points"

        Generate Narrative Requirements
        Each requirement must be verifiable
        Use reasonable defaults for unspecified details (document assumptions in Assumptions section)

        Define Success Criteria
        Create measurable, genre-agnostic outcomes
        Include both quantitative metrics (word count, pacing) and qualitative measures (reader satisfaction, emotional impact)
        Each criterion must be verifiable without specific prose details

        Identify Key Characters & Concepts (if complex world-building involved)

        Return: SUCCESS (spec ready for outlining)

    Write the specification to SPEC_FILE using the template structure, replacing placeholders with concrete details derived from the narrative description (arguments) while preserving section order and headings.

    Specification Quality Validation: After writing the initial spec, validate it against quality criteria:

    a. Create Spec Quality Checklist: Generate a checklist file at NARRATIVE_DIR/checklists/narrative-quality.md using the checklist template structure with these validation items:
    Markdown

# Narrative Quality Checklist: [NARRATIVE NAME]

**Purpose**: Validate specification completeness and quality before proceeding to outlining
**Created**: [DATE]
**Narrative**: [Link to narrative-spec.md]

## Content Quality

- [ ] No specific prose details (grammar, sentence structure, word choice)
- [ ] Focused on reader value and emotional impact
- [ ] Written for a narrative audience
- [ ] All mandatory sections completed

## Requirement Completeness

- [ ] No [NEEDS CLARIFICATION] markers remain
- [ ] Requirements are verifiable and unambiguous
- [ ] Success criteria are measurable
- [ ] Success criteria are genre-agnostic (no specific prose details)
- [ ] All plot scenarios are defined
- [ ] Edge cases are identified
- [ ] Scope is clearly bounded
- [ ] Dependencies and assumptions identified

## Narrative Readiness

- [ ] All narrative requirements have clear acceptance criteria
- [ ] Character arcs cover primary emotional flows
- [ ] Narrative meets measurable outcomes defined in Success Criteria
- [ ] No specific prose details leak into specification

## Notes

- Items marked incomplete require spec updates before `/narrative.clarify` or `/narrative.plan`

b. Run Validation Check: Review the spec against each checklist item:

    For each item, determine if it passes or fails

    Document specific issues found (quote relevant spec sections)

c. Handle Validation Results:

    If all items pass: Mark checklist complete and proceed to step 6

    If items fail (excluding [NEEDS CLARIFICATION]):

        List the failing items and specific issues

        Update the spec to address each issue

        Re-run validation until all items pass (max 3 iterations)

        If still failing after 3 iterations, document remaining issues in checklist notes and warn user

    If [NEEDS CLARIFICATION] markers remain:

        Extract all [NEEDS CLARIFICATION: ...] markers from the spec

        LIMIT CHECK: If more than 3 markers exist, keep only the 3 most critical (by plot/theme/emotional impact) and make informed guesses for the rest

        For each clarification needed (max 3), present options to user in this format:
        Markdown

            ## Question [N]: [Topic]

            **Context**: [Quote relevant spec section]

            **What we need to know**: [Specific question from NEEDS CLARIFICATION marker]

            **Suggested Answers**:

            | Option | Answer | Implications |
            |--------|--------|--------------|
            | A      | [First suggested answer] | [What this means for the narrative] |
            | B      | [Second suggested answer] | [What this means for the narrative] |
            | C      | [Third suggested answer] | [What this means for the narrative] |
            | Custom | Provide your own answer | [Explain how to provide custom input] |

            **Your choice**: _[Wait for user response]_

            CRITICAL - Table Formatting: Ensure markdown tables are properly formatted:

                Use consistent spacing with pipes aligned

                Each cell should have spaces around content: | Content | not |Content|

                Header separator must have at least 3 dashes: |--------|

                Test that the table renders correctly in markdown preview

            Number questions sequentially (Q1, Q2, Q3 - max 3 total)

            Present all questions together before waiting for responses

            Wait for user to respond with their choices for all questions (e.g., "Q1: A, Q2: Custom - [details], Q3: B")

            Update the spec by replacing each [NEEDS CLARIFICATION] marker with the user's selected or provided answer

            Re-run validation after all clarifications are resolved

    d. Update Checklist: After each validation iteration, update the checklist file with current pass/fail status

    Report completion with narrative name, spec file path, checklist results, and readiness for the next phase (/narrative.clarify or /narrative.plan).

NOTE: The script creates the new directory and initializes the spec file before writing.

General Guidelines

    Focus on WHAT the reader needs and WHY.

    Avoid HOW to write (no specific prose, sentence structure, or word choice).

    Written for a narrative audience, not a technical one.

    DO NOT create any checklists that are embedded in the spec. That will be a separate command.