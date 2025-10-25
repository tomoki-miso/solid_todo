# todo_solid

<p align="center">
  <img src="https://github.com/user-attachments/assets/fbc15662-89bc-4ac7-a5ed-00dd806601b2" width="60%">
</p>

Solidart（Signals）を使った Flutter 製 TODO アプリのサンプルです。`flutter_solidart` によるリアクティブな状態管理、`disco` の DI、そして `http` 経由のシンプルなモック REST API を組み合わせ、カウンターと TODO リストの 2 画面を実装しています。TODO リストは GET / POST / PATCH / DELETE をすべてモック API に対して行い、状態は `ListSignal` でリアクティブに同期されます。

## 概要 / Features
- Signal + Computed を使ったカウンター画面（リアクティブなダブルカウンター付き）
- `ListSignal` + `ProviderScope` で構成した TODO 画面（取得 / 追加 / 削除 / 完了トグル / 部分更新）
- `tool/mock_api.dart` によるローカルモック API（ダミーデータ・PATCH 更新・遅延シミュレーション対応）
- `SolidartConfig.autoDispose = false` を指定したシンプルなルーティングとページ遷移

## 技術スタック
- Flutter 3.35 以降（Dart SDK ^3.9.2）
- [flutter_solidart](https://pub.dev/packages/flutter_solidart)
- [disco](https://pub.dev/packages/disco)
- `http`（REST クライアント）

## 動作要件
1. Flutter SDK がセットアップ済みであること
2. iOS/Android エミュレータ、Chrome、または実機デバイス
3. Dart CLI（`dart` コマンド）— モック API の起動に使用

## クイックスタート
```bash
# 依存パッケージの取得
flutter pub get

# 別ターミナルでモック API を起動（デフォルト :8080）
dart run tool/mock_api.dart [port]

# アプリの起動（例: Chrome）
flutter run -d chrome
```

### 基本的な操作フロー
1. `MainPage` から `カウンター` または `ToDo リスト` を選択
2. カウンターでは `Signal` を直接操作してリアクティブ更新を確認
3. TODO リストでは FAB から追加ダイアログを開き、新しい TODO を作成
4. チェックアイコンで完了/未完了を PATCH で更新、ゴミ箱アイコンで削除

## モック API について
立ち上げコマンド
```bash
dart run tool/mock_api.dart
```

`TodoController` はデフォルトで `http://localhost:8080` を参照します。Android エミュレータで動かす場合は `lib/controller/todo_contoller.dart` の `_baseUrl` を `http://10.0.2.2:8080` などに変更してください。

| HTTP | エンドポイント | 説明 |
|------|----------------|------|
| GET    | `/todos`          | TODO 一覧を JSON で返却（`?delay=1000` で遅延追加可） |
| POST   | `/todos`          | `{"title":"string","isCompleted":false}` で TODO 作成 |
| PATCH  | `/todos/{id}`     | `title` や `isCompleted` を一部更新 |
| DELETE | `/todos/{id}`     | 指定 ID の TODO を削除 |

## ディレクトリ構成（抜粋）
```text
lib/
  main.dart              # ルーティングとエントリポイント
  controller/todo_contoller.dart  # REST 呼び出し + Signal 管理
  model/todo.dart        # Todo エンティティ
  pages/
    counter.dart         # Signal/Computed のデモ
    todos.dart           # ProviderScope + ListView
source/                 # Solid Annotations 版のサンプル実装
tool/
  mock_api.dart          # ローカルモック API
```

## 開発時によく使うコマンド
- 静的解析: `flutter analyze`
- テスト（現状サンプル未収録）: `flutter test`
- フォーマット: `dart format .`

## 今後の発展アイデア
1. API ベース URL を `--dart-define` や `.env` から注入できるようにする
2. `todoControllerProvider` のテスト・モック実装を追加

本リポジトリは Solidart × Flutter の最小構成サンプルとして、チュートリアルや勉強会資料などに自由にご利用ください。
