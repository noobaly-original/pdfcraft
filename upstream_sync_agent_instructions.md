# AGENT INSTRUCTION: Upstream Release Sync & Custom Branch Maintenance

## Mission & Purpose
This repository maintains custom local modifications while tracking releases from an upstream source repository. When tasked with checking, syncing, or updating against upstream releases, execute the protocol below strictly to preserve local patches without corrupting commit history or dropping customizations.

---

## Repository Architecture

- **`upstream` Remote**: Points to original authoritative repository (`git remote get-url upstream`).
- **`origin` Remote**: Points to your fork / self-hosted clone (`git remote get-url origin`).
- **`main` / `upstream-tracking`**: Untouched upstream mirror. Never commit custom work here directly.
- **Active Working Branch**: Your custom integration branch (e.g., `my-custom-build` or current active branch).

---

## Automated Execution Protocol

When instructed to "update to latest upstream release" or "sync upstream":

### Step 1: Pre-Flight Verification
Run these commands and verify the state before performing any writes:
```bash
# Verify working tree is clean
git status --porcelain

# Verify remotes exist
git remote -v
```
*Rule: If uncommitted changes exist, stop and stash or alert the user. Never overwrite uncommitted work.*

### Step 2: Fetch Upstream Metadata & Tags
```bash
git fetch upstream --tags --prune
```

### Step 3: Identify Target Upstream Release
Determine the target release point:
1. List recent release tags:
   ```bash
   git tag --sort=-v:refname | head -n 10
   ```
2. Identify the target tag (or upstream default branch if targeting rolling releases, e.g., `upstream/main`).
3. Record the target tag identifier (e.g., `vX.Y.Z`).

### Step 4: Sync Strategy Selection
Choose the strategy based on repository requirements:

#### Default Strategy: Linear Rebase (Cleanest Patch Stack)
Replays custom patches directly on top of the target release:
```bash
git checkout <custom-branch>
git rebase <target-tag>
```

#### Alternative Strategy: Non-Destructive Merge (Multi-User / Preserved Hashes)
Use this if rebase is explicitly disabled or if collaborating across multiple contributors:
```bash
git checkout <custom-branch>
git merge <target-tag> -m "chore(sync): merge upstream release <target-tag>"
```

---

## Conflict Resolution Rules

If a merge or rebase conflict occurs:

1. **Locate Conflicted Files**:
   ```bash
   git status --short
   ```
2. **Inspect the Diffs**:
   - Upstream base: `<<<<<<< HEAD` (or upstream during rebase)
   - Local customizations: `>>>>>>> <commit-hash>`
3. **Preservation Priority**:
   - Retain custom local business logic, configuration overrides, and bespoke features.
   - Adopt upstream structural refactors, security patches, and dependency updates.
4. **Resolution Verification**:
   - Run existing test suites and linters (e.g., `npm test`, `pytest`, `cargo test`, `go test ./...`) after resolving conflicts.
5. **Resume**:
   - If rebasing:
     ```bash
     git add <resolved-files>
     git rebase --continue
     ```
   - If merging:
     ```bash
     git add <resolved-files>
     git commit -m "chore(sync): resolve conflicts with upstream <target-tag>"
     ```
6. **Bailout**: If conflict resolution threatens system integrity or cannot be verified via tests, abort cleanly and report status:
   ```bash
   git rebase --abort # or git merge --abort
   ```

---

## Post-Sync Verification & Push Protocol

1. **Run Quality Assurance**:
   ```bash
   # Ensure project builds cleanly
   # Execute relevant test suite
   ```
2. **Push to Remote**:
   - For rebased branches:
     ```bash
     git push origin <custom-branch> --force-with-lease
     ```
   - For merged branches:
     ```bash
     git push origin <custom-branch>
     ```
3. **Emit Summary**:
   Provide the user with:
   - Base release tag applied.
   - List of custom commits retained.
   - Files with resolved conflicts (if any).
   - Test execution results.