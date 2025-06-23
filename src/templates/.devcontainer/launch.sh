#!/usr/bin/env bash
set -euo pipefail

# 1) devcontainer 起動
devcontainer up --workspace-folder .

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
