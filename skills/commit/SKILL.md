---
name: commit
description: |
  Use this skill to commit changes already sitting in
  the working tree of the current Git repository.
  Inspect the tree, stage only what the user named,
  write one Conventional Commits message, stop.
  One repository per run, one commit per run.
---

Operate on the Git repository in the current working
  directory.

Refuse to run when the directory is not a Git working
  tree.

Refuse to run when the branch has no commits yet and
  the user did not ask for an initial commit.

Refuse to run when the current branch is `main`,
  `master`, `develop`, `trunk`, or matches the remote's
  default branch from
  `git symbolic-ref --short refs/remotes/origin/HEAD` —
  commits belong on feature branches, not protected
  defaults.

Override the default-branch refusal only when the user
  said in plain words to commit directly to that
  branch.

Trust the user — the changes in the working tree exist
  on purpose, and this skill only records them.

Do not edit source files.

Do not reformat code, run the linter, run the test
  suite, or start a build to "verify" the change before
  committing.

Verify the commit identity with `git config user.email`
  and `git config user.name` before composing the
  message.

Refuse to run when either is empty — otherwise Git
  attributes the commit to `root@hostname` or a stale
  default.

Inspect `commit.gpgsign` and `gpg.format` with
  `git config --get` before running `git commit`.

Warn the user once when signing is required but no
  signing key is configured locally, so the commit
  does not fail mid-run on a hook.

Run `git status` and `git diff` (and
  `git diff --staged` when something is already staged)
  before composing the message.

Describe what is on disk, not what the conversation
  discussed earlier.

Show the user a one-line summary of the files about to
  be committed and the proposed subject.

Stop and wait for the user's reply before invoking
  `git commit`, so the user can redirect the scope or
  the wording before the commit lands.

Stage files with one `git add <path> [<path> ...]` call
  listing every path the user named.

Never run `git add -A`, `git add .`, or `git commit -a`
  unless the user said in plain words to stage
  everything — those forms sweep in unrelated edits and
  leak secrets.

Refuse to stage files whose names match a known secret
  pattern: `.env`, `.env.*`, `*.pem`, `*.key`, `id_rsa`,
  `id_ed25519`, `credentials.json`, `*.tfstate`,
  `*.kdbx`, or any path inside `.ssh/`.

Refuse to stage a file whose diff introduces a
  credential-looking line — an `AKIA`/`ASIA` AWS key, a
  `gh[pousr]_` GitHub token, an `sk-` API key, a
  `-----BEGIN ... PRIVATE KEY-----` block, or a 40+
  character base64 string assigned to a `secret`,
  `token`, `password`, or `key` variable — and ask the
  user to confirm before continuing.

Format the subject as `<type>(<scope>): <description>`
  per [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/).

The scope is optional; the colon-space separator is
  mandatory.

Pick the type from the standard set: `feat`, `fix`,
  `docs`, `style`, `refactor`, `perf`, `test`, `build`,
  `ci`, `chore`, `revert`.

Do not invent new types.

Include a scope when every staged path sits under one
  package, module, or top-level directory
  (`fix(parser): ...`, `feat(api): ...`).

Omit the scope when the change spans unrelated areas.

Never invent a scope that does not match a directory
  or module name.

Append `!` after the type or scope (`feat!:` or
  `feat(api)!:`) when the commit breaks compatibility,
  and add a `BREAKING CHANGE:` footer so tooling can
  detect the break from the subject alone.

Write the description in the imperative mood,
  lowercase, with no trailing period.

Aim for 50 characters and never exceed 72
  (`fix(parser): handle empty input`, not
  `Fixed the parser.`).

Leave one blank line between the subject and the body,
  and another between the body and any footer — the
  parser splits the message on those blank lines.

Keep the body to a few short sentences naming the
  motivation and the visible effect.

Wrap body lines at 72 columns.

Omit the body when the subject already says everything
  — one-line commits ship.

Derive the message from the diff and the user's words,
  not from the branch name or a guess at intent.

When the diff and the conversation disagree, ask the
  user which is right before committing.

Do not pad the message with restated diffs, file lists,
  or obvious summaries like `updated foo.js to add a
  function` — the diff shows that, so the message must
  add the reason.

Do not bundle unrelated changes into one commit.

When the working tree mixes two unrelated edits, ask
  the user whether to split them or stage only one
  now.

Add a `Closes #<number>` or `Fixes #<number>` footer
  when the user named that issue or asked for the
  auto-close.

Add a `Refs: #<number>` footer when the user named an
  issue for context only.

Never put the issue number in the subject — Conventional
  Commits parsers and changelog tools do not read it
  there.

Never add a `Co-authored-by:` trailer naming Claude,
  Claude Code, Anthropic, or any coding agent — the
  user authors the commit and crediting a tool
  misleads readers.

Never add promotional trailers, signatures, emoji, or
  `Generated with ...` lines — the commit log records
  technical history, not credits.

Never override the author or committer with `--author`,
  `-c user.name=`, `-c user.email=`, `GIT_AUTHOR_NAME`,
  or `GIT_COMMITTER_EMAIL`; rely on the repository or
  global Git config so the commit is attributed
  correctly.

Do not pass `--no-verify`, `--no-gpg-sign`, or any flag
  that bypasses hooks or signing unless the user asks
  — a failing hook means the commit is not ready, so
  fix the cause and stage the fix as part of this
  commit or a follow-up.

Do not amend the previous commit, rebase, or
  force-push from this skill.

When the previous commit was wrong, write a new commit
  on top and let the user decide whether to clean up
  the history.

Do not push the new commit to any remote.

Pushing and opening a pull request belong to the
  sibling skill `open-pr`, and the user may want to
  inspect, amend, or discard the commit before it
  leaves the machine.

Pass the message to `git commit -F -` via a HEREDOC on
  stdin so blank lines, backticks, and quotes survive
  the shell intact — `-m` quoting traps corrupt the
  body and footers.

After `git commit` succeeds, run `git log -1 --stat`
  and show the output to the user so the subject,
  body, footers, and file set appear in one place.

When anything looks wrong, propose a new commit on top
  instead of amending the one just created.

Stop after the commit lands.

Do not open a pull request, push, or start the next
  change.

Point the user to `open-pr` when the branch is ready
  to ship, and re-run this skill from the top when
  more changes are ready.

## Examples

```text
feat(api): add pagination to list endpoint

fix(parser): handle empty input

docs: clarify install steps in README

refactor(auth)!: drop legacy session cookie

BREAKING CHANGE: clients must send the bearer token
on every request; the `sid` cookie is no longer read.

Closes #482
```

```text
fix(worker): retry on transient redis timeout

The pool dropped connections under load and the job
was lost instead of retried, so user-facing imports
silently stalled.

Refs: #1207
```
