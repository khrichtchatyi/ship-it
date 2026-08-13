# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog], and this project adheres to [Semantic Versioning].

## [0.2.0] - 2026-08-13

### Added

- Multi-agent support: the skills now work with [opencode], [Cursor], and [GitHub Copilot], alongside Claude Code.
- `install.sh` to install the skills per agent — opencode is linked globally into `~/.config/opencode/skills`; Cursor and Copilot are rendered into the current project — with `--opencode`, `--cursor`, `--copilot`, `--all`, `--remove`, `--force`, and auto-detect flags.
- `tests/test_install.sh`, a dependency-free test suite for `install.sh`, wired into CI via `.github/workflows/tests.yml`.
- `.opencode/skills/` project-level symlinks so opencode discovers the skills when the repo is cloned.
- `.cursor/rules/` and `.github/instructions/` wrappers for Cursor and Copilot.
- `AGENTS.md` as the agent-neutral instruction file; `CLAUDE.md` is now a symlink to it.
- CI coverage: `shellcheck` and `tests` workflows; `.typos.toml` whitelisting `opencode`; `**/*.mdc` added to `REUSE.toml`.
- Windows symlink note in the README.

### Changed

- Generalized the AI-attribution denials in both skills to name Claude, Claude Code, ChatGPT, GPT, Gemini, Anthropic, OpenAI, and any coding agent or LLM.
- Rewrote the README as agent-neutral with per-agent install instructions.
- Bumped version to `0.2.0`.

## [0.1.0] - 2026-05-23

- Initial release: the `commit` and `open-pr` skills as a Claude Code plugin.

[Keep a Changelog]: https://keepachangelog.com/en/1.1.0/
[Semantic Versioning]: https://semver.org/
[opencode]: https://opencode.ai/
[Cursor]: https://cursor.com/
[GitHub Copilot]: https://github.com/features/copilot
[0.2.0]: https://github.com/khrichtchatyi/ship-it/releases/tag/v0.2.0
[0.1.0]: https://github.com/khrichtchatyi/ship-it/releases/tag/v0.1.0
