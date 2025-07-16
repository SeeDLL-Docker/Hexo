#!/bin/bash
set -euo pipefail

# ========================
# 多语言系统初始化
# ========================
function init_i18n() {
    declare -gA I18N=(
        # 基础提示
        ["start"]="zh-cn:开始执行脚本 | en:Starting script"
        ["error_dir"]="zh-cn:错误：无法访问工作目录 | en:Error: Cannot access working directory"
        ["skip"]="zh-cn:跳过 | en:Skipped"

        # 阶段提示
        ["phase_env"]="zh-cn:=== 环境初始化 === | en:=== Environment Setup ==="
        ["phase_requirements"]="zh-cn:=== 依赖安装 === | en:=== Requirements Installation ==="
        ["phase_ssh"]="zh-cn:=== SSH 配置 === | en:=== SSH Setup ==="
        ["phase_hexo"]="zh-cn:=== Hexo 操作 === | en:=== Hexo Operations ==="

        # 环境初始化
        ["init_empty"]="zh-cn:→ 空白目录，执行完整初始化 | en:→ Empty directory, running full init"
        ["init_hexo_done"]="zh-cn:→ Hexo 初始化完成 | en:→ Hexo initialization completed"
        ["install_deps"]="zh-cn:→ 安装基础依赖 | en:→ Installing base dependencies"
        ["install_ncu"]="zh-cn:→ 安装 npm-check-updates | en:→ Installing npm-check-updates"

        # 自定义脚本
        ["script_found"]="zh-cn:→ 执行脚本: %s | en:→ Executing script: %s"
        ["script_not_found"]="zh-cn:→ 未找到脚本: %s | en:→ Script not found: %s"

        # Hexo 操作
        ["hexo_build"]="zh-cn:→ 生成静态文件 | en:→ Building static files"
        ["hexo_serve"]="zh-cn:→ 启动服务 (端口: %s) | en:→ Starting server (port: %s)"
        ["hexo_invalid_mode"]="zh-cn:错误: 无效的运行模式 | en:Error: Invalid run mode"
    )
}

function t() {
    local key="$1"
    local lang="${LANG:-en_US.UTF-8}"
    local text="${I18N[$key]}"

    [[ -z "$text" ]] && { echo "[MISSING_TRANSLATION:$key]"; return; }

    case "${lang:0:2}" in
        zh) echo "$text" | sed -E 's/.*zh-cn:([^|]+).*/\1/' ;;
        *)  echo "$text" | sed -E 's/.*en:([^|]+).*/\1/' ;;
    esac
}


# ========================
# 核心配置
# ========================
WORKDIR="/app"
cd "$WORKDIR" || { echo "$(t error_dir) $WORKDIR" >&2; exit 1; }

# ========================
# 阶段实现
# ========================
function setup_environment() {
    echo "$(t phase_env)"

    # Hexo 初始化
    if [ ! "$(ls -A .)" ]; then
        echo "$(t init_empty)"
        hexo init .
        echo "$(t init_hexo_done)"
    fi

    # 依赖安装
    if [ ! -d "node_modules" ]; then
        echo "$(t install_deps)"
        npm install
        npm install --save hexo-admin
    fi

    # 全局工具检查
    if ! npm list -g npm-check-updates &>/dev/null; then
        echo "$(t install_ncu)"
        npm install -g npm-check-updates
    fi
}

function install_requirements() {
    echo -e "\n$(t phase_requirements)"
    local req_file="requirements.txt"

    if [ -f "$req_file" ]; then
        echo "$(printf "$(t script_found)" "$req_file")"
        xargs npm install --save < "$req_file"
    else
        echo "$(printf "$(t script_not_found)" "$req_file")"
    fi
}

function setup_ssh_config() {
    echo -e "\n$(t phase_ssh)"
    mkdir -p .ssh
    chmod 700 .ssh

    if [ ! -f ".ssh/id_rsa" ]; then
        ssh-keygen -t rsa -b 4096 -f .ssh/id_rsa -N "" -q
        ssh-keyscan github.com gitlab.com >> .ssh/known_hosts 2>/dev/null
    fi

    if [ -n "${GIT_USER:-}" ] && [ -n "${GIT_EMAIL:-}" ]; then
        git config --global user.name "$GIT_USER"
        git config --global user.email "$GIT_EMAIL"
    fi
}

function run_custom_script() {
    local script_name="$1"
    if [ -f "$script_name" ]; then
        echo "$(printf "$(t script_found)" "$script_name")"
        chmod +x "$script_name"
        ./"$script_name"
    else
        echo "$(printf "$(t script_not_found)" "$script_name")"
    fi
}

function execute_hexo() {
    echo -e "\n$(t phase_hexo)"
    case "${RUN_MODE:-server}" in
        build)
            echo "$(t hexo_build)"
            hexo clean && hexo generate
            ;;
        server)
            local port="${HEXO_PORT:-4000}"
            echo "$(printf "$(t hexo_serve)" "$port")"
            hexo server -d -p "$port"
            ;;
        *)
            echo "$(t hexo_invalid_mode)" >&2
            exit 1
            ;;
    esac
}

# ========================
# 主流程控制
# ========================
function main() {
    init_i18n
	echo "$(t start)"
    setup_environment
    run_custom_script "custom_script1.sh"
    install_requirements
    run_custom_script "custom_script2.sh"
    setup_ssh_config
    execute_hexo
}

main "$@"
