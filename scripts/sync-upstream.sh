#!/usr/bin/env bash
# ==============================================================================
# sync-upstream.sh
# Synchronize personal fork's 'turkish-supported' branch with upstream/main
# ==============================================================================

set -euo pipefail

UPSTREAM_URL="https://github.com/storytold/pdfcraft.git"
TARGET_BRANCH="turkish-supported"

echo "[1/4] Ensuring 'upstream' remote is configured..."
if ! git remote | grep -q "^upstream$"; then
    git remote add upstream "$UPSTREAM_URL"
    echo "Added upstream: $UPSTREAM_URL"
else
    git remote set-url upstream "$UPSTREAM_URL"
fi

echo "[2/4] Fetching latest changes from upstream/main..."
git fetch upstream main

echo "[3/4] Checking out $TARGET_BRANCH..."
git checkout "$TARGET_BRANCH"

echo "[4/4] Merging upstream/main into $TARGET_BRANCH..."
if git merge upstream/main -m "chore(sync): merge upstream/main into $TARGET_BRANCH"; then
    echo "✅ Successfully synced $TARGET_BRANCH with upstream/main."
    echo "To push to your fork, run: git push origin $TARGET_BRANCH"
else
    echo "⚠️ Merge conflicts encountered. Please resolve conflicts while preserving"
    echo "   Turkish character glyph metrics and standard_encoding mappings."
    exit 1
fi
