# ship-it

[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/khrichtchatyi/ship-it/blob/master/LICENSES/MIT.txt)

Agent skills that commit your work and open pull requests. You write the code. They handle git. Works with [Claude Code], [opencode], [Cursor], and [GitHub Copilot].

## Skills

**[`commit`](skills/commit/SKILL.md)** — stages the files you name, writes one [Conventional Commits] message, stops. No push.

**[`open-pr`](skills/open-pr/SKILL.md)** — pushes the branch, opens a pull request, pings the owner when CODEOWNERS points to one person.

The `skills/` directory is the single source of truth; every agent integration below reads from it.

## Install

Clone the repo once, then install for the agents you use.

```sh
git clone https://github.com/khrichtchatyi/ship-it
cd ship-it
```

### opencode (global, all your projects)

```sh
./install.sh --opencode
```

Symlinks both skills into `~/.config/opencode/skills/`, so they are available in every project.

### Cursor (per project)

Cursor rules are project-scoped. From each project where you want the skills:

```sh
/path/to/ship-it/install.sh --cursor
```

Renders `.cursor/rules/commit.mdc` and `.cursor/rules/open-pr.mdc` in the current project.

### GitHub Copilot (per project)

```sh
/path/to/ship-it/install.sh --copilot
```

Renders `.github/instructions/commit.instructions.md` and `.github/instructions/open-pr.instructions.md`.

### Claude Code

```text
/plugin marketplace add khrichtchatyi/plugins
/plugin install ship-it@khrichtchatyi
```

### Everything at once

```sh
./install.sh --all      # opencode global + Cursor + Copilot in the current project
./install.sh            # auto-detect: opencode, plus Cursor/Copilot when .cursor/.github exist
```

Run `./install.sh --help` for every flag. The Cursor and Copilot files are generated from `skills/*/SKILL.md` on each run; edit the `SKILL.md` and re-run to refresh them.

## Use

Ask your agent in plain English. The matching skill activates.

```text
commit these changes
open a PR for this branch
```

## Update and remove

Re-run `./install.sh` after pulling the repo to refresh the generated files. To uninstall:

```sh
./install.sh --remove   # removes every file this script created
```

For Claude Code:

```text
/plugin marketplace update khrichtchatyi
/plugin uninstall ship-it@khrichtchatyi
```

## Notes

Symlinks under `.opencode/` and `CLAUDE.md` are committed as symlinks; on Windows, enable Developer Mode (or set `core.symlinks=true`) so they do not materialize as text files.

One source of truth, every agent. No git in the way.

[Claude Code]: https://code.claude.com/docs/en/skills
[opencode]: https://opencode.ai/docs/skills
[Cursor]: https://docs.cursor.com/context/rules
[GitHub Copilot]: https://docs.github.com/en/copilot/customizing-copilot/adding-repository-custom-instructions-for-github-copilot
[Conventional Commits]: https://www.conventionalcommits.org/
