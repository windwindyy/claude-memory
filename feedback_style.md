---
name: feedback-style
description: "User's preferences for response style and behavior"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 5d9ed1a4-6f2e-4a36-9100-5ba000b1f171
---

用户希望 Claude 自动保存记忆，不需要每次都显式说明"记住这个"。对于值得长期保留的信息（角色、偏好、项目上下文），Claude 应主动写入 memory 文件。

用户使用中文交流，回复使用中文。

**How to apply:** 每次对话中，如果观察到新的用户偏好、反馈、项目背景信息，主动判断是否值得写入 memory，无需等用户提醒。无关紧要的临时信息不写。
