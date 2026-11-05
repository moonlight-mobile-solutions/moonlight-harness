#!/bin/sh
# Claude Code UserPromptSubmit hook: repeats the delegation thresholds on every prompt.
cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"Delegation is the default (subagent-delegation skill). Send to the executor agent: reading or searching more than 3 files when only the conclusion matters, full test suites, builds or linters, the same mechanical edit in 3 or more files, independent parallel subtasks. Keep in the main session: smaller work, decisions, plans, reviews, tax and financial calculations, secrets, git history, production, external sends."}}
JSON
