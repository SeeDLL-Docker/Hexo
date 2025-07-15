#!/bin/bash
set -euo pipefail  # 严格模式：错误退出、未定义变量报错、管道中断捕获

# 阶段 1：环境初始化
function setup_env() {
    echo "=== 阶段 1：环境初始化 ==="
    
    # 1.1 检查 /app 是否为空
    if [ ! "$(ls -A /app)" ]; then
        echo "→ /app 为空，执行完整初始化..."
        hexo init
        npm install
        npm install --save hexo-admin
        return
    fi

    # 1.2 非空但缺少 node_modules
    if [ ! -d "/app/node_modules" ]; then
        echo "→ /app 非空但缺少 node_modules，安装基础依赖..."
        npm install
        npm install --save hexo-admin
    fi

    npm list -g | grep npm-check-updates  >/dev/null 2>&1 
    if [ $? -ne 0 ]; then
        echo "***** npm install npm-check-updates *****";
        npm install -g npm-check-updates
    fi
}

# 阶段 2：自定义脚本 1（前置）
function run_custom_script_1() {
    echo -e "\n=== 阶段 2：自定义脚本 1 检查 ==="
    local CUSTOM_SCRIPT_1="/app/custom_script1.sh"
    
    if [ -f "$CUSTOM_SCRIPT_1" ]; then
        echo "→ 发现 custom_script1.sh，执行..."
        chmod +x "$CUSTOM_SCRIPT_1"
        bash "$CUSTOM_SCRIPT_1"
    else
        echo "→ 未找到 custom_script1.sh，跳过"
    fi
}

# 阶段 3：安装 requirements.txt 中的依赖
function setup_requirements() {
    echo -e "\n=== 阶段 3：安装 requirements.txt ==="
    if [ -f "/app/requirements.txt" ]; then
        echo "→ 发现 requirements.txt，安装额外依赖..."
        cat /app/requirements.txt | xargs npm --prefer-offline install --save
    else
        echo "→ 未找到 requirements.txt，跳过"
    fi
}

# 阶段 4：自定义脚本 2（后置）
function run_custom_script_2() {
    echo -e "\n=== 阶段 4：自定义脚本 2 检查 ==="
    local CUSTOM_SCRIPT_2="/app/custom_script2.sh"
    
    if [ -f "$CUSTOM_SCRIPT_2" ]; then
        echo "→ 发现 custom_script2.sh，执行..."
        chmod +x "$CUSTOM_SCRIPT_2"
        bash "$CUSTOM_SCRIPT_2"
    else
        echo "→ 未找到 custom_script2.sh，跳过"
    fi
}

# 阶段 5：SSH 和 Git 配置
function setup_ssh_git() {
    echo -e "\n=== 阶段 5：SSH 和 Git 配置 ==="
    if [ ! -d "/app/.ssh" ]; then
        echo "→ 生成 SSH 密钥..."
        mkdir -p ~/.ssh
        ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -P ""
        ssh-keyscan github.com gitlab.com >> ~/.ssh/known_hosts
        cp -r ~/.ssh /app/
    fi

    if [ -n "${GIT_USER:-}" ] && [ -n "${GIT_EMAIL:-}" ]; then
        echo "→ 配置 Git 用户信息..."
        git config --global user.name "$GIT_USER"
        git config --global user.email "$GIT_EMAIL"
    else
        echo "→ 未提供 GIT_USER 或 GIT_EMAIL，跳过 Git 配置"
    fi
}

# 阶段 6：启动 Hexo 服务
function run_server() {
    echo -e "\n=== 阶段 6：启动 Hexo 服务 ==="
    local PORT="${HEXO_SERVER_PORT:-4000}"
    echo "→ 在端口 $PORT 启动服务..."
    hexo server -d -p "$PORT"
}

# 阶段 6：根据环境变量选择模式
function run_hexo() {
    echo -e "\n=== 阶段 6：执行 Hexo 操作 ==="
    
    case "${RUN_MODE:-server}" in  # 默认模式为 server
        "build")
            echo "→ 生成静态网页（hexo generate）..."
            hexo clean && hexo generate
            ;;
        "server")
            local PORT="${HEXO_SERVER_PORT:-4000}"
            echo "→ 启动 Web 服务（hexo server -p $PORT）..."
            hexo server -d -p "$PORT"
            ;;
        *)
            echo "错误：未知的 RUN_MODE 值 '${RUN_MODE}'，允许值为 'build' 或 'server'"
            exit 1
            ;;
    esac
}
 
function main() {
    setup_env
    run_custom_script_1
    setup_requirements
    run_custom_script_2
    setup_ssh_git
    run_hexo  # 替代原来的 run_server
}
main "$@"
