---
description: Write documentation for a feature, module, or change
agent: docs-writer
subtask: true
---

Write documentation for $ARGUMENTS.

1. Read the relevant code and any existing documentation to understand context
2. Check if documentation already exists for this area
3. Write clear, concise docs matching the project's existing style
4. Use concrete examples over abstract descriptions
5. Ask before writing or editing any file

If $ARGUMENTS is empty, check what has changed recently (`git diff --cached`, `git diff`) and document the changes.

If the area is already well-documented, suggest improvements rather than rewriting.
