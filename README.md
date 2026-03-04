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

Show the full branch stack, regardless of which branch you're on.

```
Branch stack:
    develop (base)
    feature/auth ✓
    feature/api ↑
  ▸ feature/tests ↑
```

| Symbol | Color | Meaning |
|--------|-------|---------|
| **✓** | Green | In sync with remote |
| **↑** | Yellow | Local changes not pushed |
| **⚡** | Red | Diverged from parent, needs `git stack sync` |
| **▸** | — | Current branch |

The base branch (develop/main/master) is always shown at the top.

### `git stack -i`

Interactive branch checkout via `fzf`.

### `git stack sync`

Rebase the entire stack in cascade, bottom to top.

Uses pre-rebase SHAs as fork points to avoid duplicating commits when parent branches have been rewritten. Discovers the full stack (including branches above HEAD) so you can run it from any branch.

After syncing, diverged branches (⚡) go back to normal.

### `git stack push`

Force-push (`--force-with-lease`) all branches in the stack that differ from remote. Discovers the full stack, so you can push from any branch.

### `git stack reorder`

Interactively reorder branches in `$EDITOR`. Creates backup refs for safety. Pass `--dry-run` to preview.

### `git stack next`

Move up the stack (switch to child branch).

If the current branch has multiple children (multiple stacks), opens `fzf` to pick which one to enter. This is especially useful from the base branch where multiple stacks may exist.

### `git stack prev`

Move down the stack (switch to parent branch). At the bottom of the stack, switches to the base branch.

### `git stack amend`

Stage all changes, amend current commit (no-edit), and **auto-rebase the entire stack above**. Discovers all descendant branches before the amend, then cascades the rebase through each one.

### `git stack reword`

Change commit message (opens editor) and **auto-rebase the entire stack above**. Same cascade behavior as amend.

### `git stack edit [<commit>]`

Interactive rebase with automatic stack syncing after completion.

- `git stack edit HEAD~2` — mark a specific commit for editing
- `git stack edit` — full interactive rebase from merge-base

## Typical Workflows

### Daily work

```bash
git stack              # see the stack
git stack next         # move to child branch
# ... make changes ...
git stack amend        # amend + auto-rebase entire stack
git stack push         # push everything
```

### Rewrote a commit without git-stack?

If you used plain `git commit --amend` or `git rebase` outside of git-stack, the stack will show ⚡ on diverged branches:

```
Branch stack:
    develop (base)
  ▸ feature/auth ↑
    feature/api ⚡     ← diverged, needs sync
    feature/tests ⚡
```

Just run sync to fix it:

```bash
git stack sync
git stack push
```

### Added a commit mid-stack

```bash
git checkout feature/api
git add -A && git commit -m "fix"
git stack sync         # rebases everything above
git stack push
```

### Reorder branches

```bash
git stack reorder
git stack push
```

### Navigate from base branch

```bash
git checkout develop
git stack next         # fzf picker if multiple stacks exist
```

## How It Works

- **Discovery:** Walks `git log --ancestry-path` from HEAD to `merge-base(base, HEAD)` to find branches below. In full mode, walks up from the top branch to find descendants, using `git cherry` (patch-id matching) to detect children even after parent rewrites.
- **Sync cascade:** Walks stack bottom-to-top. Saves each branch's pre-rebase SHA. Uses it as the fork point for the next branch, avoiding the merge-base bug where rewritten commits get duplicated.
- **Amend/reword/edit:** Discovers all descendant branches *before* modifying the current branch, then cascades rebase through each one in distance order.
- **Divergence detection:** Checks if each branch's parent in the stack is still an ancestor. If not, shows ⚡ to signal that sync is needed.

## Configuration

### Base Branch

Auto-detects: `develop` > `main` > `master`. Override per-repo or globally:

```bash
git config stack.base main
git config --global stack.base develop
```

## Limitations

- Branches discovered by commit ancestry and patch-id matching. Completely unrelated branches won't appear in a stack.
- No metadata files. Stack order is inferred from topology.
- Conflicts stop the operation; resolve manually and re-run.

## License

MIT © 2025 Fernando Farias
