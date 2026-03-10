#!/bin/bash

# Git Worktree Creator
# 无论当前在任意分支，都能从主分支成功创建 worktree

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印错误信息并退出
error() {
    echo -e "${RED}❌ Error: $1${NC}" >&2
    exit 1
}

# 打印成功信息
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 打印信息
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# 检查是否在 git 仓库中
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        error "Not in a git repository"
    fi
}

# 获取 git 根目录
get_git_root() {
    git rev-parse --show-toplevel
}

# 获取项目名称
get_project_name() {
    basename "$(get_git_root)"
}

# 检测并确保主分支可用
detect_and_ensure_main_branch() {
    local main_branch=""

    # 1. 检查本地是否有 main 分支
    if git show-ref --verify --quiet refs/heads/main; then
        main_branch="main"
        info "Using local branch: main" >&2
        echo "$main_branch"
        return 0
    fi

    # 2. 检查本地是否有 master 分支
    if git show-ref --verify --quiet refs/heads/master; then
        main_branch="master"
        info "Using local branch: master" >&2
        echo "$main_branch"
        return 0
    fi

    # 3. 检查远程是否有 main 分支
    if git ls-remote --exit-code --heads origin main &> /dev/null; then
        main_branch="main"
        info "Found remote branch: origin/main" >&2

        # 尝试 fetch 远程分支
        info "Fetching origin/main..." >&2
        git fetch origin main:refs/remotes/origin/main 2>/dev/null || true

        echo "$main_branch"
        return 0
    fi

    # 4. 检查远程是否有 master 分支
    if git ls-remote --exit-code --heads origin master &> /dev/null; then
        main_branch="master"
        info "Found remote branch: origin/master" >&2

        # 尝试 fetch 远程分支
        info "Fetching origin/master..." >&2
        git fetch origin master:refs/remotes/origin/master 2>/dev/null || true

        echo "$main_branch"
        return 0
    fi

    # 5. 如果都没有，默认使用 main
    info "No main/master branch found, defaulting to 'main'" >&2
    echo "main"
}

# 获取基础分支的完整引用
get_base_branch_ref() {
    local branch_name="$1"

    # 检查本地分支是否存在
    if git show-ref --verify --quiet "refs/heads/${branch_name}"; then
        echo "${branch_name}"
        return 0
    fi

    # 检查远程分支是否存在
    if git show-ref --verify --quiet "refs/remotes/origin/${branch_name}"; then
        echo "origin/${branch_name}"
        return 0
    fi

    # 如果都不存在，返回分支名（让 git worktree 报错）
    echo "${branch_name}"
}

# 显示使用说明
usage() {
    cat << EOF
Usage: $0 [OPTIONS] BRANCH_NAME

Create a git worktree in parent directory with format: {project}_{branch}

Arguments:
    BRANCH_NAME         Name of the branch to create or checkout

Options:
    -b, --base BRANCH   Base branch to create from (default: auto-detect main/master)
    -h, --help          Show this help message

Examples:
    $0 feature-login
    $0 -b develop feature-api-v2
    $0 --base main bugfix-auth

EOF
    exit 0
}

# 主函数
main() {
    local branch_name=""
    local base_branch=""

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                ;;
            -b|--base)
                base_branch="$2"
                shift 2
                ;;
            -*)
                error "Unknown option: $1"
                ;;
            *)
                if [[ -z "$branch_name" ]]; then
                    branch_name="$1"
                else
                    error "Multiple branch names provided"
                fi
                shift
                ;;
        esac
    done

    # 检查分支名是否提供
    if [[ -z "$branch_name" ]]; then
        error "Branch name is required. Use -h for help."
    fi

    # 验证分支名格式
    if [[ ! "$branch_name" =~ ^[a-zA-Z0-9._/-]+$ ]]; then
        error "Invalid branch name. Use only letters, numbers, hyphens, underscores, dots, and slashes."
    fi

    # 检查是否在 git 仓库中
    check_git_repo

    # 获取项目信息
    local git_root
    git_root=$(get_git_root)
    local project_name
    project_name=$(get_project_name)
    local parent_dir
    parent_dir=$(dirname "$git_root")

    # 确定基础分支
    if [[ -z "$base_branch" ]]; then
        base_branch=$(detect_and_ensure_main_branch)
    fi

    # 获取基础分支的完整引用
    local base_branch_ref
    base_branch_ref=$(get_base_branch_ref "$base_branch")

    # 生成 worktree 路径
    local worktree_name="${project_name}_${branch_name}"
    local worktree_path="${parent_dir}/${worktree_name}"

    # 显示操作信息
    echo ""
    info "Creating worktree:"
    echo "   Project: $project_name"
    echo "   Base branch: $base_branch_ref"
    echo "   New branch: $branch_name"
    echo "   Location: $worktree_path"
    echo ""

    # 检查 worktree 路径是否已存在
    if [[ -d "$worktree_path" ]]; then
        error "Directory already exists: $worktree_path"
    fi

    # 检查分支是否已存在
    local branch_exists=false
    if git show-ref --verify --quiet "refs/heads/${branch_name}"; then
        branch_exists=true
    fi

    # 检查分支是否已被其他 worktree 检出
    if [[ "$branch_exists" == true ]]; then
        local checked_out_path
        checked_out_path=$(git worktree list --porcelain | awk -v branch="$branch_name" '
            /^worktree / { wt=$2 }
            /^branch refs\/heads\// {
                b = substr($2, 12)
                if (b == branch) print wt
            }
        ')
        if [[ -n "$checked_out_path" ]]; then
            error "Branch '$branch_name' is already checked out in worktree: $checked_out_path\nPlease use a different branch name, or remove that worktree first:\n   git worktree remove \"$checked_out_path\""
        fi
    fi

    # 创建 worktree
    if [[ "$branch_exists" == true ]]; then
        info "Branch '$branch_name' already exists, checking it out..."
        git worktree add "$worktree_path" "$branch_name"
    else
        info "Creating new branch '$branch_name' from '$base_branch_ref'..."
        # 使用完整的分支引用，确保从正确的分支创建
        git worktree add -b "$branch_name" "$worktree_path" "$base_branch_ref"
    fi

    # 显示成功信息
    echo ""
    success "Worktree created successfully!"
    echo ""
    echo -e "${YELLOW}To start working:${NC}"
    echo "   cd \"$worktree_path\""
    echo ""
    echo -e "${YELLOW}To list all worktrees:${NC}"
    echo "   git worktree list"
    echo ""
    echo -e "${YELLOW}To remove this worktree later:${NC}"
    echo "   git worktree remove \"$worktree_path\""
    echo ""
}

# 运行主函数
main "$@"
