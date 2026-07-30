---
description: Stage changes, run pre-commit checks, and create a conventional commit with user confirmation at every step
agent: build
---

You are handling a conventional commit workflow. Every step requires user confirmation via the `question` tool. Never stage, commit, or push without asking first.

## Step 1 — Detect pre-commit command

If `$ARGUMENTS` is provided, treat it as the pre-commit command to run.

If `$ARGUMENTS` is empty, auto-detect:

- `.pre-commit-config.yaml` exists → `pre-commit run --all-files`
- `pyproject.toml` exists with `[tool.ruff]` → `uv run ruff check . && uv run ruff format --check .`
- `pyproject.toml` with `[project.scripts]` or `[tool.uv]` → `uv run prek -a`
- `package.json` with `"lint"` script → `npm run lint`
- `Makefile` with `lint` target → `make lint`
- Nothing detected → warn that no pre-commit was detected and proceed

Ask: **"Run `{detected-command}` as pre-commit check?"** — Options: "Yes", "Skip", "Use a different command instead"

If "Use a different command", ask for the command string and use that.

## Step 2 — Run pre-commit

Execute the chosen command. Show the full output.

If it succeeds → proceed to Step 3.

If it fails → Ask: **"Pre-commit check failed. What would you like to do?"** — Options: "Fix issues automatically", "Skip and proceed anyway", "Abort commit".

- If "Fix": attempt to auto-fix (`ruff check --fix`, `pre-commit run` with autofix, etc.). Re-run check.
- If "Skip": proceed.
- If "Abort": stop.

## Step 3 — Show changes and plan staging

Run `git status --short` and `git diff --stat` to list uncommitted changes.

If there are no changes → stop with a message.

Group the changed files into logical categories by directory and purpose. For example:
```
src/auth.py                  (auth feature)
tests/test_auth.py           (auth tests)
docs/api.md                  (docs update)
README.md                    (unrelated formatting fix)
.env                         ⚠️ sensitive — skip by default
```

Ask: **"Here are the changes. Which groups should I stage?"** — List each group as a selectable option. Options should include: "All groups", each individual group, "Custom selection", "Abort".

If "Custom selection": ask the user to specify which files to stage.

## Step 4 — Stage the selected files

`git add <selected files>`

Show confirmation of what was staged. Ask: **"Confirm staging?"** — Options: "Yes, proceed to commit message", "Unstage and redo", "Abort".

## Step 5 — Generate commit message

Run `git diff --cached` to analyze the staged diff. Generate a conventional commit message:

```
type(scope): short summary (max 72 chars)

- bullet point describing each logical change
- focus on WHY, not WHAT
- reference issue numbers if relevant
```

Determine the type:
- `feat` — new feature
- `fix` — bug fix
- `docs` — documentation only
- `refactor` — code change that neither fixes nor adds
- `test` — adding or fixing tests
- `chore` — tooling, config, build, dependencies
- `perf` — performance improvement
- `style` — formatting, missing semicolons, etc. (no logic change)
- `ci` — CI pipeline changes

Determine the scope from the directory or module name.

Show the full message. Ask: **"Use this commit message?"** — Options: "Yes, commit", "Let me edit it", "Write my own", "Regenerate", "Abort".

- If "Edit": present the message in an editable format. Ask the user for their edits and incorporate them.
- If "Write my own": ask the user to type their commit message.
- If "Regenerate": reanalyze and try a different message.
- If "Abort": stop.

## Step 6 — Commit

`git commit -m "type(scope): summary" -m "body..."`

Show the full commit hash.

Check current branch name. If the branch is `main` or `master`, warn: **"Committing directly to the {branch} branch. Are you sure?"** — Options: "Yes, commit anyway", "Abort".

Ask: **"Commit successful. Push to remote?"** — Options: "Yes", "No".

## Step 7 — Push (if requested)

`git push`

Show the push output.

## Final summary

Show a clean summary:
- Commit hash
- Branch
- Files changed count
- Whether pushed
- Whether pre-commit was run and passed
