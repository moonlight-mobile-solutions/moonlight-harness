# Third-party skills

Skills Moonlight projects use but this repo does not maintain or copy. Install them from their source and keep their license.

| Skill | Stack | Source |
|---|---|---|
| `figma-use`, `figma-generate-design`, `figma-generate-library` | design | Figma plugin for your agent (required by `figma-feature-file-structure`) |
| `fastapi` | python | Official FastAPI skill, distributed by the FastAPI project |
| `vite-react-best-practices` | web | https://github.com/claudiocebpaz/vite-react-best-practices (MIT) |
| `design-taste-frontend` | web | https://github.com/Leonxlnx/taste-skill (MIT). Art direction and browser checks for landing pages, sites and dashboards; web only, needs Node 22+ and Chrome |
| `skill-creator` | all | Anthropic skills, to write new skills in the right format |

Install `design-taste-frontend` from a clone so `git pull` updates it: `git clone https://github.com/Leonxlnx/taste-skill && ./taste-skill/install.sh --all-agents`. Without a clone: `npx skills add https://github.com/Leonxlnx/taste-skill --skill design-taste-frontend`.

`spec-driven-development` is adapted from [jjeanjacques10/skills](https://github.com/jjeanjacques10/skills) (MIT); attribution is in the skill.

`lgpd-brasil` is adapted from [ericbsantana/llm-skills](https://github.com/ericbsantana/llm-skills) (MIT); attribution is in the skill.

`ux-writing` is adapted from [content-designer/ux-writing-skill](https://github.com/content-designer/ux-writing-skill) (MIT); attribution and license are in the skill.
