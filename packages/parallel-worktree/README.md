# parallel-worktree

Git worktree + background agent による非同期並列開発プラグイン。

## 特徴

- **非同期実行**: タスク開始後すぐにユーザーに制御が戻る
- **並列開発**: 複数タスクを同時に実行可能
- **隔離環境**: 各タスクは独立した git worktree で実行
- **状態管理**: タスクの進捗を追跡・確認可能

## 使い方

### タスクを開始

```bash
# 単一タスク
/parallel-worktree:work "ユーザー認証機能を実装"

# 複数タスク（同時開始）
/parallel-worktree:work "ログインページ作成" "サインアップページ作成" "パスワードリセット"

# 1つずつ追加
/parallel-worktree:work "認証機能"
/parallel-worktree:work "検索機能"
/parallel-worktree:work "通知機能"
```

### 進捗確認

```bash
/parallel-worktree:status
```

出力例:
```
## Parallel Task Status

| Task ID | Branch | Description | Status |
|---------|--------|-------------|--------|
| task-001 | feature-auth | 認証機能 | ✅ Completed |
| task-002 | feature-search | 検索機能 | 🔄 Running |
```

### クリーンアップ

```bash
/parallel-worktree:cleanup
```

## 仕組み

```
1. /work "タスクA" "タスクB"
   ↓
2. worktree 作成 (.worktrees/task-a, .worktrees/task-b)
   ↓
3. Background Agent 起動 (run_in_background: true)
   ↓
4. ユーザーに制御が戻る（即座）
   ↓
5. 各 Agent が独立して実装作業
   ↓
6. /status で進捗確認
   ↓
7. /cleanup で完了タスクを削除
```

## ディレクトリ構成

```
your-project/
├── .worktrees/
│   ├── feature-auth/       # Task 1 の作業環境
│   ├── feature-search/     # Task 2 の作業環境
│   └── feature-notify/     # Task 3 の作業環境
├── .claude/
│   └── parallel-worktree-state.json  # タスク状態
└── src/
```

## 状態ファイル

`.claude/parallel-worktree-state.json`:

```json
{
  "tasks": [
    {
      "id": "task-1234567890-12345",
      "agent_id": "a127f7c",
      "worktree": "feature-auth",
      "description": "ユーザー認証機能を実装",
      "started_at": "2025-01-01T00:00:00Z",
      "status": "running"
    }
  ]
}
```

## インストール

```bash
/plugin marketplace add shabaraba/shabaraba-cc-plugins
/plugin install parallel-worktree
```

## 制限事項

- 各 worktree は main ブランチから作成される
- Agent は自動で push しない（ユーザーがレビュー後に push）
- 同じブランチ名の worktree は作成できない

## ライセンス

MIT
