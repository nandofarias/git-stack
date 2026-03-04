# Changelog

All notable changes to git-stack are documented here.

## [1.1.0] - 2026-03-03

### Added
- **Divergence indicator**: red ⚡ on branches whose parent is no longer an ancestor, signaling that `git stack sync` is needed.
- **Base branch in output**: `git stack` now shows the base branch (develop/main/master) at the top of the stack.
- **Full stack visibility**: the stack is visible from any branch, not just branches below HEAD. Being on the middle branch shows both parents below and children above.
- **fzf picker for `git stack next`**: when multiple child branches exist (e.g., from the base branch), opens an interactive picker instead of choosing arbitrarily.
- **`git stack prev` to base**: at the bottom of the stack, switches to the base branch instead of erroring.
- **Rewritten branch detection**: uses `git cherry` (patch-id matching) to find child branches even after a parent was rebased and amended. Handles the double-orphan case where both SHAs and fork points changed.
- **`--version` flag**: `git stack --version` or `git stack -v`.

### Fixed
- **Duplicate commits in sync** (3+ branch stacks): after rebasing branch A, `merge-base(new-A, old-B)` returned the base branch instead of old-A's tip, causing A's commits to be replayed into B. Now tracks pre-rebase SHAs as fork points. Reported by Colby Pines.
- **Sync crash under `set -e`**: `((rebased++))` returns exit code 1 when `rebased=0` (bash treats 0 as falsy). Replaced with `$((rebased + 1))`.
- **`git stack next` missed outdated branches**: branches that forked before the base moved forward were not found. Now checks merge-base instead of strict ancestry.
- **`git stack prev` performance**: was running `git for-each-ref` on every commit between HEAD and merge-base. Now builds the branch map once with O(1) lookups.

### Changed
- **`amend`, `reword`, `edit` cascade the full stack**: these commands now discover all descendant branches before modifying the current branch, then rebase through the entire stack. Previously they only rebased direct children.
- **`sync` and `push` discover the full stack**: finds branches above HEAD (descendants) in addition to ancestors, so you can sync/push from any branch in the stack.

## [1.0.0] - 2026-03-01

### Added
- Initial release: `git stack`, `sync`, `push`, `reorder`, `next`, `prev`, `amend`, `reword`, `edit`.
- Auto-detects base branch: develop > main > master. Override with `git config stack.base`.
- Interactive mode (`git stack -i`) via fzf.
- `--force-with-lease` for all pushes.
- Backup refs on reorder for safety.

[1.1.0]: https://github.com/nandofarias/git-stack/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/nandofarias/git-stack/releases/tag/v1.0.0
