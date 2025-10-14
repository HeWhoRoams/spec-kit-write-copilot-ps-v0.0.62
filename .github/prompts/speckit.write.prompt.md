### 4. `narrative.write.md`
This command, a counterpart to `speckit.implement`, is the final step in the workflow. It directs the AI to execute the scene-by-scene writing tasks from the `scenes.md` file, checking them off as they are completed.

```markdown
---
description: Execute the narrative plan by processing and executing all scenes defined in scenes.md
scripts:
  sh: scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
  ps: scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks
---

## User Input

```text
$ARGUMENTS

You MUST consider the user input before proceeding (if not empty).

Outline

    Run {SCRIPT} from repo root and parse NARRATIVE_DIR and AVAILABLE_DOCS list. All paths must be absolute. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'''m Groot' (or double-quote if possible: "I'm Groot").

    Check checklists status (if NARRATIVE_DIR/checklists/ exists):

        Scan all checklist files in the checklists/ directory

        For each checklist, count:

            Total items: All lines matching - [ ] or - [X] or - [x]

            Completed items: Lines matching - [X] or - [x]

            Incomplete items: Lines matching - [ ]

        Create a status table:

        | Checklist | Total | Completed | Incomplete | Status |
        |-----------|-------|-----------|------------|--------|
        | pacing.md     | 12    | 12        | 0          | ✓ PASS |
        | character.md   | 8     | 5         | 3          | ✗ FAIL |
        | consistency.md | 6   | 6         | 0          | ✓ PASS |

        Calculate overall status:

            PASS: All checklists have 0 incomplete items

            FAIL: One or more checklists have incomplete items

        If any checklist is incomplete:

            Display the table with incomplete item counts

            STOP and ask: "Some checklists are incomplete. Do you want to proceed with writing anyway? (yes/no)"

            Wait for user response before continuing

            If user says "no" or "wait" or "stop", halt execution

            If user says "yes" or "proceed" or "continue", proceed to step 3

        If all checklists are complete:

            Display the table showing all checklists passed

            Automatically proceed to step 3

    Load and analyze the narrative context:

        REQUIRED: Read scenes.md for the complete scene list and writing plan

        REQUIRED: Read narrative-outline.md for plot structure, pacing, and chapter structure

        IF EXISTS: Read character-model.md for character entities and relationships

        IF EXISTS: Read research-notes.md for research decisions and constraints

        IF EXISTS: Read quickstart.md for writing examples

    Narrative Setup Verification:

        REQUIRED: Create/verify ignore files based on actual project setup:

    Detection & Creation Logic:

        Check if the following command succeeds to determine if the repository is a git repo (create/verify .gitignore if so):
        Bash

        git rev-parse --git-dir 2>/dev/null

        Check if the writing format is a specific type (e.g., Markdown, plaintext, etc.) → create/verify ignore files as needed.

    If ignore file already exists: Verify it contains essential patterns, append missing critical patterns only
    If ignore file missing: Create with full pattern set for detected writing format

    Parse scenes.md structure and extract:

        Writing phases: Setup, Foundational, Character Arcs, Polish

        Scene dependencies: Sequential vs parallel writing rules

        Scene details: ID, description, file paths, parallel markers [P]

        Execution flow: Order and dependency requirements

    Execute writing following the scene plan:

        Phase-by-phase execution: Complete each phase before moving to the next

        Respect dependencies: Draft sequential scenes in order, parallel scenes [P] can run together

        File-based coordination: Tasks affecting the same files must run sequentially

        Validation checkpoints: Verify each phase completion before proceeding

    Writing execution rules:

        Setup first: Initialize narrative structure, world-building, character outlines

        Foundational writing: Draft key plot points, core conflicts, and motivations

        Character arc drafting: Implement character development and subplots

        Polish and validation: Proofread, refine, and ensure consistency

    Progress tracking and error handling:

        Report progress after each completed scene

        Halt execution if any non-parallel task fails

        For parallel scenes [P], continue with successful scenes, report failed ones

        Provide clear error messages with context for debugging

        Suggest next steps if writing cannot proceed

        IMPORTANT For completed scenes, make sure to mark the scene off as [X] in the scenes file.

    Completion validation:

        Verify all required scenes are completed

        Check that written scenes match the original narrative specification

        Validate that the narrative follows the outline

        Report final status with a summary of completed work

Note: This command assumes a complete scene breakdown exists in scenes.md. If scenes are incomplete or missing, suggest running /narrative.tasks first to regenerate the scene list.