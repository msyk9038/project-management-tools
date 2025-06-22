# Project Management Tools

プロジェクトの作成から GitHub 公開まで一貫したワークフローを提供する mise ベースのツールセットです。

## 📋 概要

- **ローカル開発**: `local/` ディレクトリで実験・開発
- **GitHub 公開**: 準備ができたらワンコマンドで GitHub に公開
- **プロジェクト管理**: ghq + tmuxinator で統一的な開発環境
- **テンプレート機能**: プロジェクト作成時に自動的にファイルを生成

## 🛠️ セットアップ

### 1. リポジトリのクローン

```bash
git clone https://github.com/msyk9038/project-management-tools.git
cd project-management-tools
```

### 2. セットアップ

**事前準備**: [Homebrew](https://brew.sh/)をインストールしてください。

```bash
# macOS/Linux用パッケージマネージャー
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**自動セットアップ実行**:

```bash
./setup.sh
```

このスクリプトが必要なソフトウェアを自動インストールし、設定ファイルをセットアップします。

**設定の有効化**:

```bash
cd ~/ghq
mise trust
```

これで準備完了です！

## 🚀 使い方

### 基本的なワークフロー

1. **アイデア段階**: `mise new` でローカルにプロジェクト作成
2. **開発進行**: ローカルで自由に実験・開発
3. **公開準備**: `mise publish` でGitHubに公開
4. **継続開発**: `mise enter` で開発環境を起動

### コマンド詳細

#### 1. 新規プロジェクト作成

```bash
mise new
```

プロジェクト名を入力すると、以下が自動実行されます：
- ローカル開発用ディレクトリの作成
- Gitリポジトリの初期化
- プロジェクトファイルの生成（README、設定ファイル等）
- 開発環境設定の準備

#### 2. GitHub への公開

```bash
mise publish
```

開発中のプロジェクトを一覧から選択し、GitHubに公開します：
- プロジェクト選択画面の表示
- リポジトリ名と説明の設定
- 公開設定（public/private）の選択
- GitHubリポジトリの自動作成
- プロジェクトファイルの移動

#### 3. プロジェクトを開く

```bash
mise enter
```

既存のプロジェクトを選択して開発環境を起動：
- 全プロジェクトの一覧表示
- プロジェクト選択
- tmux環境が起動（2つのウィンドウ構成）
  - **devウィンドウ**: 上下2分割
    - 上側: Claude Code（AI開発アシスタント）
    - 下側: 通常のターミナル
  - **gitウィンドウ**: Git操作用（lazygit）

**安全性について**: Claude Codeは開発コンテナ内で動作するため、万が一AIが予期しない動作をしても影響範囲はプロジェクト内に限定され、システム全体への影響はありません。

#### 4. プロジェクト情報表示

```bash
mise info
```

プロジェクトの詳細情報を確認：
- プロジェクト一覧から選択
- README概要とGit統計の表示

#### 5. プロジェクト削除

```bash
mise delete
```

不要なプロジェクトを安全に削除：
- プロジェクト一覧から選択
- 詳細情報表示による確認
- 確認入力後に**ローカル**から完全削除

**注意**: GitHubに公開済みのプロジェクトの場合、ローカルファイルのみ削除されます。GitHubリポジトリは残るので安心です。

## 🏗️ ディレクトリ構造

```
$(ghq root)/
├── local/                    # ローカル開発用
│   ├── project-a/           # 実験中プロジェクト
│   └── project-b/           # 開発中プロジェクト
└── github.com/              # GitHub 公開済み
    └── username/
        ├── published-project/
        └── another-repo/
```

## 📂 テンプレートファイル

`~/ghq/templates/` に配置されるテンプレートファイル：

- **README.md.template**: プロジェクトのREADME雛形（Topics セクション含む）
- **.env.template**: 環境変数設定ファイル雛形
- **.envrc.template**: direnv 設定ファイル雛形
- **.gitignore.template**: Git 除外設定ファイル雛形
- **tmuxinator.yml.template**: tmuxinator 設定ファイル雛形

これらのテンプレートは `PROJECT_NAME` プレースホルダーを含み、プロジェクト作成時に実際のプロジェクト名に置換されます。

## 🔧 tmuxinator 設定

各プロジェクトで生成される tmuxinator 設定：

```yaml
name: PROJECT_NAME
root: PROJECT_ROOT

windows:
  - dev:
      layout: even-vertical
      panes:
        - commands:
            - clear
            - claude                 # Claude Code起動
        - commands:
            - cd ../PROJECT_NAME
            - clear                  # 作業ディレクトリ

  - git:
      panes:
        - lazygit                    # Git TUI
```

## 💡 ワークフロー例

1. **アイデア段階**
   ```bash
   mise new
   # プロジェクト名: my-experiment
   # Python プロジェクト: N
   ```

2. **開発進行**
   ```bash
   # 通常の開発作業...
   # local/my-experiment で作業
   ```

3. **公開準備完了**
   ```bash
   mise publish
   # プロジェクト選択: my-experiment
   # リポジトリ名: my-experiment
   # 説明: Experimental project for...
   # 公開設定: N (private)
   ```

4. **継続開発**
   ```bash
   mise enter
   # github.com/username/my-experiment を選択
   ```

## 🎯 利点

- **統一的な開発環境**: 全プロジェクトで同じ tmux レイアウト
- **段階的な公開**: ローカル → GitHub への自然な移行
- **整理された構造**: ローカル開発と公開済みの明確な分離
- **自動化**: 手動作業を最小限に抑制

## 🔧 使用ソフトウェアについて

このツールでは以下のソフトウェアを使用しています（setup.sh実行時に自動インストールされます）：

### 必須ツール

- **[mise](https://mise.jdx.dev/)**: タスクランナー・開発環境管理
- **[ghq](https://github.com/x-motemen/ghq)**: リポジトリ管理
- **[fzf](https://github.com/junegunn/fzf)**: ファジーファインダー
- **[tmux](https://github.com/tmux/tmux)**: ターミナルマルチプレクサー
- **[tmuxinator](https://github.com/tmuxinator/tmuxinator)**: tmux セッション管理
- **[GitHub CLI](https://cli.github.com/)**: GitHub操作
- **[lazygit](https://github.com/jesseduffield/lazygit)**: Git TUI
- **[uv](https://github.com/astral-sh/uv)**: Python 環境管理
- **[devcontainer](https://containers.dev/)**: 開発コンテナ管理


## 📄 License

MIT License - 詳細は [LICENSE](LICENSE) ファイルを参照してください。