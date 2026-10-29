# Adopting the Harness in a Project

## 1. Install the shared skills on your machine

```bash
git clone https://github.com/moonlight-mobile-solutions/moonlight-harness.git
cd moonlight-harness
./scripts/install.sh --dry-run   # shows what would change
./scripts/install.sh             # links every skill for Claude Code and the agents that read ~/.agents/skills
```

See the main README for `--agent` and `--stack`.

## 2. Prepare the project

```bash
./scripts/link-project.sh ~/path/to/project --name myapp --stack flutter
```

It creates, without overwriting anything that already exists:

| Path | Purpose |
|---|---|
| `AGENTS.md` | Entry point for every agent, generated from `harness/templates/AGENTS.md` |
| `CLAUDE.md` | One line, `@AGENTS.md`, because Claude Code does not read `AGENTS.md` on its own |
| `.agents/skills/` | Project skills, read by Codex, Gemini CLI, Cursor and Copilot |
| `.claude/skills` | Symlink to `../.agents/skills`, read by Claude Code |
| `.agents/rules/` | Standing rules of the project (language, punctuation, release cadence...) |

Then fill the `TODO` markers in `AGENTS.md`.

## 3. Write project skills in layers

A project skill holds **only** what is specific to the project and names the shared skill it builds on.

- Name: `<project>-<topic>` (e.g. `myapp-testing`), so it never collides with a shared skill.
- First line of the body: `Builds on <shared-skill>. Load both.`
- No copy of the shared rules. If a rule is useful to every project, open a PR here instead.

Map each task to its pair of skills in the "Skills" table of the project's `AGENTS.md`.

## 4. Keep it current

```bash
cd moonlight-harness && git pull
```

The skills are symlinks, so a pull updates every agent at once. Run `./scripts/install.sh` again only when new skills were added.
