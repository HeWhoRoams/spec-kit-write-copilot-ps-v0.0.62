# Narrative Outline & Plan: [NARRATIVE]

**Narrative**: `[###-narrative-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Narrative specification from `/narratives/[###-narrative-name]/narrative-spec.md`

**Note**: This template is filled in by the `/narrative.plan` command.

## Summary

[Extract from narrative spec: primary requirement + narrative approach from research]

## Narrative Context

**Genre/Style**: [e.g., Historical Fiction, Literary Non-Fiction, Fantasy or NEEDS CLARIFICATION]
**Primary Tropes**: [e.g., Hero's Journey, Chosen One, Fish Out of Water or NEEDS CLARIFICATION]
**Narrative Voice**: [e.g., First-person, Omniscient Third-person, Limited Third-person or NEEDS CLARIFICATION]
**Pacing**: [e.g., Slow burn, Fast-paced, Episodic or NEEDS CLARIFICATION]
**Target Audience**: [e.g., Young Adult, Academic, General Public or NEEDS CLARIFICATION]
**Total Length**: [e.g., 80,000 words, 10 chapters, 5-page article or NEEDS CLARIFICATION]
**Constraints**: [e.g., Must be historically accurate, must be suitable for all ages or NEEDS CLARIFICATION]

## Narrative Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 outlining.*

[Gates determined based on constitution file]

## Project Structure

### Documentation (this narrative)

narratives/[###-narrative]/
├── narrative-outline.md  # This file (/narrative.plan command output)
├── research-notes.md     # Phase 0 output (/narrative.plan command)
├── character-model.md    # Phase 1 output (/narrative.plan command)
├── quickstart.md         # Phase 1 output (/narrative.plan command)
└── scenes.md             # Phase 2 output (/narrative.tasks command - NOT created by /narrative.plan)


### Manuscript

src/
├── part_1_rising_action/
│   ├── chapter_01.md
│   └── chapter_02.md
├── part_2_climax/
└── part_3_resolution/


**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th point of view] | [current need] | [why 3 POVs insufficient] |