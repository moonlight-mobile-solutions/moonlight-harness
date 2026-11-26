# Third-party skills

Skills Moonlight projects use but this repo does not maintain or copy. Install them from their source and keep their license.

| Skill | Stack | Source |
|---|---|---|
| `figma-use`, `figma-generate-design`, `figma-generate-library` | design | Figma plugin for your agent (required by `figma-feature-file-structure`) |
| `fastapi` | python | Official FastAPI skill, distributed by the FastAPI project |
| `vite-react-best-practices` | web | https://github.com/claudiocebpaz/vite-react-best-practices (MIT) |
| `design-taste-frontend` | web | https://github.com/Leonxlnx/taste-skill (MIT). Art direction and browser checks for landing pages, sites and dashboards; web only, needs Node 22+ and Chrome |
| `security-audit` | all | https://github.com/cloudflare/security-audit-skill (MIT). Security guidance by default; a six-phase codebase audit with reports when asked explicitly. Needs Node, parallel sub-agents and an OS sandbox to run target code |
| `firebase-*`, `firestore-rules-creation`, `extension-to-functions-codebase`, `xcode-project-setup` | all | https://github.com/firebase/agent-skills (Apache-2.0). Official Firebase skills: CLI and projects, Auth, Firestore and rules, Hosting, App Hosting, Data Connect, Crashlytics, Analytics, Remote Config, AI Logic. Also ships as the `firebase@firebase` Claude Code plugin, which adds the Firebase MCP server |
| `grilling`, `grill-me`, `grill-with-docs`, `domain-modeling`, `codebase-design`, `improve-codebase-architecture`, `diagnosing-bugs`, `prototype`, `handoff`, `wait-what`, `to-questionnaire`, `writing-for-agents` | all | https://github.com/mattpocock/skills (MIT). Interview to stress-test a plan, domain glossary and ADRs, module design, bug diagnosis loop, throwaway prototypes and handoffs. `domain-modeling`, `grill-with-docs` and `improve-codebase-architecture` write `GLOSSARY.md` and ADRs into the project |
| `skill-creator` | all | Anthropic skills, to write new skills in the right format |

Install `design-taste-frontend` from a clone so `git pull` updates it: `git clone https://github.com/Leonxlnx/taste-skill && ./taste-skill/install.sh --all-agents`. Without a clone: `npx skills add https://github.com/Leonxlnx/taste-skill --skill design-taste-frontend`.

Install `security-audit` from a clone too. The repo has no installer, so link the skill folder into each agent: `git clone https://github.com/cloudflare/security-audit-skill && ln -s "$PWD/security-audit-skill/skills/security-audit" ~/.claude/skills/security-audit` (same for `~/.codex/skills`). Without a clone: `npx skills add https://github.com/cloudflare/security-audit-skill --skill security-audit --global`.

Install the Firebase skills from a clone too. The repo has no installer, so link each folder of `skills/` into each agent: `git clone https://github.com/firebase/agent-skills && for s in agent-skills/skills/*/; do ln -s "$PWD/${s%/}" ~/.claude/skills/$(basename "$s"); done` (same for `~/.codex/skills`). Without a clone: `npx skills add firebase/skills`. Keep the Claude Code plugin (`claude plugin install firebase@firebase`) if you use the Firebase MCP server; the links do not bring it.

Install the Matt Pocock skills from a clone and link only the ones listed above: `git clone https://github.com/mattpocock/skills mattpocock-skills && for n in grilling grill-me grill-with-docs domain-modeling codebase-design improve-codebase-architecture diagnosing-bugs prototype handoff wait-what to-questionnaire writing-for-agents; do for p in "$PWD"/mattpocock-skills/skills/{engineering,productivity}/"$n"; do [ -d "$p" ] && ln -s "$p" ~/.claude/skills/"$n"; done; [ -e ~/.claude/skills/"$n" ] || echo "missing: $n"; done` (same for `~/.codex/skills`). Don't install the whole set or its plugin: `code-review` shares its name with the agent's own review command, and `pr`, `tdd`, `to-spec`, `to-tickets`, `implement`, `implement-spec`, `triage`, `wayfinder`, `ask-matt` and `setup-matt-pocock-skills` compete with the harness standard and its skills.

`spec-driven-development` is adapted from [jjeanjacques10/skills](https://github.com/jjeanjacques10/skills) (MIT); attribution is in the skill.

`lgpd-brasil` is adapted from [ericbsantana/llm-skills](https://github.com/ericbsantana/llm-skills) (MIT); attribution is in the skill.

`subagent-delegation` is based on the video "O NOVO JEITO de usar o Claude Code: o Opus vira o chefe (e o Haiku trabalha)"; the source is cited in the skill.

`ux-writing` is adapted from [content-designer/ux-writing-skill](https://github.com/content-designer/ux-writing-skill) (MIT); attribution and license are in the skill.

`humanizer` is copied from [blader/humanizer](https://github.com/blader/humanizer) (MIT); attribution and license are in the skill.
