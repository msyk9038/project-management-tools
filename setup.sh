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
log_success "Permissions set successfully"


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