# 🥞 git-stack

**Lightweight stacked branch workflow for Git.**

Manage stacked branches without external services. No metadata files, no accounts — just shell scripts and Git.

## Why?

Stacked branches (aka stacked PRs) let you build features incrementally: branch B depends on branch A, branch C depends on B, and so on. The problem? **Amending a commit mid-stack breaks every branch above it.**

`git-stack` solves this by automatically rebasing all descendant branches whenever you amend, reword, or edit a commit. It also gives you tools to visualize, navigate, sync, and push the entire stack in one command.

## Installation

```bash
git clone https://github.com/nandofarias/git-stack.git
cd git-stack
./install.sh
```

Or manually add `bin/` to your `PATH`:

```bash
export PATH="$HOME/path/to/git-stack/bin:$PATH"
```

**Dependencies:** `git`, `bash`. Optional: `fzf` (for interactive branch selection).

## Commands

### `git stack`

Show the current branch stack between the base branch and `HEAD`.

```
Branch stack:
    feature/auth ✓
    feature/api ↑
  ▸ feature/tests ↑
```

- **✓** — matches remote
- **↑** — local changes not pushed
- **▸** — current branch

### `git stack -i`

Interactive branch checkout via `fzf`.

### `git stack sync`

Rebase the entire stack in cascade. Use after adding commits to a branch that isn't the top.

### `git stack push`

Force-push (`--force-with-lease`) all branches that differ from remote.

### `git stack reorder`

Interactively reorder branches in `$EDITOR`. Creates backup refs for safety. Pass `--dry-run` to preview.

### `git stack next` / `git stack prev`

Navigate up (child) or down (parent) in the stack.

### `git stack amend`

Stage all changes, amend current commit (no-edit), and **auto-rebase all child branches**.

### `git stack reword`

Change commit message (opens editor) and **auto-rebase all child branches**.

### `git stack edit [<commit>]`

Interactive rebase with automatic child branch rebasing.

- `git stack edit HEAD~2` — mark a specific commit for editing
- `git stack edit` — full interactive rebase from merge-base

## Typical Workflows

### Daily work

```bash
git stack              # see the stack
git stack next         # move to child branch
# ... make changes ...
git stack amend        # amend + auto-rebase children
git stack push         # push everything
```

### Added a commit mid-stack

```bash
git checkout feature/api
git add -A && git commit -m "fix"
git checkout feature/tests   # back to top
git stack sync
git stack push
```

### Reorder branches

```bash
git stack reorder
git stack push
```

### Edit an old commit

```bash
git stack edit HEAD~3
# make changes
git add -A && git rebase --continue
# children rebased automatically
```

## How It Works

- **Discovery:** Finds `merge-base(base, HEAD)`, walks `git log --ancestry-path`, maps commit SHAs to local branches.
- **Child rebase:** After modifying a commit, finds all descendant branches, sorts by distance, rebases each `--onto` the new SHA.
- **Sync:** Walks stack bottom→top, checks ancestry. If branch N isn't on top of N-1, rebases with `--onto`.

## Configuration

### Base Branch

Auto-detects: `develop` → `main` → `master`. Override per-repo or globally:

```bash
git config stack.base main
git config --global stack.base develop
```

## Limitations

- Branches discovered by commit ancestry — unreachable branches won't appear
- No metadata files — order inferred from topology
- Conflicts stop the operation; resolve manually and re-run

## License

MIT © 2025 Fernando Farias
