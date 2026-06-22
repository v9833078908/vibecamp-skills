#!/usr/bin/env bash
# Install VibeCamp skills into every detected agent's skill directory.
# Run from anywhere for user-global install, or inside a landing repo and pass
# --local to install project-local (./.claude/skills, ./.codex/skills).
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)/plugins/vibecamp-landing-kit/skills"
LOCAL=0
[ "${1:-}" = "--local" ] && LOCAL=1

if [ "$LOCAL" = "1" ]; then
  TARGETS=("./.claude/skills" "./.codex/skills" "./.cursor/skills")
else
  TARGETS=("$HOME/.claude/skills" "$HOME/.codex/skills" "$HOME/.cursor/skills")
fi

installed=0
for base in "${TARGETS[@]}"; do
  parent="$(dirname "$base")"
  # only install where the agent home already exists (skip absent agents)
  [ "$LOCAL" = "1" ] || [ -d "$parent" ] || continue
  mkdir -p "$base"
  cp -R "$SRC/." "$base/"
  echo "installed -> $base"
  installed=$((installed+1))
done

[ "$installed" -gt 0 ] || { echo "no agent homes found (~/.claude, ~/.codex, ~/.cursor)"; exit 1; }
echo "done: $installed target(s)"
