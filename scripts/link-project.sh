#!/usr/bin/env bash
# Prepares a project for the harness: AGENTS.md, CLAUDE.md, .agents/skills and the .claude/skills link.
# Never overwrites a file that already exists.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATES="$ROOT/harness/templates"

usage() {
  cat <<EOF
Usage: scripts/link-project.sh <project-dir> [--name NAME] [--stack LIST] [--dry-run]

  --name NAME    project name used in AGENTS.md (default: the directory name)
  --stack LIST   comma-separated stacks the project uses, e.g. flutter,python (default: common)
  --dry-run      print what would change, change nothing
EOF
}

[ $# -ge 1 ] || { usage >&2; exit 2; }
case "$1" in -h|--help) usage; exit 0 ;; esac

project="$1"; shift
name=""
stacks="common"
dry_run=false

while [ $# -gt 0 ]; do
  case "$1" in
    --name) name="${2:?--name needs a value}"; shift 2 ;;
    --stack) stacks="${2:?--stack needs a value}"; shift 2 ;;
    --dry-run) dry_run=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[ -d "$project" ] || { echo "Not a directory: $project" >&2; exit 2; }
project="$(cd "$project" && pwd)"
[ -n "$name" ] || name="$(basename "$project")"

for stack in ${stacks//,/ }; do
  [ -d "$ROOT/skills/$stack" ] || { echo "Unknown stack '$stack'. Known: $(find "$ROOT/skills" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort | tr '\n' ' ')" >&2; exit 2; }
done

run() {
  if $dry_run; then
    echo "    [dry-run] $*"
  else
    "$@"
  fi
}

skip() { echo "  = $1 (already exists, left as is)"; }

sed_escape() { printf '%s' "$1" | sed -e 's/[&|\\]/\\&/g'; }

if [ -e "$project/AGENTS.md" ]; then
  skip AGENTS.md
else
  echo "  + AGENTS.md"
  if ! $dry_run; then
    tmp="$(mktemp "$project/.AGENTS.md.XXXXXX")"
    sed -e "s|{{PROJECT_NAME}}|$(sed_escape "$name")|g" -e "s|{{STACKS}}|$(sed_escape "${stacks//,/, }")|g" "$TEMPLATES/AGENTS.md" > "$tmp" \
      || { rm -f "$tmp"; echo "Could not render AGENTS.md" >&2; exit 1; }
    chmod 644 "$tmp"
    mv "$tmp" "$project/AGENTS.md"
  fi
fi

if [ -e "$project/CLAUDE.md" ]; then
  skip CLAUDE.md
else
  echo "  + CLAUDE.md"
  run cp "$TEMPLATES/CLAUDE.md" "$project/CLAUDE.md"
fi

for dir in .agents/skills .agents/rules; do
  if [ -d "$project/$dir" ]; then
    skip "$dir/"
  else
    echo "  + $dir/"
    run mkdir -p "$project/$dir"
  fi
done

for rule in "$TEMPLATES"/rules/*.md; do
  target="$project/.agents/rules/$(basename "$rule")"
  if [ -e "$target" ]; then
    skip ".agents/rules/$(basename "$rule")"
  else
    echo "  + .agents/rules/$(basename "$rule")"
    run cp "$rule" "$target"
  fi
done

if [ -e "$project/.claude/skills" ] || [ -L "$project/.claude/skills" ]; then
  skip .claude/skills
else
  echo "  + .claude/skills -> ../.agents/skills"
  run mkdir -p "$project/.claude"
  run ln -s ../.agents/skills "$project/.claude/skills"
fi

$dry_run && echo "Dry run: nothing changed." || echo "Done. Fill the TODO markers in AGENTS.md."
