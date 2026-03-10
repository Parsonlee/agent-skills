---
name: git-worktree-creator
description: 在项目父目录创建规范命名的 git worktree（格式：{项目名}_{分支名}），支持指定基础分支。当用户需要创建 worktree、并行开发、多分支同时工作、或需要独立工作目录来做 feature/hotfix/debug 时使用此 skill。注意：此 skill 与内置 EnterWorktree 不同——它在项目外部创建 worktree 并使用规范命名，适合团队协作场景。
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

- 分支名只能包含字母、数字、连字符、下划线、点号和斜杠
- 必须在 git 仓库中执行
- 父目录必须有写入权限

## 错误处理指引

脚本会自动检测常见错误并给出明确提示。遇到以下场景时，按提示引导用户：

| 错误场景 | 脚本输出 | 建议回应 |
|---------|---------|---------|
| 目标目录已存在 | `Directory already exists: ...` | 告知用户该 worktree 可能已创建，建议 `git worktree list` 确认 |
| 分支已被其他 worktree 检出 | `Branch 'xxx' is already checked out in worktree: ...` | 建议用户换一个分支名，或先移除旧 worktree |
| 不在 git 仓库中 | `Not in a git repository` | 引导用户先 `cd` 到项目目录 |
| 分支名格式无效 | `Invalid branch name...` | 提示合法字符范围 |

