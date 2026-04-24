#!/usr/bin/env bash
#
# Marko installer — Claude Code + Codex
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/julianmemberstack/marko/main/install.sh | bash
#
# Flags (when run locally):
#   --claude-only    install only for Claude Code
#   --codex-only     install only for Codex
#   --local          copy from the current checkout instead of downloading

set -euo pipefail

REPO="julianmemberstack/marko"
BRANCH="main"
BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"

MODE="both"
SOURCE="remote"

for arg in "$@"; do
  case "$arg" in
    --claude-only) MODE="claude" ;;
    --codex-only)  MODE="codex"  ;;
    --local)       SOURCE="local" ;;
    -h|--help)
      sed -n '1,16p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

fetch() {
  # $1 = source path relative to repo root, $2 = destination absolute path
  if [[ "$SOURCE" == "local" ]]; then
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cp "${script_dir}/$1" "$2"
  else
    curl -fsSL "${BASE}/$1" -o "$2"
  fi
}

install_claude() {
  local dir="${HOME}/.claude/skills/marko"
  mkdir -p "$dir"
  fetch "SKILL.md" "${dir}/SKILL.md"
  echo "[ok] Claude Code  -> ${dir}/SKILL.md"
}

install_codex() {
  local dir="${HOME}/.codex/prompts"
  mkdir -p "$dir"
  fetch "codex/marko.md" "${dir}/marko.md"
  echo "[ok] Codex        -> ${dir}/marko.md"
}

echo "Installing Marko..."

case "$MODE" in
  claude) install_claude ;;
  codex)  install_codex  ;;
  both)   install_claude; install_codex ;;
esac

cat <<'EOF'

Marko is installed.

  Claude Code: restart your session, then try "marko?" on a branch with changes.
  Codex:       type /marko in a session.

He will not be impressed.
EOF
