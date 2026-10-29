# Secrets

- Secrets live only in `.env` (gitignored) or the CI secret store. Never in code, Git, prompts, skills or issue/PR text.
- Before committing, check `git diff --cached` for keys, tokens, keystores, service-account files and client data.
- Found a secret in history? Rotate it first, then clean the history. Cleaning without rotating is not a fix.
