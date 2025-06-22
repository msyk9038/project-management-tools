#!/bin/bash

# Project Management Tools Setup Script
# ====================================
#
# このスクリプトは、プロジェクト管理ツールをグローバルにセットアップします。
# .mise.toml とテンプレートファイルを ~/ghq 直下にコピーして、
# どこからでもプロジェクト管理コマンドを使用できるようにします。

set -e

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ログ関数
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_MISE_TOML="$SCRIPT_DIR/.mise.toml"
SOURCE_TEMPLATES_DIR="$SCRIPT_DIR/templates"

# 必要なソフトウェアのリスト
REQUIRED_SOFTWARE=(
    "mise"
    "ghq"
    "fzf"
    "tmux"
    "tmuxinator"
    "gh"
    "lazygit"
    "uv"
    "devcontainer"
)

# ソフトウェアのインストール状況をチェックする関数
check_software() {
    log_info "必要なソフトウェアの導入状況をチェック中..."
    
    local missing_software=()
    
    for software in "${REQUIRED_SOFTWARE[@]}"; do
        if command -v "$software" >/dev/null 2>&1; then
            log_success "$software: インストール済み"
        else
            log_warning "$software: 未インストール"
            missing_software+=("$software")
        fi
    done
    
    if [ ${#missing_software[@]} -gt 0 ]; then
        log_info "未インストールのソフトウェアを自動インストール中..."
        
        # Homebrewの存在確認
        if ! command -v brew >/dev/null 2>&1; then
            log_error "Homebrewがインストールされていません。"
            log_error "まず以下のコマンドでHomebrewをインストールしてください："
            log_error "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi
        
        # 未インストールのソフトウェアをインストール
        for software in "${missing_software[@]}"; do
            log_info "$software をインストール中..."
            if brew install "$software"; then
                log_success "$software のインストールが完了しました"
            else
                log_error "$software のインストールに失敗しました"
                exit 1
            fi
        done
    else
        log_success "すべての必要なソフトウェアがインストール済みです"
    fi
}

# tmuxinatorディレクトリの作成
create_tmuxinator_dir() {
    local tmuxinator_dir="$HOME/.tmuxinator"
    
    if [ ! -d "$tmuxinator_dir" ]; then
        log_info "~/.tmuxinator ディレクトリを作成中..."
        mkdir -p "$tmuxinator_dir"
        log_success "~/.tmuxinator ディレクトリを作成しました"
    else
        log_success "~/.tmuxinator ディレクトリは既に存在します"
    fi
}

# GitHub CLIの認証状況をチェックする関数
check_github_auth() {
    log_info "GitHub CLIの認証状況をチェック中..."
    
    if command -v gh >/dev/null 2>&1; then
        if gh auth status >/dev/null 2>&1; then
            log_success "GitHub CLI: 認証済み"
        else
            log_warning "GitHub CLI: 未認証"
            log_info "GitHubとの連携のため、認証を行ってください："
            echo ""
            echo "  gh auth login"
            echo ""
            log_info "認証が完了したら、再度セットアップスクリプトを実行してください。"
            
            read -p "今すぐ認証を行いますか？ (y/N): " -n 1 -r
            echo
            
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                log_info "GitHub CLI認証を開始します..."
                if gh auth login; then
                    log_success "GitHub CLI認証が完了しました"
                else
                    log_error "GitHub CLI認証に失敗しました"
                    log_error "後で手動で 'gh auth login' を実行してください"
                fi
            else
                log_warning "GitHub CLI認証をスキップしました"
                log_warning "後で手動で 'gh auth login' を実行してください"
            fi
        fi
    else
        log_warning "GitHub CLIがまだインストールされていません（後でインストールされます）"
    fi
}

# インストール先を確認
GHQ_ROOT="$(ghq root 2>/dev/null || echo "$HOME/ghq")"
if [ ! -d "$GHQ_ROOT" ]; then
    log_warning "ghq root directory not found. Creating: $GHQ_ROOT"
    mkdir -p "$GHQ_ROOT"
fi

TARGET_MISE_TOML="$GHQ_ROOT/.mise.toml"
TARGET_TEMPLATES_DIR="$GHQ_ROOT/templates"

echo "🚀 Project Management Tools Setup"
echo "=================================="
echo ""

# ソフトウェアのインストール状況チェック
check_software

# tmuxinatorディレクトリの作成
create_tmuxinator_dir

echo ""
log_info "Source directory: $SCRIPT_DIR"
log_info "Target directory: $GHQ_ROOT"
echo ""

# 既存ファイルの確認とバックアップ
if [ -f "$TARGET_MISE_TOML" ]; then
    log_warning "Existing .mise.toml found. Creating backup..."
    cp "$TARGET_MISE_TOML" "$TARGET_MISE_TOML.backup.$(date +%Y%m%d_%H%M%S)"
    log_success "Backup created: $TARGET_MISE_TOML.backup.$(date +%Y%m%d_%H%M%S)"
fi

if [ -d "$TARGET_TEMPLATES_DIR" ]; then
    log_warning "Existing templates directory found. Creating backup..."
    mv "$TARGET_TEMPLATES_DIR" "$TARGET_TEMPLATES_DIR.backup.$(date +%Y%m%d_%H%M%S)"
    log_success "Backup created: $TARGET_TEMPLATES_DIR.backup.$(date +%Y%m%d_%H%M%S)"
fi

# .mise.toml をコピー
log_info "Copying .mise.toml..."
if [ -f "$SOURCE_MISE_TOML" ]; then
    cp "$SOURCE_MISE_TOML" "$TARGET_MISE_TOML"
    log_success ".mise.toml copied successfully"
else
    log_error "Source .mise.toml not found: $SOURCE_MISE_TOML"
    exit 1
fi

# templates ディレクトリをコピー
log_info "Copying templates directory..."
if [ -d "$SOURCE_TEMPLATES_DIR" ]; then
    cp -r "$SOURCE_TEMPLATES_DIR" "$TARGET_TEMPLATES_DIR"
    log_success "Templates directory copied successfully"
else
    log_error "Source templates directory not found: $SOURCE_TEMPLATES_DIR"
    exit 1
fi

# パーミッション設定
log_info "Setting permissions..."
chmod 644 "$TARGET_MISE_TOML"
find "$TARGET_TEMPLATES_DIR" -type f -exec chmod 644 {} \;
# launch.shに実行権限を付与
if [ -f "$TARGET_TEMPLATES_DIR/.devcontainer/launch.sh" ]; then
    chmod +x "$TARGET_TEMPLATES_DIR/.devcontainer/launch.sh"
    log_success "Set execute permission for launch.sh"
fi
log_success "Permissions set successfully"

# GitHub CLIの認証状況チェック
check_github_auth

# インストール完了
echo ""
echo "🎉 Setup completed successfully!"
echo "================================="
echo ""
log_success "Project management tools are now available globally"
log_info "Location: $GHQ_ROOT"
echo ""
echo "📖 Available commands:"
echo "   mise new     - Create a new project"
echo "   mise publish - Publish project to GitHub"
echo "   mise enter   - Enter existing project"
echo "   mise info    - Show project information"
echo "   mise delete  - Delete project"
echo ""
echo "🚀 To get started:"
echo "   cd $GHQ_ROOT"
echo "   mise trust"
echo "   mise new"
echo ""