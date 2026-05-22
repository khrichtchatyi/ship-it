---
name: commit-changes-to-git
description: |
  Use this skill to commit changes that already sit in
  the working tree of the current Git repository, under
  the direct supervision of the user — inspect what is
  modified, stage only what the user named (or all
  modifications when the user said so), compose one
  Conventional Commits message that names the change
  honestly, and stop. One repository per run, one
  commit per run — then stop.
---

Operate on the Git repository in the current working
  directory; refuse to run when the directory is not a
  Git working tree or when no commits exist yet on the
  current branch and the user did not ask for an
  initial commit.

Trust the user — the changes in the working tree were
  made earlier on purpose and this skill only records
  them; do not edit source files, do not reformat code,
  do not run the linter, do not run the test suite, and
  do not start a build to "verify" the change before
  committing.

Before composing the message, verify the commit identity
  with `git config user.email` and `git config user.name`,
  and refuse to run when either is empty so the commit is
  not attributed to `root@hostname` or a stale default.

Inspect `commit.gpgsign` and `gpg.format` with
  `git config --get`, and warn the user once when signing
  is required but no signing key is configured locally,
  so the commit does not fail mid-run on a hook the user
  did not anticipate.

Run `git status` and `git diff` (and `git diff --staged`
  when something is already staged) before composing
  the message, so the subject and the body describe
  what is actually on disk and not what was discussed
  earlier in the conversation.

Show the user a one-line summary of the files about to
  be committed and the proposed commit subject, then
  stop and wait for the user's reply before invoking
  `git commit`, so the user can redirect the scope or
  the wording before the commit lands.

Stage files explicitly with one `git add <path> [<path> ...]`
  call that lists every path the user named, and never
  run `git add -A`, `git add .`, or `git commit -a` unless
  the user said in plain words to stage everything; those
  forms sweep in unrelated edits and leak secrets.

Refuse to stage files whose names match a known secret
  pattern — `.env`, `.env.*`, `*.pem`, `*.key`, `id_rsa`,
  `id_ed25519`, `credentials.json`, `*.tfstate`,
  `*.kdbx`, or any path inside `.ssh/` — and warn the
  user instead of committing them silently.

Refuse to stage a file whose diff introduces a line that
  looks like a credential — an `AKIA`/`ASIA` AWS key, a
  `gh[pousr]_` GitHub token, a `sk-` API key, a `-----BEGIN
  ... PRIVATE KEY-----` block, or a base64-looking string
  longer than 40 characters assigned to a name containing
  `secret`, `token`, `password`, or `key` — and ask the
  user to confirm before continuing.

Format the subject line as `<type>(<scope>): <description>`
  per the Conventional Commits 1.0.0 spec at
  https://www.conventionalcommits.org/en/v1.0.0/, where
  the scope in parentheses is optional and the
  colon-space separator is mandatory.

Pick the type from the standard set: `feat` for a new
  feature, `fix` for a bug fix, `docs`, `style`,
  `refactor`, `perf`, `test`, `build`, `ci`, `chore`,
  or `revert`; do not invent new types.

Include a scope in parentheses when every staged path sits
  under a single package, module, or top-level directory
  (`fix(parser): ...`, `feat(api): ...`), and omit the
  scope when the change spans unrelated areas; never
  invent a scope that does not match the directory or
  module name.

Append `!` after the type or scope (`feat!:` or
  `feat(api)!:`) and add a `BREAKING CHANGE:` footer
  when the commit introduces an incompatible change,
  so tooling can detect the break from the subject
  alone.

Write the description in the imperative mood,
  lowercase, with no trailing period, aiming for 50
  characters and never exceeding 72 (`fix(parser):
  handle empty input`, not `Fixed the parser.`).

Leave one blank line between the subject and the body,
  and another blank line between the body and any
  footer; the parser relies on these blank lines to
  split the message.

Keep the body to a few short sentences that explain
  the motivation and the visible effect, wrap lines at
  72 columns, and omit the body entirely when the
  subject already says everything — a one-line commit
  is a good commit.

Derive the message from the diff and from what the
  user said in the conversation, not from the branch
  name or from a guess about intent; when the diff and
  the conversation disagree, ask the user which one is
  right before committing.

Do not pad the message with restated diffs, file
  lists, or obvious summaries (`updated foo.js to add
  a function`); the diff already shows that — the
  message must add the reason.

Do not bundle unrelated changes into one commit; when
  the working tree mixes two unrelated edits, ask the
  user whether to split them into two commits or to
  stage only one of them now.

Add a `Closes #<number>` or `Fixes #<number>` footer
  when the user named that exact issue or asked for
  the auto-close behaviour, and add a `Refs: #<number>`
  footer when the user named an issue for context but
  did not ask to close it; never put the issue number
  in the subject line, because Conventional Commits
  parsers and changelog tools do not read it there.

Never add a `Co-authored-by:` trailer naming Claude,
  Claude Code, Anthropic, or any other coding agent;
  the commit is authored by the user running the agent
  and attribution to a tool is misleading.

Never add promotional trailers, signatures, emoji, or
  `Generated with ...` lines to the message; the
  commit log is a technical record, not a credit
  screen.

Never override the author or the committer on the
  command line with `--author`, `-c user.name=`,
  `-c user.email=`, `GIT_AUTHOR_NAME`, or
  `GIT_COMMITTER_EMAIL`; rely on the defaults
  configured in the repository or in the user's global
  Git config so the commit is attributed correctly.

Do not pass `--no-verify`, `--no-gpg-sign`, or any
  flag that bypasses hooks or signing unless the user
  has explicitly asked for it; a failing hook means
  the commit is not ready and the right move is to fix
  the underlying problem and stage the fix as part of
  this commit or as a follow-up.

Do not amend the previous commit, do not rebase, and
  do not force-push as part of this skill; when the
  previous commit was wrong, create a new commit on
  top and let the user decide whether to clean up the
  history.

Do not push the new commit to any remote; pushing and
  opening a pull request are handled by the sibling
  skill `submit-a-pull-request` and the user may want
  to inspect, amend, or discard the commit before it
  leaves the machine.

Pass the message to `git` with `git commit -F -` and a
  HEREDOC on stdin, so blank lines, backticks, and
  quotes survive the shell intact and no `-m` quoting
  trap can corrupt the body or the footers.

After `git commit` succeeds, run `git log -1 --stat`
  and show the output to the user so the subject,
  body, footers, and file set are visible in one
  place; when anything looks wrong, propose a new
  commit on top rather than amending the one just
  created.

Stop after the single commit lands: do not open a
  pull request, do not push, do not start the next
  change — direct the user to `submit-a-pull-request`
  when the branch is ready to ship, and re-run this
  skill from the top when more changes are ready.

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
