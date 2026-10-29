#!/usr/bin/env bash
# Validates the skills and scans the repo for content that must never be published.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

errors=0
fail() { echo "FAIL $*"; errors=$((errors + 1)); }

frontmatter_field() {
  awk -v field="$2" '
    NR == 1 && $0 != "---" { exit }
    NR > 1 && $0 == "---" { exit }
    NR > 1 && index($0, field ":") == 1 { sub("^" field ":[ ]*", ""); print; exit }
  ' "$1"
}

echo "== skills"
for required in AGENTS.md CLAUDE.md harness/templates/AGENTS.md harness/templates/CLAUDE.md; do
  git ls-files --error-unmatch "$required" > /dev/null 2>&1 || git ls-files --others --exclude-standard --error-unmatch "$required" > /dev/null 2>&1 \
    || fail "$required is not tracked by Git (a global gitignore may hide it)"
done

for stack_dir in skills/*/; do
  stack="$(basename "$stack_dir")"
  [ -f "$stack_dir/README.md" ] || fail "skills/$stack has no README.md"
  for skill_dir in "$stack_dir"*/; do
    name="$(basename "$skill_dir")"
    file="$skill_dir/SKILL.md"
    [ -f "$file" ] || { fail "$skill_dir has no SKILL.md"; continue; }
    [ "$(head -n1 "$file")" = "---" ] || fail "$file does not start with a frontmatter block"
    declared="$(frontmatter_field "$file" name)"
    description="$(frontmatter_field "$file" description)"
    [ "$declared" = "$name" ] || fail "$file declares name '$declared', folder is '$name'"
    [[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || fail "$name is not lowercase-kebab-case"
    [ "${#name}" -le 64 ] || fail "$name is longer than 64 characters"
    [ -n "$description" ] || fail "$file has no description"
    case "$description" in
      \"*|\'*|'>'*|'|'*) ;;
      *': '*) fail "$file description has ': ' unquoted, which is invalid YAML; wrap it in double quotes" ;;
    esac
    [ "${#description}" -le 1024 ] || fail "$file description is longer than 1024 characters"
    grep -q "skills/$stack/$name" "$stack_dir/README.md" 2>/dev/null || fail "skills/$stack/README.md does not list $name"
  done
done

duplicates="$(find skills -mindepth 2 -maxdepth 2 -type d -exec basename {} \; | sort | uniq -d)"
[ -z "$duplicates" ] || fail "skill names must be unique across stacks: $duplicates"

if grep -rns "flutter-python-coding-principles" skills harness README.md AGENTS.md; then
  fail "flutter-python-coding-principles was split; use coding-principles + the stack skill"
fi

echo "== sensitive content"
patterns=(
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'
  'AKIA[0-9A-Z]{16}'
  'AIza[0-9A-Za-z_-]{35}'
  'gh[pousr]_[0-9A-Za-z]{36}'
  'github_pat_[0-9A-Za-z_]{40,}'
  'sk-[A-Za-z0-9_-]{20,}'
  'xox[abpr]-[0-9A-Za-z-]{10,}'
  '[0-9]{8,10}:AA[0-9A-Za-z_-]{33}'
  '"private_key_id"'
  '/Users/[a-z]'
  '/home/[a-z]+/'
  '[A-Za-z]:\\Users\\'
  '[A-Za-z0-9._%+-]+@(gmail|hotmail|outlook|yahoo|icloud)\.com'
  '[^—]—[^—]'
)
for pattern in "${patterns[@]}"; do
  if git grep --untracked -nIE -e "$pattern" -- . ':!scripts/check.sh' 2>/dev/null; then
    fail "matches a secret or personal-data pattern: $pattern"
  fi
done

denylist="${MOONLIGHT_HARNESS_DENYLIST:-$ROOT/.denylist.local}"
if [ -f "$denylist" ]; then
  while IFS= read -r term || [ -n "$term" ]; do
    term="${term%$'\r'}"
    case "$term" in ''|'#'*) continue ;; esac
    if git grep --untracked -nIiF -e "$term" -- . 2>/dev/null; then
      fail "matches a private term from $(basename "$denylist")"
    fi
  done < "$denylist"
else
  echo "  (no .denylist.local; add client and project names there to block them, one per line)"
fi

if command -v gitleaks >/dev/null 2>&1; then
  gitleaks detect --source . --no-banner --redact || fail "gitleaks found something"
else
  echo "  (gitleaks not installed; CI runs it)"
fi

if command -v shellcheck >/dev/null 2>&1; then
  echo "== shellcheck"
  shellcheck -S warning scripts/*.sh || fail "shellcheck"
fi

if [ "$errors" -gt 0 ]; then
  echo "$errors problem(s) found."
  exit 1
fi
echo "All checks passed."
