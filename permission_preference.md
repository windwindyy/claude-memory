---
name: permission-preference
description: 用户希望减少不必要的权限提示
metadata: 
  node_type: memory
  type: feedback
  originSessionId: be7475a2-ceb8-4361-b57a-c4af7d7fabe3
---

不涉及系统文件删改的操作都允许，无需每次申请许可。包括：读取文件、查看状态、搜索内容、创建非系统目录/文件、安装工具包等常规开发操作。

**Why:** 用户认为频繁的权限提示影响工作效率，只有真正危险的操作（删除系统文件、修改注册表、系统配置等）才需要确认。

**How to apply:** 对于只读操作和常规开发写入操作，直接执行无需确认。对于 `rm -rf /`、修改 Windows 注册表、系统配置等操作仍需确认。
