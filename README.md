# Claude Skills Collection

个人开源的 Claude Code Agent Skills 集合，提供实用的开发工具和自动化脚本。

## 简介

这是一个为 [Claude Code](https://claude.com/claude-code) 构建的 Skills 仓库，包含了一系列提高开发效率的自动化工具。每个 Skill 都经过精心设计，旨在简化常见的开发工作流程。

## 包含的 Skills

### 1. Git Worktree Creator

自动创建 git worktree，实现并行开发和独立工作环境。

**功能特性：**
- 自动检测主分支（main 或 master）
- 在父目录创建 worktree，命名格式：`{项目名}_{分支名}`
- 自动创建新分支或检出已存在的分支
- 提供清晰的操作提示和后续步骤

**使用方法：**
```bash
请帮我创建一个 feature-login 的 worktree
```

**详细文档：** [worktree-skill/SKILL.md](worktree-skill/SKILL.md)

## 如何使用

### 方式一：直接使用单个 Skill

每个 Skill 都是独立的目录，你可以单独克隆或下载需要的 Skill：

1. 进入你的项目目录：
```bash
cd your-project
```

2. 复制需要的 Skill 到你的项目：
```bash
# 创建 skills 目录（如果不存在）
mkdir -p .claude/skills

# 复制 worktree-skill
cp -r /path/to/claude-skills/worktree-skill .claude/skills/
```

### 方式二：克隆整个仓库

如果你想使用所有 Skills：

```bash
git clone https://github.com/yourusername/claude-skills.git
cd claude-skills
```

然后将需要的 Skills 复制到你的项目中。

### 在 Claude Code 中使用

在 Claude Code 中，直接向 Claude 描述你想要做的事情，Claude 会自动识别并使用相应的 Skill：

```
创建一个 hotfix 的 worktree
```

## 项目结构

```
claude-skills/
├── worktree-skill/              # Git Worktree Creator Skill
│   ├── worktree.sh             # Skill 实现脚本
│   └── SKILL.md                # Skill 详细文档
├── README.md                    # 项目说明文档
└── .gitignore
```

每个 Skill 都是一个独立的目录，可以单独使用。

## 贡献指南

欢迎贡献新的 Skills 或改进现有的 Skills！

### 添加新 Skill

1. Fork 本仓库
2. 在根目录下创建新的 Skill 目录（如 `my-skill/`）
3. 添加 Skill 实现和文档
4. 提交 Pull Request

### Skill 开发规范

[官方文档](https://code.claude.com/docs/en/skills)

每个 Skill 应包含：
- `SKILL.md` - Skill 说明文档（包含 frontmatter）
- 实现脚本（如 `.sh`、`.py` 等）
- 清晰的错误处理
- 用户友好的输出信息
