#!/bin/bash
# Claude Memory Sync Script
# Usage: ./sync-memory.sh [push|pull]

MEMORY_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$MEMORY_DIR"

case "${1:-sync}" in
  push)
    echo "==> Pulling remote changes first..."
    git pull origin main --rebase 2>/dev/null || echo "    (no remote or pull failed, continuing)"
    echo "==> Staging and committing local changes..."
    git add -A
    if git diff --cached --quiet; then
      echo "    Nothing to commit."
    else
      git commit -m "Auto-sync: $(date '+%Y-%m-%d %H:%M:%S')" 2>/dev/null || echo "    (commit skipped)"
    fi
    echo "==> Pushing to remote..."
    git push origin main 2>/dev/null || echo "    Push failed — check remote config"
    ;;
  pull)
    echo "==> Pulling remote changes..."
    git pull origin main --rebase 2>/dev/null || echo "    Pull failed — check remote config"
    ;;
  sync)
    echo "==> Pulling remote changes..."
    git pull origin main --rebase 2>/dev/null || echo "    (no remote or pull failed, continuing)"
    echo "==> Staging and committing local changes..."
    git add -A
    if git diff --cached --quiet; then
      echo "    Nothing to commit."
    else
      git commit -m "Auto-sync: $(date '+%Y-%m-%d %H:%M:%S')" 2>/dev/null || echo "    (commit skipped)"
    fi
    echo "==> Pushing to remote..."
    git push origin main 2>/dev/null || echo "    Push failed — check remote config"
    ;;
  *)
    echo "Usage: ./sync-memory.sh [push|pull|sync]"
    echo "  sync  — pull, commit local changes, push (default)"
    echo "  push  — pull, commit, push"
    echo "  pull  — pull only"
    ;;
esac
