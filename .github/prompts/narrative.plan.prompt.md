***

### 5. `narrative.plan.md`
This command, based on `narrative.plan`, orchestrates the creation of your narrative outline, character model, and research notes. It acts as the bridge between your high-level idea and the detailed writing plan.

```markdown
---
description: Execute the narrative planning workflow using the outline template to generate narrative artifacts.
scripts:
  sh: scripts/bash/setup-plan.sh --json
  ps: scripts/powershell/setup-plan.ps1 -Json
agent_scripts:
  sh: scripts/bash/update-agent-context.sh __AGENT__
  ps: scripts/powershell/update-agent-context.ps1 -AgentType __AGENT__
---

## User Input

```text
$ARGUMENTS

You MUST consider the user input before proceeding (if not empty).

Outline

    Setup: Run {SCRIPT} from project root and parse JSON for NARRATIVE_SPEC, NARRATIVE_OUTLINE, NARRATIVES_DIR, NARRATIVE. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'''m Groot' (or double-quote if possible: "I'm Groot").

    Load context: Read NARRATIVE_SPEC and /memory/constitution.md. Load NARRATIVE_OUTLINE template (already copied).

    Execute plan workflow: Follow the structure in NARRATIVE_OUTLINE template to:

        Fill Narrative Context (mark unknowns as "NEEDS CLARIFICATION")

        Fill Narrative Constitution Check section from constitution

        Evaluate gates (ERROR if violations unjustified)

        Phase 0: Generate research-notes.md (resolve all NEEDS CLARIFICATION)

        Phase 1: Generate character-model.md, quickstart.md

        Phase 1: Update agent context by running the agent script

        Re-evaluate Narrative Constitution Check post-design

    Stop and report: Command ends after Phase 2 planning. Report narrative, NARRATIVE_OUTLINE path, and generated artifacts.

Phases

Phase 0: Outline & Research

    Extract unknowns from Narrative Context above:

        For each NEEDS CLARIFICATION → research task

        For each genre/style choice → best practices task

        For each thematic element → patterns task

    Generate and dispatch research agents:

    For each unknown in Narrative Context:
      Task: "Research {unknown} for {narrative context}"
    For each narrative choice:
      Task: "Find best practices for {pacing/style} in {genre}"

    Consolidate findings in research-notes.md using format:

        Decision: [what was chosen]

        Rationale: [why chosen]

        Alternatives considered: [what else evaluated]

Output: research-notes.md with all NEEDS CLARIFICATION resolved

Phase 1: Character & Plot

Prerequisites: research-notes.md complete

    Extract entities from narrative spec → character-model.md:

        Character name, key traits, relationships

        Motivations from narrative requirements

        Arc transitions if applicable

    Generate Plot Points from narrative requirements:

        For each character arc → plot point

        Use standard narrative structures (e.g., three-act structure)

    Agent context update:

        Run {AGENT_SCRIPT}

        These scripts detect which AI agent is in use

        Update the appropriate agent-specific context file

        Add only new narrative technology from current plan

        Preserve manual additions between markers

Output: character-model.md, quickstart.md, agent-specific file

Key rules

    Use absolute paths

    ERROR on gate failures or unresolved clarifications