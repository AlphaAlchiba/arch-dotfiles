---
description: Review staged and unstaged changes for code quality and best practices
agent: review
subtask: true
---

Review all staged changes (`git diff --cached`) and unstaged changes (`git diff`) for code quality and best practices.

Focus on:

- Code quality and best practices
- Potential bugs and edge cases
- Performance implications
- Security considerations
- Error handling gaps

Show each issue with file path, line numbers, and a clear description. Distinguish between: **must fix** (bug or regression), **should fix** (code quality), and **nice to have** (style or minor improvement).

Skip trivial formatting concerns unless they indicate a deeper issue. Be constructive — suggest the fix, don't just flag the problem.
