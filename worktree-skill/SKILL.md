---
name: git-worktree-creator
description: Creates git worktrees for parallel development with automatic naming and branch management. Use when you need a separate working environment for features, hotfixes, or debugging—especially when juggling multiple branches without stashing changes.
allowed-tools:
  - Bash
  - Read
---

# Git Worktree Creator

通过执行 `worktree.sh` 脚本自动创建 git worktree，支持并行开发。目录位于项目根目录上级，命名格式：`{项目名}_{分支名}`

## 核心功能

- ✅ 自动检测主分支（main 或 master）
- ✅ 在父目录创建 worktree
- ✅ 智能命名：`{项目名}_{分支名}`
- ✅ 自动创建新分支或检出已存在的分支
- ✅ 完整的错误处理和清晰的反馈

## 快速开始

### 基本用法

创建新 worktree 和分支：

```bash
请帮我创建一个 feature-login 的 worktree
```

### 指定基础分支

从特定分支创建 worktree：

```bash
从 develop 分支创建一个 feature-api-v2 的 worktree
```

### 脚本执行参考

```bash
# 基本用法 - 从 main/master 创建 worktree
bash worktree.sh feature-name

# 指定基础分支
bash worktree.sh -b develop feature-name
```

## 执行步骤

1. **解析用户意图**：提取分支名（必需）和基础分支（可选）
2. **验证前置条件**：确认在 git 仓库中，分支名格式有效
3. **执行脚本**：在项目根目录运行 `bash worktree.sh [OPTIONS] BRANCH_NAME`
4. **报告结果**：成功时显示 worktree 位置和切换命令，失败时显示错误原因

### 脚本参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `-b, --base BRANCH` | 指定基础分支 | 自动检测 main/master |
| `BRANCH_NAME` | 新建分支的名称 | - |

## 使用示例

| 用户请求 | 分支名 | 基础分支 | 执行命令 |
|---------|-------|--------|--------|
| 创建 feature-login worktree | feature-login | (自动) | `bash worktree.sh feature-login` |
| 为 feature-user-profile 创建 worktree | feature-user-profile | (自动) | `bash worktree.sh feature-user-profile` |
| 从 develop 创建 feature-api-v2 worktree | feature-api-v2 | develop | `bash worktree.sh -b develop feature-api-v2` |

## 后续操作

创建完成后，用户可以：

```bash
# 切换到 worktree
cd ../my-app_feature-name

# 查看所有 worktrees
git worktree list

# 删除 worktree（完成工作后）
git worktree remove ../my-app_feature-name
```

## 注意事项

- 分支名只能包含字母、数字、连字符、下划线和斜杠
- 必须在 git 仓库中执行
- 父目录必须有写入权限

