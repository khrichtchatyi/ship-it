---
name: submit-a-pull-request
description: |
  Use this skill to submit the commits sitting on the
  current local branch as a single new pull request
  against a specific GitHub repository — push the
  branch, open the PR with a clear title and a short
  body that explains what changed and why, and post
  one follow-up comment only when a single owner is
  unambiguous. One branch per run, one pull request
  per run — then stop.
---

Operate on the GitHub repository named in the user's
  prompt as the target, or on the upstream of the
  current branch (`git config branch.<branch>.remote`,
  falling back to `origin`) when the user names no
  explicit target; refuse to run when neither is
  available.

Verify the GitHub CLI is authenticated with
  `gh auth status` before any other `gh` call, and
  refuse to run when it is not, so the skill does not
  produce a cascade of confusing authentication
  failures.

Refuse to run when the current branch is the
  repository's default branch (`main` or `master`) or
  when it has no commits ahead of the default branch —
  this skill submits work that already exists, and
  never invents commits.

Refuse to run when the working tree has uncommitted
  changes — staged, unstaged, or untracked — and point
  the user to the sibling skill `commit-changes-to-git`
  to record the pending edits first, because a pull
  request must reflect a clean, committed state and
  not a half-finished edit on disk.

Do not modify a single source file, do not amend
  existing commits, do not rebase, and do not squash
  the branch; the only writes this skill performs are
  the `git push`, the new pull request, and (when the
  ping criteria are met) one follow-up comment on
  GitHub.

Do not run the build, do not execute the test suite,
  do not start any linter, and do not invoke any
  static analysis tool — this skill ships the branch
  as it stands and trusts the author to have verified
  it.

Identify the default branch with
  `gh repo view <owner>/<repo> --json defaultBranchRef --jq .defaultBranchRef.name`
  and use that name as the base of the pull request,
  not a hard-coded `main` or `master`.

Confirm the current branch is up to date with the
  remote default branch (for example with
  `git fetch <remote> && git log --oneline <remote>/<default>..HEAD`)
  using the resolved remote name from the first rule,
  so the diff in the pull request reflects the author's
  intended change and not an accidental merge backlog.

Detect a fork workflow by comparing the resolved
  remote's URL (via `git remote get-url <remote>`)
  with the target slug, and when they differ — for
  example when the user pushes from a personal fork to
  the upstream organization — pass
  `--head <fork-owner>:<branch>` to every `gh` call
  that takes a head ref, because GitHub will not match
  a cross-repository branch on its short name alone.

List any open pull request that already targets the
  same head with
  `gh pr list --repo <owner>/<repo> --state open --head <head> --json number,title,author`
  and discard the run when the list is non-empty — a
  second pull request from the same branch is a
  duplicate.

Push the current branch to the resolved remote with
  `git push -u <remote> <branch>` before opening the
  pull request, because `gh pr create` refuses to open
  a pull request from a branch the remote does not yet
  know about.

Open the pull request with
  `gh pr create --repo <owner>/<repo> --base <default> --head <head> --title ... --body ...`
  using a short, declarative title that names the
  change in the imperative mood — for example
  `Drop trailing newline guard in parser` — and not a
  vague phrase like `Fixes` or `Update`.

Derive the title and the body from the commit
  messages on the branch (for example via
  `git log --reverse --pretty=format:%s%n%n%b <remote>/<default>..HEAD`)
  and from the diff itself, not from the branch name
  alone, because the branch name rarely tells the
  reviewer what the change does.

Check for a pull request template at
  `.github/PULL_REQUEST_TEMPLATE.md`,
  `.github/pull_request_template.md`, or
  `docs/PULL_REQUEST_TEMPLATE.md`, and when one
  exists, fill its sections with the derived content
  and pass the result via `--body-file` so the
  template structure survives intact; only fall back
  to a free-form body when no template is present.

Write the body as plain prose sized to the change —
  one short paragraph for a trivial fix, up to three
  paragraphs naming what changed, why it is needed,
  and any follow-up the reviewer should know — and
  stop there; do not expand a one-line fix into a
  three-paragraph essay.

Talk like a human in the pull request body and in any
  follow-up comment: use your own words, write in
  plain conversational phrasing, and drop the stock
  AI cadence, boilerplate openings, and buzzword
  strings.

Do not add AI markers to the pull request or the
  comment: no mention of Claude, ChatGPT, an LLM, or
  any model name; no `Generated with ...` footer, no
  `Co-Authored-By` AI trailer, no robot emoji, no
  disclosure that the text was written by an
  assistant.

Reference the related issue in the body with a
  closing keyword (for example `Closes #123`) only
  when the user named that issue explicitly or when
  a commit message on the branch already names it —
  never invent an issue number to look thorough.

Do not request reviewers, do not assign the pull
  request to anyone, do not attach labels, and do not
  set a milestone; leave those triage decisions to
  the maintainer and to any automation the repository
  already runs (such as CODEOWNERS-driven review
  routing).

Do not mark the pull request as a draft unless the
  user asked for a draft, because a ready pull
  request signals the work is up for review and a
  draft signals it is not.

Resolve the follow-up ping target by reading
  `.github/CODEOWNERS`, `docs/CODEOWNERS`, or
  `CODEOWNERS` at the repo root (via
  `gh api repos/<owner>/<repo>/contents/<path>` when
  the file is not on disk locally), matching the
  changed paths against the CODEOWNERS rules, and
  selecting an owner only when exactly one account is
  the unambiguous match; treat a team handle as
  unambiguous and use the team slug as the ping
  target.

Fall back to the slug owner as the ping target only
  when the slug owner is a user account (not an
  organization) and no CODEOWNERS file exists, and
  skip the ping entirely when the owner is an
  organization with no CODEOWNERS resolution —
  guessing a maintainer from commit history
  @-mentions strangers and is worse than no ping at
  all.

Skip the follow-up comment when the resolved ping
  target matches the authenticated GitHub account —
  compare `gh api user --jq .login` with the target —
  because @-mentioning yourself adds nothing to the
  pull request.

Post the follow-up comment only when the user asked
  for one, or when the rules above produced exactly
  one human ping target and the user did not opt out;
  otherwise, leave the pull request to whatever
  review-routing automation the repository already
  has in place.

When a follow-up comment is posted, use
  `gh pr comment <number> --repo <owner>/<repo> --body ...`
  with one or two sentences of plain prose that
  @-mention the resolved target, ask them to take a
  look when they have a moment, and offer to clarify
  if anything in the change is unclear — no headings,
  no bullet lists, no emoji, no AI-disclosure
  boilerplate.

Do not ping more than one account in the follow-up
  comment, do not @-mention the whole organization,
  and do not request a deadline or a priority label.

Stop after the pull request is created — or after the
  single follow-up comment when one was posted: do not
  open a second pull request, do not push another
  branch, and do not start a follow-up change —
  re-run this skill from the top for the next branch.

## Examples

```text
Title:  Drop trailing newline guard in parser

Body:
The parser rejected inputs whose last line carried no
trailing newline, which broke imports produced by
exporters that omit it.

The guard is removed and the trailing-newline case is
covered by a new fixture in tests/parser/eof.txt.

Closes #482
```

```text
Title:  Bump retry budget for the redis worker

Body:
Transient redis timeouts under load were dropping
imports instead of retrying, so jobs silently stalled.

The retry budget is raised from 3 to 8 with a
capped-exponential backoff, matching the queue's
existing dead-letter window.
```
