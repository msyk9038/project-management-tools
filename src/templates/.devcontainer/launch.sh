#!/usr/bin/env bash
set -euo pipefail

# エラー時のクリーンアップ関数
cleanup_and_retry() {
    echo "エラーが発生しました。コンテナをクリーンアップして再試行します..."
    
    # 現在のプロジェクト名を取得（.mise.tomlで設定する命名規則に基づく）
    PROJECT_NAME=$(basename "$(pwd)")
    CONTAINER_NAME="project-${PROJECT_NAME}-container"
    
    # 指定されたコンテナ名のコンテナを停止・削除
    if docker ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        echo "コンテナ $CONTAINER_NAME を停止・削除しています..."
        docker stop "$CONTAINER_NAME" 2>/dev/null || true
        docker rm "$CONTAINER_NAME" 2>/dev/null || true
    fi
    
    echo "クリーンアップが完了しました。devcontainerを再構築します..."
}

# 1) devcontainer 起動（エラーハンドリング付き）
if ! devcontainer up --workspace-folder .; then
    cleanup_and_retry
    devcontainer up --workspace-folder .
fi

# 2) 準備完了をポーリング（最大10回、2秒間隔）
for i in {1..10}; do
  if devcontainer exec --workspace-folder . echo ready &>/dev/null; then
    echo "Container is ready."
    break
  fi
  echo "Waiting for container to become ready… ($i/10)"
  sleep 2
done

# 3) zsh を起動（ここで attach します）
exec devcontainer exec --workspace-folder . zsh -ic 'claude --dangerously-skip-permissions'
