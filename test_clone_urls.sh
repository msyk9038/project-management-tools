#!/bin/bash

# Clone機能のURL形式テスト
# テスト用のURL形式を確認

echo "🧪 Testing clone URL patterns..."

# テスト対象のURL形式
test_urls=(
    "git@github.com:msyk9038/repository_name.git"
    "git@github.com:msyk9038/repository_name"
    "https://github.com/msyk9038/repository_name.git"
    "https://github.com/msyk9038/repository_name"
    "https://github.com/msyk9038/repository_name/"
    "invalid-url"
    "https://gitlab.com/user/repo.git"
)

# URL解析の正規表現（.mise.tomlから抽出）
ssh_pattern="git@github\.com:([^/]+)/([^\.]+)(\.git)?$"
https_pattern="https://github\.com/([^/]+)/([^/\.]+)(\.git)?/?$"

echo "SSH パターン: $ssh_pattern"
echo "HTTPS パターン: $https_pattern"
echo ""

for url in "${test_urls[@]}"; do
    echo "Testing: $url"
    
    if [[ "$url" =~ $ssh_pattern ]]; then
        github_user="${BASH_REMATCH[1]}"
        repo_name="${BASH_REMATCH[2]}"
        echo "  ✅ SSH形式でマッチ: user=$github_user, repo=$repo_name"
    elif [[ "$url" =~ $https_pattern ]]; then
        github_user="${BASH_REMATCH[1]}"
        repo_name="${BASH_REMATCH[2]}"
        echo "  ✅ HTTPS形式でマッチ: user=$github_user, repo=$repo_name"
    else
        echo "  ❌ マッチしません"
    fi
    echo ""
done

echo "🎯 期待される結果:"
echo "  - git@github.com:user/repo.git ✅"
echo "  - git@github.com:user/repo ✅"
echo "  - https://github.com/user/repo.git ✅"
echo "  - https://github.com/user/repo ✅"
echo "  - https://github.com/user/repo/ ✅"
echo "  - invalid-url ❌"
echo "  - https://gitlab.com/user/repo.git ❌ (GitHubのみサポート)"