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

### 2. 前提条件のインストール

このツールを使用するには以下のツールが必要です。まだインストールしていないものがあれば、下記の手順でインストールしてください。

#### [Homebrew](https://brew.sh/) (パッケージマネージャー)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
macOS/Linuxでソフトウェアのインストールとアップデートを簡単にするツールです。

#### [mise](https://mise.jdx.dev/) - タスクランナー・開発環境管理
```bash
brew install mise
```
**できること:** プロジェクトごとのタスク実行、言語バージョン管理、環境変数管理を統一的に行えます。今回は主にタスクランナーとして使用します。

#### [ghq](https://github.com/x-motemen/ghq) - リポジトリ管理
```bash
brew install ghq
```
**できること:** GitHubなどのリモートリポジトリをローカルで効率的に管理できます。決まったルールでディレクトリが整理され、プロジェクトの場所を迷うことがなくなります。

#### [fzf](https://github.com/junegunn/fzf) - ファジーファインダー
```bash
brew install fzf
```
**できること:** 曖昧検索で素早くファイルやディレクトリを選択できます。プロジェクト選択時の操作が格段に快適になります。

#### [tmux](https://github.com/tmux/tmux) - ターミナルマルチプレクサー
```bash
brew install tmux
```
**できること:** 1つのターミナルウィンドウで複数のセッションを管理できます。プロジェクト作業時に複数のペインを同時に使えるようになります。

#### [tmuxinator](https://github.com/tmuxinator/tmuxinator) - tmux セッション管理
```bash
brew install tmuxinator
```
**できること:** tmuxセッションの設定をファイルで管理し、プロジェクトごとに決まったレイアウトで開発環境を起動できます。

#### [GitHub CLI](https://cli.github.com/) - GitHub操作
```bash
brew install gh
```
**できること:** コマンドラインからGitHubリポジトリの作成、プルリクエスト、Issues操作などが行えます。ブラウザを開かずにGitHub操作が完結します。

#### [lazygit](https://github.com/jesseduffield/lazygit) - Git TUI
```bash
brew install lazygit
```
**できること:** ターミナル上で直感的にGit操作ができるツールです。ステージング、コミット、ブランチ操作などがマウス操作のような感覚で行えます。

#### [uv](https://github.com/astral-sh/uv) - Python 環境管理（Pythonプロジェクトの場合）
```bash
brew install uv
```
**できること:** 従来のpipenvやpoetryより高速なPython仮想環境管理ツールです。依存関係の管理が劇的に高速化されます。

#### GitHub CLI の認証設定
GitHubとの連携のため、初回のみ認証が必要です：
```bash
gh auth login
```
ブラウザが開くので、GitHubアカウントでログインしてください。

### 3. グローバルセットアップの実行

```bash
./setup.sh
```

このスクリプトが以下を実行します：
- `.mise.toml` を `~/ghq` にコピー
- `templates/` ディレクトリを `~/ghq/templates` にコピー
- 既存ファイルの自動バックアップ
- 適切なパーミッション設定

### 4. 設定の信頼

```bash
cd ~/ghq
mise trust
```

## 🚀 使い方

### 1. 新規プロジェクト作成

```bash
mise new
```

**実行内容:**
- プロジェクト名の入力
- `$(ghq root)/local/プロジェクト名` にディレクトリ作成
- Git リポジトリの初期化
- Python プロジェクトかどうかの確認（uv venv の作成）
- テンプレートファイルからプロジェクトファイルを生成：
  - `README.md` (プロジェクト概要)
  - `.env` (環境変数設定)
  - `.envrc` (direnv設定)
  - `.gitignore` (Git除外設定)
- tmuxinator 設定ファイルの生成

### 2. GitHub への公開

```bash
mise publish
```

**実行内容:**
- `local/` 配下のプロジェクトを fzf で選択
- GitHub リポジトリ名の設定（デフォルト: プロジェクト名）
- リポジトリの説明入力
- 公開設定の選択（public/private）
- GitHub CLI でリポジトリ作成
- README.md の Topics セクションから GitHub Topics を自動設定
- プロジェクトを `github.com/ユーザー名/リポジトリ名` に移動
- tmuxinator 設定ファイルのパス更新

### 3. 既存プロジェクトへの移行

```bash
mise enter
```

**実行内容:**
- ghq 管理下の全プロジェクトを fzf で表示
- 選択したプロジェクトの tmuxinator セッション開始

### 4. プロジェクト情報表示

```bash
mise info
```

**実行内容:**
- ghq 管理下の全プロジェクトを fzf で表示
- 選択したプロジェクトの詳細情報表示（README概要、Git統計など）

### 5. プロジェクト削除

```bash
mise delete
```

**実行内容:**
- ghq 管理下の全プロジェクトを fzf で表示
- プロジェクトの詳細情報表示（安全確認）
- 'DELETE' 入力による確認後、プロジェクトと tmuxinator 設定を削除

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

## 📄 License

MIT License - 詳細は [LICENSE](LICENSE) ファイルを参照してください。