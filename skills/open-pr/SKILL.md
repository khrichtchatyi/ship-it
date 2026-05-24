---
name: open-pr
description: |
  Use this skill to submit the commits on the current
  branch as one pull request against a GitHub
  repository. Push the branch, open the PR with an
  imperative title and a body that names what changed
  and why, and post a follow-up ping only when
  CODEOWNERS resolves to one person. One branch per
  run, one pull request per run.
---

Resolve the target GitHub repository from the user's
  prompt, or from the upstream of the current branch
  (`git config branch.<branch>.remote`, falling back
  to `origin`) when the user names none.

Refuse to run when neither resolves.

Verify the GitHub CLI is authenticated with
  `gh auth status` before any other `gh` call.

Refuse to run when it is not — otherwise the skill
  cascades authentication errors.

Refuse to run when the current branch is the
  repository's default branch (`main` or `master`).

Refuse to run when the branch has no commits ahead of
  the default — this skill ships work that already
  exists, and never invents commits.

Refuse to run when the working tree has uncommitted
  changes — staged, unstaged, or untracked.

Point the user to the sibling skill `commit` to record
  the pending edits first; a pull request must reflect
  a clean, committed state.

Do not modify source files, amend existing commits,
  rebase, or squash the branch.

This skill writes only the `git push`, the new pull
  request, and (when ping criteria are met) one
  follow-up comment on GitHub.

Do not run the build, the test suite, the linter, or
  any static analysis tool — this skill ships the
  branch as it stands and trusts the author to have
  verified it.

Identify the default branch with
  `gh repo view <owner>/<repo> --json defaultBranchRef --jq .defaultBranchRef.name`,
  and use that name as the base of the pull request.

Do not hard-code `main` or `master`.

Confirm the current branch is up to date with the
  remote default branch using the resolved remote name
  (`git fetch <remote> && git log --oneline <remote>/<default>..HEAD`).

That keeps the diff in the pull request to the
  author's intended change, not an accidental merge
  backlog.

Detect a fork workflow by comparing the resolved
  remote's URL (`git remote get-url <remote>`) with
  the target slug.

When they differ — for example, the user pushes from a
  personal fork to the upstream organization — pass
  `--head <fork-owner>:<branch>` to every `gh` call
  that takes a head ref.

GitHub will not match a cross-repository branch on its
  short name alone.

List any open pull request that already targets the
  same head with
  `gh pr list --repo <owner>/<repo> --state open --head <head> --json number,title,author`.

Discard the run when the list is non-empty — a second
  pull request from the same branch is a duplicate.

Push the current branch to the resolved remote with
  `git push -u <remote> <branch>` before opening the
  pull request.

`gh pr create` refuses to open a pull request from a
  branch the remote does not yet know about.

Open the pull request with
  `gh pr create --repo <owner>/<repo> --base <default> --head <head> --title ... --body ...`.

Use a short, declarative title in the imperative mood
  — for example `Drop trailing newline guard in
  parser` — not a vague phrase like `Fixes` or
  `Update`.

Derive the title and the body from the commit messages
  on the branch (for example
  `git log --reverse --pretty=format:%s%n%n%b <remote>/<default>..HEAD`)
  and from the diff.

Do not derive from the branch name alone — the branch
  name rarely tells the reviewer what the change does.

Check for a pull request template at
  `.github/PULL_REQUEST_TEMPLATE.md`,
  `.github/pull_request_template.md`, or
  `docs/PULL_REQUEST_TEMPLATE.md`.

When one exists, fill its sections with the derived
  content and pass the result via `--body-file` so the
  template structure survives intact.

Fall back to a free-form body only when no template is
  present.

Size the body to the change — one short paragraph for
  a trivial fix, up to three paragraphs naming what
  changed, why it is needed, and any follow-up the
  reviewer should know.

Do not expand a one-line fix into a three-paragraph
  essay.

Talk like a human in the pull request body and in any
  follow-up comment.

Use your own words, write in plain conversational
  phrasing, and drop the stock AI cadence, boilerplate
  openings, and buzzword strings.

Do not add AI markers to the pull request or the
  comment: no mention of Claude, ChatGPT, an LLM, or
  any model name; no `Generated with ...` footer; no
  `Co-Authored-By` AI trailer; no robot emoji; no
  disclosure that an assistant wrote the text.

Reference the related issue in the body with a closing
  keyword (for example `Closes #123`) only when the
  user named that issue or when a commit message on
  the branch already names it.

Never invent an issue number to look thorough.

Do not request reviewers, assign the pull request,
  attach labels, or set a milestone.

Leave those triage decisions to the maintainer and to
  any automation the repository runs (such as
  CODEOWNERS-driven review routing).

Do not mark the pull request as a draft unless the
  user asked for a draft.

A ready pull request signals the work is up for
  review; a draft signals it is not.

Resolve the follow-up ping target from
  `.github/CODEOWNERS`, `docs/CODEOWNERS`, or
  `CODEOWNERS` at the repo root — use
  `gh api repos/<owner>/<repo>/contents/<path>` when
  the file is not on disk locally.

Match the changed paths against the CODEOWNERS rules.

Select an owner only when exactly one account is the
  match — treat a team handle as unambiguous and use
  the team slug as the ping target.

Fall back to the slug owner only when the slug owner
  is a user account (not an organization) and no
  CODEOWNERS file exists.

Skip the ping when the owner is an organization with
  no CODEOWNERS resolution — guessing a maintainer
  from commit history @-mentions strangers.

Skip the follow-up comment when the resolved ping
  target matches the authenticated GitHub account —
  compare `gh api user --jq .login` with the target.

@-mentioning yourself adds nothing to the pull
  request.

Post the follow-up comment only when the user asked
  for one, or when the rules above produced exactly
  one human ping target and the user did not opt out.

Otherwise, leave the pull request to whatever
  review-routing automation the repository runs.

Post the comment with
  `gh pr comment <number> --repo <owner>/<repo> --body ...`.

Write one or two sentences of plain prose that
  @-mention the resolved target, ask them to take a
  look, and offer to clarify if anything is unclear.

No headings, no bullet lists, no emoji, no
  AI-disclosure boilerplate.

Do not ping more than one account, @-mention the whole
  organization, or request a deadline or priority
  label.

Stop after the pull request is created — or after the
  single follow-up comment when one was posted.

Do not open a second pull request, push another
  branch, or start a follow-up change.

Re-run this skill from the top for the next branch.

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
