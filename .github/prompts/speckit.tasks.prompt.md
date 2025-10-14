***

### 7. `narrative.tasks.md`
This command, based on `speckit.tasks`, analyzes your outline and creates a sequential or parallel list of writing tasks. It enables you to draft your novel scene by scene, ensuring that each piece fits into the larger whole.

```markdown
---
description: Generate an actionable, dependency-ordered scenes.md for the narrative based on available design artifacts.
scripts:
  sh: scripts/bash/check-prerequisites.sh --json
  ps: scripts/powershell/check-prerequisites.ps1 -Json
---

## User Input

```text
$ARGUMENTS

You MUST consider the user input before proceeding (if not empty).

Outline

    Setup: Run {SCRIPT} from repo root and parse NARRATIVE_DIR and AVAILABLE_DOCS list. All paths must be absolute. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'''m Groot' (or double-quote if possible: "I'm Groot").

    Load design documents: Read from NARRATIVE_DIR:

        Required: narrative-outline.md (plot structure, pacing, tone), narrative-spec.md (character arcs with priorities)

        Optional: character-model.md (entities), research-notes.md (decisions), quickstart.md (writing examples)

        Note: Not all projects have all documents. Generate scenes based on what's available.

    Execute scene generation workflow (follow the template structure):

        Load narrative-outline.md and extract genre, style, and structure

        Load narrative-spec.md and extract character arcs with their priorities (P1, P2, P3, etc.)

        If character-model.md exists: Extract entities → map to character arcs

        If research-notes.md exists: Extract decisions → generate setup tasks

        Generate tasks ORGANIZED BY CHARACTER ARC:

            Setup tasks (shared world-building needed by all arcs)

            Foundational tasks (prerequisites that must complete before ANY character arc can start)

            For each character arc (in priority order P1, P2, P3...):

                Group all scenes needed to complete JUST that arc

                Include scenes, dialogue, and inner monologue specific to that arc

                Mark which tasks are [P] parallelizable

            Polish/Integration tasks (cross-cutting concerns)

        Apply task rules:

            Different chapters = mark [P] for parallel

            Same chapter = sequential (no [P])

        Number tasks sequentially (S001, S002...)

        Generate a narrative progression graph showing character arc completion order

        Create parallel execution examples per character arc

        Validate task completeness (each character arc has all needed scenes, independently draftable)

    Generate scenes.md: Use .specify/templates/scenes-template.md as structure, fill with:

        Correct narrative name from narrative-outline.md

        Phase 1: Setup tasks (world-building initialization)

        Phase 2: Foundational tasks (blocking prerequisites for all character arcs)

        Phase 3+: One phase per character arc (in priority order from narrative-spec.md)

            Each phase includes: arc goal, independent test criteria, writing tasks

            Clear [Arc] labels (CA1, CA2, CA3...) for each task

            [P] markers for parallelizable tasks within each arc

            Checkpoint markers after each arc phase

        Final Phase: Polish & cross-cutting concerns

        Numbered tasks (S001, S002...) in execution order

        Clear file paths for each task

        Dependencies section showing arc completion order

        Parallel execution examples per arc

        Implementation strategy section (MVP first, incremental delivery)

    Report: Output path to generated scenes.md and summary:

        Total task count

        Task count per character arc

        Parallel opportunities identified

        Suggested MVP scope (typically just Character Arc 1)

Context for task generation: {ARGS}

The scenes.md should be immediately executable - each task must be specific enough that an LLM can complete it without additional context.