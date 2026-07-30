---
description: Security audit of staged changes or a specific file/path
agent: security-auditor
subtask: true
---

Audit $ARGUMENTS for security vulnerabilities.

If $ARGUMENTS is empty, audit all staged changes (`git diff --cached`) and any relevant configuration files.

Check for:

- Input validation (SQLi, XSS, command injection, path traversal)
- Authentication and authorization flaws
- Data exposure (hardcoded secrets, PII in logs)
- Dependency vulnerabilities
- Cryptography misuse
- Configuration security (CORS, debug mode, permissions)

Report each finding with:

- **Severity:** Critical / High / Medium / Low
- **File:** path:line
- **Issue:** what the problem is
- **Risk:** what an attacker could exploit
- **Fix:** concrete recommendation

Be thorough. If nothing is found, explicitly state that no vulnerabilities were detected.
