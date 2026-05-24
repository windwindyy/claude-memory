---
name: feedback-read-memories
description: 每次新对话开始时，Claude 必须主动读取并回顾所有记忆文件
metadata:
  type: feedback
  originSessionId: 50fe77a9-7712-4d46-9e97-1ff0bb501b6f
---

每次打开新对话时，Claude 必须先执行 `git pull` 拉取最新记忆，然后读取 MEMORY.md 索引及所有关联的记忆文件，全面了解用户背景和项目上下文，而不是被动等待用户提及。

**Why:** 用户在多台电脑间工作，依赖记忆同步来保持上下文连续性。如果 Claude 不主动加载记忆，之前积累的偏好和项目信息就会丢失。git pull 确保拿到另一台电脑推送的最新记忆。

**How to apply:** 新对话的第一个动作应该是进入 memory 目录执行 `git pull`，然后读取 MEMORY.md，再根据索引读取各记忆文件的内容。不要假设用户会手动提醒。
