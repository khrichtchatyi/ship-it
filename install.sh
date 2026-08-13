#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2026 Maxim Khrichtchatyi
# SPDX-License-Identifier: MIT
#
# install.sh — install ship-it skills (commit, open-pr) for coding agents.
#
# opencode skills are linked globally into ~/.config/opencode/skills; Cursor
# rules and Copilot instructions are rendered into the current project
# (.cursor/rules and .github/instructions) because those tools are
# project-scoped. The canonical source is skills/<name>/SKILL.md; Cursor and
# Copilot files are generated from it on each run, so edit the SKILL.md files
# and re-run this script to refresh the generated copies.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
SKILLS=(commit open-pr)
MARKER="managed by ship-it install.sh"

OPENCODE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills"
CURSOR_DIR=".cursor/rules"
COPILOT_DIR=".github/instructions"

DO_OPENCODE=0
DO_CURSOR=0
DO_COPILOT=0
REMOVE=0
FORCE=0

declare -A CURSOR_DESC=(
  [commit]="Commit, stage, or record changes in the working tree with one Conventional Commits message."
  [open-pr]="Open a pull request for the current branch on GitHub."
)

usage() {
  cat <<'EOF'
Usage: install.sh [options]

Install ship-it skills (commit, open-pr) for coding agents.

  --opencode    Link skills into ~/.config/opencode/skills (global)
  --cursor      Render Cursor rules into ./.cursor/rules (project)
  --copilot     Render Copilot instructions into ./.github/instructions (project)
  --all         Install for all three agents
  --remove      Remove the files this script creates
  --force       Overwrite files that are not managed by this script
  --help        Show this message

With no agent flag the script auto-detects: opencode when its config dir
exists, Cursor when ./.cursor exists, Copilot when ./.github exists.
EOF
}

skill_body() {
  awk 'BEGIN{f=0;b=0} /^---[[:space:]]*$/ {f++; next} f>=2 { if($0=="" && !b) next; b=1; print }' "$1"
}

is_managed() {
  [[ -f "$1" ]] && grep -q "$MARKER" "$1" 2>/dev/null
}

install_opencode() {
  mkdir -p "$OPENCODE_DIR"
  local name target src
  for name in "${SKILLS[@]}"; do
    target="$OPENCODE_DIR/$name"
    src="$SKILLS_DIR/$name"
    if [[ -e "$target" && ! -L "$target" ]]; then
      [[ "$FORCE" -eq 1 ]] || { echo "skip opencode/$name: $target is not a symlink (--force to overwrite)" >&2; continue; }
      rm -rf "$target"
    elif [[ -L "$target" ]]; then
      rm "$target"
    fi
    ln -s "$src" "$target"
    echo "linked   opencode/$name  ->  $src"
  done
}

remove_opencode() {
  local name target
  for name in "${SKILLS[@]}"; do
    target="$OPENCODE_DIR/$name"
    if [[ -L "$target" ]]; then
      rm "$target"
      echo "removed  opencode/$name"
    fi
  done
}

install_cursor() {
  mkdir -p "$CURSOR_DIR"
  local name out
  for name in "${SKILLS[@]}"; do
    out="$CURSOR_DIR/$name.mdc"
    if [[ -e "$out" ]] && ! is_managed "$out"; then
      [[ "$FORCE" -eq 1 ]] || { echo "skip cursor/$name: $out is not managed (--force to overwrite)" >&2; continue; }
    fi
    {
      printf '%s\n' '---' "description: ${CURSOR_DESC[$name]}" 'alwaysApply: false' '---' ''
      printf '<!-- %s; rendered from skills/%s/SKILL.md. -->\n\n' "$MARKER" "$name"
      skill_body "$SKILLS_DIR/$name/SKILL.md"
    } > "$out"
    echo "rendered cursor/$name  ->  $out"
  done
}

remove_cursor() {
  local name out
  for name in "${SKILLS[@]}"; do
    out="$CURSOR_DIR/$name.mdc"
    if is_managed "$out"; then
      rm "$out"
      echo "removed  cursor/$name"
    fi
  done
}

install_copilot() {
  mkdir -p "$COPILOT_DIR"
  local name out
  for name in "${SKILLS[@]}"; do
    out="$COPILOT_DIR/$name.instructions.md"
    if [[ -e "$out" ]] && ! is_managed "$out"; then
      [[ "$FORCE" -eq 1 ]] || { echo "skip copilot/$name: $out is not managed (--force to overwrite)" >&2; continue; }
    fi
    {
      printf '%s\n' '---' 'applyTo: "**"' '---' ''
      printf '<!-- %s; rendered from skills/%s/SKILL.md. -->\n\n' "$MARKER" "$name"
      skill_body "$SKILLS_DIR/$name/SKILL.md"
    } > "$out"
    echo "rendered copilot/$name ->  $out"
  done
}

remove_copilot() {
  local name out
  for name in "${SKILLS[@]}"; do
    out="$COPILOT_DIR/$name.instructions.md"
    if is_managed "$out"; then
      rm "$out"
      echo "removed  copilot/$name"
    fi
  done
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --opencode) DO_OPENCODE=1; shift ;;
    --cursor)   DO_CURSOR=1; shift ;;
    --copilot)  DO_COPILOT=1; shift ;;
    --all)      DO_OPENCODE=1; DO_CURSOR=1; DO_COPILOT=1; shift ;;
    --remove)   REMOVE=1; shift ;;
    --force)    FORCE=1; shift ;;
    --help|-h)  usage; exit 0 ;;
    *)          echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ $DO_OPENCODE -eq 0 && $DO_CURSOR -eq 0 && $DO_COPILOT -eq 0 && $REMOVE -eq 0 ]]; then
  [[ -d "${XDG_CONFIG_HOME:-$HOME/.config}/opencode" ]] && DO_OPENCODE=1
  [[ -d ".cursor" ]] && DO_CURSOR=1
  [[ -d ".github" ]] && DO_COPILOT=1
fi

if [[ $REMOVE -eq 1 && $DO_OPENCODE -eq 0 && $DO_CURSOR -eq 0 && $DO_COPILOT -eq 0 ]]; then
  DO_OPENCODE=1; DO_CURSOR=1; DO_COPILOT=1
fi

[[ -d "$SKILLS_DIR" ]] || { echo "skills/ not found at $SKILLS_DIR - run from the repo root" >&2; exit 1; }

if [[ $REMOVE -eq 1 ]]; then
  [[ $DO_OPENCODE -eq 1 ]] && remove_opencode
  [[ $DO_CURSOR   -eq 1 ]] && remove_cursor
  [[ $DO_COPILOT  -eq 1 ]] && remove_copilot
  echo "done."
  exit 0
fi

if [[ $DO_OPENCODE -eq 0 && $DO_CURSOR -eq 0 && $DO_COPILOT -eq 0 ]]; then
  echo "no agents detected; pass --opencode, --cursor, --copilot, or --all" >&2
  usage >&2
  exit 1
fi

[[ $DO_OPENCODE -eq 1 ]] && install_opencode
[[ $DO_CURSOR   -eq 1 ]] && install_cursor
[[ $DO_COPILOT  -eq 1 ]] && install_copilot
echo "done."
