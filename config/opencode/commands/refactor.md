---
description: Safely refactor code without changing behavior
agent: refactor
subtask: true
---

Refactor $ARGUMENTS for clarity and maintainability without changing behavior.

If $ARGUMENTS is empty, check what has changed recently and suggest refactoring opportunities.

**Rules:**

- Behavior must not change — verify with existing tests before and after
- Use existing patterns — don't introduce new abstractions unless necessary
- Prefer small, independent changes over large rewrites
- Before each edit, explain your reasoning in one sentence
- Ask before making any write, edit, rm, or bash operation
- Run existing tests after changes to confirm no regression

Focus on: extract functions, reduce nesting, remove duplication, improve naming, simplify conditionals, replace magic values with constants, remove dead code.
