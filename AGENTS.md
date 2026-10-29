# AGENTS.md - Moonlight Harness

This repo is **public**. It holds the Moonlight development standard (`harness/`), the shared skills (`skills/<stack>/<name>/SKILL.md`) and their installers (`scripts/`).

## Rules

1. **Nothing sensitive.** No client or project names, internal URLs, IDs, emails, personal paths or secrets. Skills use placeholders (`<project-id>`, `myapp`).
2. **Right stack.** What every stack shares goes to `skills/common/`. A stack skill holds only its language specifics and names the common skill it builds on. Never copy a common rule into a stack skill.
3. **Skill format.** Folder name equals the frontmatter `name` (lowercase kebab-case, at most 64 characters); `description` says what it covers and when to load it (at most 1024 characters). List every skill in `skills/<stack>/README.md`.
4. **Scripts in pairs.** Every change to a `.sh` script gets the same change in its `.ps1` twin, and vice versa. Both must keep working on macOS bash 3.2 and Windows PowerShell 5.1.
5. **Gate.** Run `./scripts/check.sh` before saying "done". It must print `All checks passed.`
6. Plan approved before any change; follow `harness/principles.md`.
