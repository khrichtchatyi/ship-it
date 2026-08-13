#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2026 Maxim Khrichtchatyi
# SPDX-License-Identifier: MIT
#
# test_install.sh — dependency-free tests for install.sh.
# Each test follows the Arrange-Act-Assert pattern.
# Runs entirely in a throwaway sandbox; never touches real agent config.

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL="$REPO/install.sh"
SANDBOX="$(mktemp -d)"
PROJ="$SANDBOX/proj"
XDG="$SANDBOX/xdg"
TESTS=0
FAILS=0

trap 'rm -rf "$SANDBOX"' EXIT

ok() { TESTS=$((TESTS + 1)); printf '  ok   %s\n' "$1"; }
ko() { TESTS=$((TESTS + 1)); FAILS=$((FAILS + 1)); printf '  FAIL %s\n' "$1" >&2; }

assert_exists()   { if [[ -e "$1" ]]; then ok "exists  $1"; else ko "exists  $1"; fi; }
assert_symlink()  { if [[ -L "$1" ]]; then ok "symlink $1"; else ko "symlink $1"; fi; }
assert_link()     { local got; got="$(readlink -f "$1")"; if [[ "$got" == "$2" ]]; then ok "link $1 -> $2"; else ko "link $1 -> $2 (got $got)"; fi; }
assert_contains() { if grep -qF "$2" "$1" 2>/dev/null; then ok "contains '$2' in $1"; else ko "contains '$2' in $1"; fi; }
assert_absent()   { if [[ ! -e "$1" && ! -L "$1" ]]; then ok "absent  $1"; else ko "absent  $1"; fi; }
assert_rc()       { if [[ "$1" -eq "$2" ]]; then ok "exit $2  $3"; else ko "exit $2  $3 (got $1)"; fi; }

reset() {
  rm -rf "$PROJ" "$XDG"
  mkdir -p "$PROJ/.cursor" "$PROJ/.github"
}

run_install() {
  ( cd "$PROJ" && XDG_CONFIG_HOME="$XDG" "$INSTALL" "$@" >"$SANDBOX/log" 2>&1 )
}

test_opencode_links_skills_globally() {
  echo "== opencode: links both skills globally =="
  # Arrange
  reset
  # Act
  run_install --opencode
  local rc=$?
  # Assert
  assert_rc "$rc" 0 "--opencode"
  assert_symlink "$XDG/opencode/skills/commit"
  assert_link    "$XDG/opencode/skills/commit" "$REPO/skills/commit"
  assert_symlink "$XDG/opencode/skills/open-pr"
  assert_link    "$XDG/opencode/skills/open-pr" "$REPO/skills/open-pr"
}

test_cursor_renders_managed_rules() {
  echo "== cursor: renders managed .mdc with body =="
  # Arrange
  reset
  # Act
  run_install --cursor
  local rc=$?
  # Assert
  assert_rc "$rc" 0 "--cursor"
  assert_contains "$PROJ/.cursor/rules/commit.mdc" "alwaysApply: false"
  assert_contains "$PROJ/.cursor/rules/commit.mdc" "managed by ship-it install.sh"
  assert_contains "$PROJ/.cursor/rules/commit.mdc" "Conventional Commits"
  assert_contains "$PROJ/.cursor/rules/open-pr.mdc" "pull request"
}

test_copilot_renders_managed_instructions() {
  echo "== copilot: renders managed instructions with body =="
  # Arrange
  reset
  # Act
  run_install --copilot
  local rc=$?
  # Assert
  assert_rc "$rc" 0 "--copilot"
  assert_contains "$PROJ/.github/instructions/commit.instructions.md" 'applyTo: "**"'
  assert_contains "$PROJ/.github/instructions/commit.instructions.md" "managed by ship-it install.sh"
  assert_contains "$PROJ/.github/instructions/open-pr.instructions.md" "pull request"
}

test_all_installs_every_agent() {
  echo "== --all: installs every agent =="
  # Arrange
  reset
  # Act
  run_install --all
  local rc=$?
  # Assert
  assert_rc "$rc" 0 "--all"
  assert_symlink "$XDG/opencode/skills/commit"
  assert_exists  "$PROJ/.cursor/rules/commit.mdc"
  assert_exists  "$PROJ/.github/instructions/commit.instructions.md"
}

test_install_is_idempotent() {
  echo "== idempotent re-run =="
  # Arrange
  reset
  # Act
  run_install --all
  run_install --all
  local rc=$?
  # Assert
  assert_rc "$rc" 0 "--all (second run)"
  assert_symlink "$XDG/opencode/skills/commit"
  assert_contains "$PROJ/.cursor/rules/commit.mdc" "Conventional Commits"
}

test_unmanaged_file_survives_install_and_remove() {
  echo "== unmanaged file survives install and remove =="
  # Arrange
  reset
  mkdir -p "$PROJ/.cursor/rules"
  printf '%s\n' '---' 'alwaysApply: false' '---' 'my own rule' '' > "$PROJ/.cursor/rules/manual.mdc"
  # Act
  run_install --cursor
  local rc_install=$?
  run_install --remove
  local rc_remove=$?
  # Assert
  assert_rc "$rc_install" 0 "--cursor with manual file present"
  assert_contains "$PROJ/.cursor/rules/manual.mdc" "my own rule"
  assert_rc "$rc_remove" 0 "--remove"
  assert_exists "$PROJ/.cursor/rules/manual.mdc"
  assert_absent  "$PROJ/.cursor/rules/commit.mdc"
}

test_remove_cleans_only_managed_artifacts() {
  echo "== --remove cleans only managed artifacts =="
  # Arrange
  reset
  run_install --all
  printf '%s\n' '---' 'alwaysApply: false' '---' 'keep me' '' > "$PROJ/.cursor/rules/keep.mdc"
  # Act
  run_install --remove
  local rc=$?
  # Assert
  assert_rc "$rc" 0 "--remove"
  assert_absent "$XDG/opencode/skills/commit"
  assert_absent "$PROJ/.cursor/rules/commit.mdc"
  assert_absent "$PROJ/.github/instructions/commit.instructions.md"
  assert_exists "$PROJ/.cursor/rules/keep.mdc"
}

test_auto_detect_cursor_and_copilot() {
  echo "== auto-detect: cursor + copilot when .cursor/.github present =="
  # Arrange
  reset
  # Act
  run_install
  local rc=$?
  # Assert
  assert_rc "$rc" 0 "auto-detect"
  assert_exists "$PROJ/.cursor/rules/commit.mdc"
  assert_exists "$PROJ/.github/instructions/commit.instructions.md"
  assert_absent  "$XDG/opencode/skills/commit"
}

main() {
  test_opencode_links_skills_globally
  test_cursor_renders_managed_rules
  test_copilot_renders_managed_instructions
  test_all_installs_every_agent
  test_install_is_idempotent
  test_unmanaged_file_survives_install_and_remove
  test_remove_cleans_only_managed_artifacts
  test_auto_detect_cursor_and_copilot
  echo ""
  echo "$((TESTS - FAILS))/$TESTS assertions passed"
  if [[ "$FAILS" -gt 0 ]]; then
    echo "$FAILS assertion(s) failed" >&2
    exit 1
  fi
  echo "all tests passed"
}

main
