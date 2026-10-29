#!/usr/bin/env bash
# Links the harness skills into each agent's user-level skills directory.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$ROOT/skills"
CONF="$ROOT/scripts/agents.conf"
BACKUP_ROOT="${MOONLIGHT_HARNESS_BACKUP_DIR:-$HOME/.moonlight-harness/backups}"
STAMP="$(date +%Y%m%d-%H%M%S)"

agents="claude,agents"
stacks="all"
mode="install"
dry_run=false

usage() {
  cat <<EOF
Usage: scripts/install.sh [options]

  --agent LIST    comma-separated agents from scripts/agents.conf (default: claude,agents)
  --stack LIST    comma-separated stacks under skills/, or "all" (default: all)
  --dry-run       print what would change, change nothing
  --uninstall     remove only the links that point into this repo
  --list          list the skills of the selected stacks and exit
  -h, --help      show this help

An existing skill with the same name is moved to $BACKUP_ROOT/<timestamp>/<agent>/ before linking,
and --uninstall moves the latest backup back.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --agent) agents="${2:?--agent needs a value}"; shift 2 ;;
    --stack) stacks="${2:?--stack needs a value}"; shift 2 ;;
    --dry-run) dry_run=true; shift ;;
    --uninstall) mode="uninstall"; shift ;;
    --list) mode="list"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

run() {
  if $dry_run; then
    echo "    [dry-run] $*"
  else
    "$@"
  fi
}

agent_dir() {
  local dir
  dir="$(awk -v name="$1" '$1 == name { print $2 }' "$CONF")"
  if [ -z "$dir" ]; then
    echo "Unknown agent '$1'. Known: $(awk '!/^#/ && NF { printf "%s ", $1 }' "$CONF")" >&2
    exit 2
  fi
  echo "${dir/\$HOME/$HOME}"
}

selected_stacks() {
  if [ "$stacks" = "all" ]; then
    find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
    return
  fi
  local stack
  for stack in ${stacks//,/ }; do
    if [ ! -d "$SKILLS_DIR/$stack" ]; then
      echo "Unknown stack '$stack'. Known: $(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort | tr '\n' ' ')" >&2
      exit 2
    fi
    echo "$stack"
  done
}

selected_skills() {
  local stack
  for stack in $(selected_stacks); do
    find "$SKILLS_DIR/$stack" -mindepth 2 -maxdepth 2 -name SKILL.md -exec dirname {} \; | sort
  done
}

points_into_repo() {
  [ -L "$1" ] && case "$(readlink "$1")" in "$SKILLS_DIR"/*) true ;; *) false ;; esac
}

prune_stale_links() {
  local dest="$1" link
  for link in "$dest"/*; do
    if points_into_repo "$link" && [ ! -e "$link" ]; then
      echo "  - $(basename "$link") (no longer in the harness)"
      run rm "$link"
    fi
  done
}

install_into() {
  local agent="$1" dest="$2" src name target
  [ -d "$dest" ] || run mkdir -p "$dest"
  while IFS= read -r src; do
    name="$(basename "$src")"
    target="$dest/$name"
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
      echo "  = $name"
      continue
    fi
    if [ -e "$target" ] || [ -L "$target" ]; then
      echo "  ~ $name (backup of the existing one in $BACKUP_ROOT/$STAMP/$agent)"
      run mkdir -p "$BACKUP_ROOT/$STAMP/$agent"
      run mv "$target" "$BACKUP_ROOT/$STAMP/$agent/"
    else
      echo "  + $name"
    fi
    run ln -s "$src" "$target"
  done < <(selected_skills)
  [ -d "$dest" ] && prune_stale_links "$dest"
  return 0
}

latest_backup() {
  [ -d "$BACKUP_ROOT" ] || return 0
  find "$BACKUP_ROOT" -mindepth 3 -maxdepth 3 -path "*/$1/$2" | sort | tail -n1
}

uninstall_from() {
  local agent="$1" dest="$2" link name backup
  [ -d "$dest" ] || return 0
  for link in "$dest"/*; do
    if points_into_repo "$link"; then
      name="$(basename "$link")"
      echo "  - $name"
      run rm "$link"
      backup="$(latest_backup "$agent" "$name")"
      if [ -n "$backup" ]; then
        echo "  < $name (restored from $backup)"
        run mv "$backup" "$dest/$name"
      fi
    fi
  done
}

selected_stacks > /dev/null

if [ "$mode" = "list" ]; then
  while IFS= read -r src; do
    echo "$(basename "$(dirname "$src")")/$(basename "$src")"
  done < <(selected_skills)
  exit 0
fi

duplicates="$(selected_skills | while IFS= read -r src; do basename "$src"; done | sort | uniq -d)"
if [ -n "$duplicates" ]; then
  echo "Skill names must be unique across stacks: $duplicates" >&2
  exit 1
fi

for agent in ${agents//,/ }; do
  dest="$(agent_dir "$agent")"
  echo "$agent -> $dest"
  if [ "$mode" = "uninstall" ]; then
    uninstall_from "$agent" "$dest"
  else
    install_into "$agent" "$dest"
  fi
done

$dry_run && echo "Dry run: nothing changed."
exit 0
