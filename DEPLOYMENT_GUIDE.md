# デプロイメントガイド

このドキュメントでは、Fashion Assistant Web AppをAzureにデプロイ・再デプロイする方法について説明します。

## 目次

1. [前提条件](#前提条件)
2. [基本デプロイ手順](#基本デプロイ手順)
3. [高度なデプロイ方法](#高度なデプロイ方法)
4. [設定とリソース管理](#設定とリソース管理)
5. [トラブルシューティング](#トラブルシューティング)
6. [参考情報](#参考情報)

## 前提条件

### 必要なツール
- [Azure Developer CLI (azd)](https://aka.ms/azd) がインストールされていること
- Azureにログインしていること (`azd auth login`)

### azd環境について

azd環境とは、Azure Developer CLIがローカルで管理する設定情報のことです：

- **保存場所**: `.azure/<環境名>/` フォルダ
- **含まれる情報**: サブスクリプションID、テナントID、リージョン、環境変数など
- **対応するAzureリソース**: リソースグループ、App Service、AI Foundryプロジェクトなど

例：
```
azd環境名: myapp-env
↓ 対応する
Azureリソースグループ: rg-myapp-env
```

**注意**: azd環境名とリソースグループ名は異なります。azd環境はローカルの設定ファイル、リソースグループは実際のAzureリソースです。

## 基本デプロイ手順

### 新規環境へのデプロイ

初回デプロイや新しい環境を作成する場合：

```bash
# 新しい環境を初期化
azd init

# デプロイ実行（インフラ作成 + アプリデプロイ）
azd up
```

### 既存環境への再デプロイ

#### 1. 環境の確認と選択

```bash
# 現在のazd環境を確認
azd env list

# デプロイ先の環境を選択
azd env select <環境名>
```

#### 2. 環境変数の確認

```bash
# 現在の環境設定を確認
azd env get-values
```

#### 3. デプロイの実行

```bash
# アプリケーションのみをデプロイ
azd deploy

# または、インフラとアプリを同時にデプロイ
azd up
```

### デプロイ後の設定

AI Agent機能を使用するために、以下の環境変数をAzure App Serviceに設定：

1. Azure Portalで対象のApp Serviceに移動
2. 「設定」→「環境変数」を選択
3. 以下のアプリ設定を追加：

| 名前 | 値 |
|------|-----|
| `AzureAIAgent__ConnectionString` | Azure AI Foundryプロジェクトの接続文字列 |
| `AzureAIAgent__AgentId` | 作成したエージェントのID (asst_xxxxx形式) |

## 高度なデプロイ方法

### 複数環境の管理

#### 方法1: 新しいazd環境を作成（推奨）

```bash
# 新しい環境を初期化
azd env new <新しい環境名>

# 例：本番環境を残して開発環境を作成
azd env new dev-env

# 新しい環境を選択
azd env select dev-env

# 新しい環境にデプロイ
azd up
```

**結果**：
- 既存のリソース：`rg-<元の環境名>`（保持）
- 新しいリソース：`rg-<新しい環境名>`（新規作成）

#### 方法2: 既存App Serviceを保持したまま新規作成

現在のApp Serviceを削除せずに、新しいApp Serviceを作成する方法です。

##### オプション2-1: タグを手動変更

1. Azure Portalで既存のApp Serviceに移動
2. 「タグ」セクションで`azd-service-name`の値を`web`から`web-old`に変更
3. `azd deploy`を実行（新しいApp Serviceが作成されます）

##### オプション2-2: App Service Planを共有（コスト最適化）

既存のApp Service Planに新しいApp Serviceを追加することで、**追加料金なし**で新しいアプリを作成できます。

**手順**：

1. **既存のApp Service Plan情報を取得**：
   ```bash
   az appservice plan list --resource-group rg-<環境名> --query "[].{Name:name, Id:id}" --output table
   ```

2. **main.parameters.json を編集**：
   ```json
   {
     "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
     "contentVersion": "1.0.0.0",
     "parameters": {
       "appServiceName": {
         "value": "app-web-new-<任意の文字列>"
       }
     }
   }
   ```

3. **既存App Serviceのタグを変更**：
   - Azure Portalで既存のApp Serviceの`azd-service-name`タグを`web`から`web-old`に変更

4. **デプロイ実行**：
   ```bash
   azd deploy
   ```

**結果**：
- ✅ **既存App Service Plan**: そのまま利用（追加料金なし）
- ✅ **新しいApp Service**: 同じPlan内に作成
- ✅ **既存App Service**: `web-old`タグで保持

### 注意事項

⚠️ **コスト**: 2つのApp Serviceが同時に稼働する場合、料金が倍になります  
⚠️ **管理**: 複数の環境を適切に管理する必要があります  
⚠️ **DNS**: 同じカスタムドメインは1つのApp Serviceにのみ設定可能です

## トラブルシューティング

### よくある問題と解決方法

#### タグ競合エラー

**エラーメッセージ**:
```
ERROR: expecting only '1' resource tagged with 'azd-service-name: web', but found '2'
```

**解決方法**:
1. Azure Portalにログインし、対象のリソースグループに移動
2. 同じ`azd-service-name: web`タグを持つリソースを特定
3. 不要なリソースから該当タグを削除するか、リソース自体を削除
4. 再度`azd deploy`を実行

#### リソースの確認方法

Azure Resource Graphを使用してタグの状況を確認：

```bash
# 特定のタグを持つリソースを確認
az graph query -q "resources | where tags['azd-service-name'] == 'web'"
```

### デプロイ成功の確認

デプロイが成功すると以下のようなメッセージが表示されます：

```
SUCCESS: Your application was deployed to Azure in 36 seconds.
You can view the resources created under the resource group rg-<環境名> in Azure Portal:
https://portal.azure.com/#@/resource/subscriptions/<サブスクリプションID>/resourceGroups/rg-<環境名>/overview
```

## 設定とリソース管理

### リソース命名規則

- **リソースグループ**: `rg-<環境名>`
- **App Service**: `app-web-<ランダム文字列>`
- **App Service プラン**: `plan-<ランダム文字列>` 
- **リージョン**: デプロイ時に選択したリージョン
- **エンドポイント**: `https://app-web-<ランダム文字列>.azurewebsites.net/`

**注意**: 実際のリソース名は環境ごとに自動生成されます。具体的な情報は個人の `AZURE_RESOURCES.md` ファイルに記録してください。

### セキュリティとリソース情報の管理

#### ⚠️ セキュリティ上の注意

**絶対に公開リポジトリに含めてはいけない情報**:
- 実際のリソース名（リソースグループ、App Service名など）
- エンドポイントURL
- サブスクリプションID、テナントID
- 接続文字列、API キー
- Agent ID

#### リソース情報の管理方法

このプロジェクトでは、Azureリソースの詳細情報を `AZURE_RESOURCES.md` ファイルに記録しています。このファイルには以下の機密情報が含まれるため、`.gitignore` に追加してGitリポジトリにコミットされないよう設定されています：

- サブスクリプション ID
- テナント ID  
- リソース名とID
- エンドポイント URL
- 認証情報

**注意**: このファイルは個人用メモとして使用し、チーム共有が必要な場合は Azure Key Vault などのセキュアな方法を使用してください。

### 重要な運用ガイドライン

1. **タグの一意性**: `azd-service-name: web`タグは1つのリソースにのみ設定する
2. **環境の分離**: 本番環境と開発環境のリソースは適切に分離する
3. **バックアップ**: 重要なデータは事前にバックアップを取る
4. **監視**: デプロイ後はアプリケーションログを確認する
5. **機密情報管理**: リソース情報は `AZURE_RESOURCES.md` に記録し、`.gitignore` でバージョン管理から除外する

## 参考情報

### 有用なコマンド一覧

```bash
# 環境管理
azd env list                    # 環境一覧の表示
azd env select <環境名>         # 環境の切り替え
azd env get-values             # 環境変数の表示
azd env new <環境名>           # 新しい環境の作成

# デプロイ関連
azd init                       # プロジェクトの初期化
azd up                         # インフラ作成 + アプリデプロイ
azd deploy                     # アプリのみデプロイ
azd provision                  # インフラのみ作成

# 監視・デバッグ
azd logs                       # ログの確認
azd monitor                    # Azure Monitor の表示

# 環境の削除（注意！）
azd down                       # リソースの削除
```

### 参考リンク

- [Azure Developer CLI ドキュメント](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- [Azure AI Agent Service ドキュメント](https://learn.microsoft.com/azure/ai-services/agents/overview)
- [Azure App Service ドキュメント](https://learn.microsoft.com/azure/app-service/)

---

**注意**: このガイドは Fashion Assistant Web App の特定の構成に基づいています。他のプロジェクトでは手順が異なる場合があります。
