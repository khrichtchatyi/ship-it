# ship-it

[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/khrichtchatyi/ship-it/blob/master/LICENSES/MIT.txt)

A Claude Code plugin that commits your work and opens pull requests. You write the code. It handles git.

## Skills

**[`commit`](skills/commit/SKILL.md)** — stages the files you name, writes one [Conventional Commits] message, stops. No push.

**[`open-pr`](skills/open-pr/SKILL.md)** — pushes the branch, opens a pull request, pings the owner when CODEOWNERS points to one person.

## Install

Open a [Claude Code] session and run:

```text
/plugin marketplace add khrichtchatyi/plugins
/plugin install ship-it@khrichtchatyi
```

## Use

Ask Claude in plain English. The matching skill activates.

```text
commit these changes
open a PR for this branch
```

## Update and remove

```text
/plugin marketplace update khrichtchatyi
/plugin uninstall ship-it@khrichtchatyi
```

Two commands to install. One sentence to commit. No git in the way.

[Claude Code]: https://code.claude.com/docs/en/skills
[Conventional Commits]: https://www.conventionalcommits.org/
