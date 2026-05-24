---
name: memory-git-sync
description: Claude 记忆通过 Git 私有仓库在两台电脑间自动同步，使用 SessionStart/Stop hooks
metadata: 
  node_type: memory
  type: reference
  originSessionId: 5caab628-e8cf-4430-9d27-e4cdab776369
---

# Memory Git 自动同步

Memory 目录：`C:\Users\Qianjunyang\.claude\projects\C--Users-Qianjunyang\memory\`

## 同步机制

通过 Claude Code hooks 实现自动同步（`~/.claude/settings.json`）：

- **SessionStart hook**（async）：每次启动会话时自动 `git pull`，拉取另一台电脑的最新记忆
- **Stop hook**（同步）：每次会话结束时自动 `git add -A && git commit && git push`，推送本地的记忆更改

同步脚本：`sync-memory.sh`（支持 `push`、`pull`、`sync` 三个子命令）

## Git 仓库

需要推送到一个私有 GitHub 仓库（待创建）。

**When setting up on another computer:**
1. Find the memory directory: `ls ~/.claude/projects/*/memory/`
2. Clone the private repo into that directory
3. Copy the sync script and hook config
