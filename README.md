# Moonlight Harness

How Moonlight Mobile Solutions builds software with AI coding agents: the development standard every project follows, the shared skills agents load, and scripts that install them the same way for Claude Code, Codex, Gemini CLI, Cursor and GitHub Copilot, on macOS, Linux and Windows.

*Português abaixo.*

## What's inside

| Path | What it is |
|---|---|
| [`harness/principles.md`](harness/principles.md) | The standard: plan before code, small traceable changes, quality gate, review before push, secrets, working with agents |
| [`harness/project-setup.md`](harness/project-setup.md) | How to adopt the harness in a project and write project skills in layers |
| [`harness/templates/`](harness/templates/) | `AGENTS.md`, `CLAUDE.md` and `.agents/rules/` for a new project |
| [`skills/`](skills/) | Shared skills by stack: [`common`](skills/common/), [`flutter`](skills/flutter/), [`python`](skills/python/), [`design`](skills/design/) |
| [`third-party.md`](third-party.md) | Skills we use but don't maintain, with where to get them |
| [`scripts/`](scripts/) | Installers and the repo check |

`common` holds what every stack shares (e.g. `coding-principles`); a stack skill holds only what is specific to its language and names the common skill it builds on (e.g. `flutter-coding-principles`).

## Install the skills

Clone once and keep the clone: the skills are linked, not copied, so `git pull` updates every agent.

macOS / Linux:

```bash
git clone https://github.com/moonlight-mobile-solutions/moonlight-harness.git ~/moonlight-harness
cd ~/moonlight-harness
./scripts/install.sh --dry-run
./scripts/install.sh
```

Windows (PowerShell 5.1 or 7):

```powershell
git clone https://github.com/moonlight-mobile-solutions/moonlight-harness.git $HOME\moonlight-harness
cd $HOME\moonlight-harness
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -DryRun
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

On Windows the links are directory junctions: no admin rights or Developer Mode needed.

| Option (`install.sh` / `install.ps1`) | Effect |
|---|---|
| `--agent` / `-Agent` | Agents from [`scripts/agents.conf`](scripts/agents.conf). Default `claude,agents` |
| `--stack` / `-Stack` | `all` (default) or a list such as `common,flutter` |
| `--dry-run` / `-DryRun` | Show what would change |
| `--uninstall` / `-Uninstall` | Remove only the links that point into this repo |
| `--list` / `-List` | List the skills |

Where each agent reads the skills:

| Agent | Directory | Installed by |
|---|---|---|
| Claude Code | `~/.claude/skills` | `claude` |
| Codex, Gemini CLI, Cursor | `~/.agents/skills` | `agents` |
| GitHub Copilot | `~/.copilot/skills` | `copilot` |
| Gemini, Cursor, Copilot own folders | `~/.gemini/skills`, `~/.cursor/skills`, `~/.copilot/skills` | `gemini`, `cursor`, `copilot` (only if your version doesn't read `~/.agents/skills`) |

A skill that already exists with the same name is moved to `~/.moonlight-harness/backups/<timestamp>/` before it is replaced, and uninstall puts it back. Nothing else in those folders is touched.

## Prepare a project

```bash
./scripts/link-project.sh ~/dev/myapp --name myapp --stack flutter
```

```powershell
.\scripts\link-project.ps1 -Project C:\dev\myapp -Name myapp -Stack flutter
```

Creates `AGENTS.md`, `CLAUDE.md`, `.agents/skills/`, `.agents/rules/` and the `.claude/skills` link, without overwriting anything. Details in [`harness/project-setup.md`](harness/project-setup.md).

Windows and the committed `.claude/skills` symlink: turn on Developer Mode and run `git config --global core.symlinks true` before cloning a project, otherwise Git checks the link out as a plain text file.

## Contributing

1. One skill per folder: `skills/<stack>/<name>/SKILL.md`, with `name` equal to the folder and a `description` that says when to load it.
2. List it in `skills/<stack>/README.md`.
3. Run `./scripts/check.sh` (frontmatter, unique names, secrets, shellcheck). CI runs it plus gitleaks on every PR.
4. This repo is public: no client names, no internal URLs, no IDs, no secrets. Put the names you must never publish in `.denylist.local` (gitignored) and `check.sh` blocks them.

## License

[MIT](LICENSE).

---

## Português

O harness define como a Moonlight desenvolve software com agentes de IA. Ele tem três partes: o padrão que todo projeto segue, as skills compartilhadas por stack e os instaladores que deixam tudo igual no Claude Code, Codex, Gemini CLI, Cursor e Copilot, em macOS, Linux e Windows.

1. Clone o repo e rode `./scripts/install.sh` (macOS/Linux) ou `.\scripts\install.ps1` (Windows). Comece com `--dry-run` / `-DryRun` para ver o que muda.
2. Em cada projeto, rode `link-project` e preencha os `TODO` do `AGENTS.md`.
3. Skill de projeto só tem o que é do projeto e cita a skill compartilhada em que se apoia.
4. Para atualizar, rode `git pull` no clone, porque as skills são links.

O repo é público. Nada de nome de cliente, URL interna, ID ou segredo. O `check.sh` e o CI barram o que der para barrar automaticamente.
