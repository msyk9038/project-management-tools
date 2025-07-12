#!/bin/bash

echo "🔍 Checking tmuxinator configuration files..."
echo ""

# ghq管理下の全プロジェクトを取得
projects=$(ghq list)
if [ -z "$projects" ]; then
  echo "❌ No projects found"
  exit 1
fi

missing_configs=()
existing_configs=()
total_projects=0

# 各プロジェクトのtmuxinator設定ファイルをチェック
while IFS= read -r project; do
  if [ -z "$project" ]; then
    continue
  fi
  
  total_projects=$((total_projects + 1))
  project_name=$(basename "$project")
  tmux_config="${XDG_CONFIG_HOME:-$HOME/.config}/tmuxinator/$project_name.yml"
  
  if [ -f "$tmux_config" ]; then
    existing_configs+=("$project")
  else
    missing_configs+=("$project")
  fi
done <<< "$projects"

# 結果レポート
echo "📊 Tmuxinator Configuration Status Report"
echo "========================================"
echo "📂 Total projects: $total_projects"
echo "✅ Configured projects: ${#existing_configs[@]}"
echo "❌ Missing configurations: ${#missing_configs[@]}"
echo ""

if [ ${#missing_configs[@]} -eq 0 ]; then
  echo "✅ All projects have tmuxinator configuration files!"
  echo ""
  echo "📋 Existing configurations:"
  echo "──────────────────────────"
  for project in "${existing_configs[@]}"; do
    project_name=$(basename "$project")
    echo "   ✅ $project"
  done
  exit 0
fi

echo "❌ Projects missing tmuxinator configuration:"
echo "───────────────────────────────────────────────"
for project in "${missing_configs[@]}"; do
  project_name=$(basename "$project")
  echo "   📁 $project"
  echo "      Config: ${XDG_CONFIG_HOME:-$HOME/.config}/tmuxinator/$project_name.yml"
done
echo ""

read -p "🔧 Generate missing tmuxinator configs? (Y/n): " generate_configs
if [[ "$generate_configs" =~ ^[Nn]$ ]]; then
  echo "❌ Operation cancelled"
  exit 0
fi

# テンプレートファイルの存在確認
mise_root_dir="$(ghq root)"
template_dir="$mise_root_dir/templates"
tmux_template_path="$template_dir/tmuxinator.yml.template"

if [ ! -f "$tmux_template_path" ]; then
  echo "❌ Tmuxinator template not found: $tmux_template_path"
  exit 1
fi

# 設定ファイルディレクトリを作成
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/tmuxinator"

# 各プロジェクトの設定ファイルを生成
success_count=0
failure_count=0

for project in "${missing_configs[@]}"; do
  project_name=$(basename "$project")
  project_path="$(ghq root)/$project"
  tmux_config="${XDG_CONFIG_HOME:-$HOME/.config}/tmuxinator/$project_name.yml"
  
  echo "🔧 Generating config for: $project_name"
  
  # テンプレートから設定ファイルを生成
  if sed -e "s/PROJECT_NAME/$project_name/g" -e "s|PROJECT_ROOT|$project_path|g" "$tmux_template_path" > "$tmux_config"; then
    echo "   ✅ Created: $tmux_config"
    success_count=$((success_count + 1))
  else
    echo "   ❌ Failed to create: $tmux_config"
    failure_count=$((failure_count + 1))
  fi
done

echo ""
echo "📊 Generation Results:"
echo "═══════════════════════"
echo "✅ Successfully created: $success_count files"
echo "❌ Failed to create: $failure_count files"
echo ""

if [ $success_count -gt 0 ]; then
  echo "🚀 You can now use 'mise run enter' to start tmuxinator sessions!"
fi