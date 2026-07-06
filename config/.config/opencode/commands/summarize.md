---
description: Generate a comprehensive situation report (context, achievements, blockers, goals) for the current task — formatted to feed another LLM
agent: plan
---

You are generating a situation report for an external LLM that has no prior context. Be thorough, specific, and self-contained.

## Scope

If `$ARGUMENTS` is provided, focus on that specific problem or area. If empty, infer the scope from the conversation history: what has the user been working on? What files have been modified? What is the recurring theme?

## Instructions

1. **Read every relevant file** — identify and read all config files, code files, and documentation relevant to the current situation. Include exact file paths, line numbers, and quoted content. Do not summarize config snippets — quote exact lines so the external LLM can reproduce them.

2. **Compile the report** in this exact structure:

---

### Goal
One sentence: what the user is ultimately trying to achieve.

### Current State
What works right now. List every achieved milestone with the specific config or code that makes it work.

### Constraints & Preferences
- Technical constraints (e.g., "cannot override X because it breaks Y")
- User preferences (e.g., "prefers muted colors", "wants session name in center", "does not want plugin Z")
- Environment details (OS, terminal emulator, terminal colorscheme, nvim colorscheme, font, tool versions)

### Progress
- **Done** — completed items
- **In Progress** — items being actively worked on
- **Blocked** — items that cannot proceed due to a blocker

### Blockers & Roadblocks
For each blocked item, explain:
- What was tried
- Why it failed
- The technical reason (not just "it broke" — explain WHY it broke at the tool/API/library level)
- What constraint prevents a solution

### Relevant Config & Code Snippets
Exact quotes from files, with file paths and line numbers. Use code fences with the appropriate language tag. This is the most critical section — the external LLM needs to see the actual configuration to understand the constraints.

### Decisions & Discoveries
Notable technical insights found during the work — workarounds, edge cases, undocumented behaviors, or clever approaches that should be preserved.

### How to Safely Modify This Setup
Rules and gotchas for anyone proposing changes. What breaks? What is safe? What patterns are known to work?

### Open Questions
Anything still undecided, unexplored, or needing further investigation.

---

## Output Format

The output must be plain markdown ready to copy-paste into another LLM's chat. No conversational wrapping — just the report. Use consistent heading levels and clear section breaks.
