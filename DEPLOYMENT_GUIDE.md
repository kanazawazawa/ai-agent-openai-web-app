# デプロイメントガイド

このドキュメントでは、Fashion Assistant Web Appを既存のAzure環境に再デプロイする方法について説明します。

## 前提条件

- [Azure Developer CLI (azd)](https://aka.ms/azd) がインストールされていること
- Azureにログインしていること (`azd auth login`)
- 既存のazd環境が設定されていること

### azd環境とは

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

## 既存環境への再デプロイ手順

### 1. 環境の確認

まず、現在のazd環境を確認します：

```bash
azd env list
```

### 2. 環境の選択

デプロイ先の環境を選択します：

```bash
azd env select <環境名>
```

例：
```bash
azd env select myapp-env
```

### 3. 環境変数の確認

現在の環境設定を確認します：

```bash
azd env get-values
```

### 4. デプロイの実行

アプリケーションをデプロイします：

```bash
azd deploy
```

## トラブルシューティング

### タグ競合エラー

**エラーメッセージ**:
```
ERROR: expecting only '1' resource tagged with 'azd-service-name: web', but found '2'
```

**解決方法**:
1. Azure Portalにログインし、対象のリソースグループに移動
2. 同じ`azd-service-name: web`タグを持つリソースを特定
3. 不要なリソースから該当タグを削除するか、リソース自体を削除
4. 再度`azd deploy`を実行

### リソースの確認

Azure Resource Graphを使用してタグの状況を確認：

```bash
# 特定のタグを持つリソースを確認
az graph query -q "resources | where tags['azd-service-name'] == 'web'"
```

### 環境変数の設定

デプロイ後、AI Agent機能を使用するために以下の環境変数をAzure App Serviceに設定：

1. Azure Portalで対象のApp Serviceに移動
2. 「設定」→「環境変数」を選択
3. 以下のアプリ設定を追加：

| 名前 | 値 |
|------|-----|
| `AzureAIAgent__ConnectionString` | Azure AI Foundryプロジェクトの接続文字列 |
| `AzureAIAgent__AgentId` | 作成したエージェントのID (asst_xxxxx形式) |

## デプロイ成功例

```
SUCCESS: Your application was deployed to Azure in 36 seconds.
You can view the resources created under the resource group rg-myapp-env in Azure Portal:
https://portal.azure.com/#@/resource/subscriptions/xxx/resourceGroups/rg-myapp-env/overview
```

## リソース情報

### 本番環境例
- **リソースグループ**: `rg-myapp-env`
- **App Service**: `app-web-<ランダム文字列>`
- **App Service プラン**: `plan-<ランダム文字列>` (P0v3)
- **リージョン**: East US 2
- **エンドポイント**: `https://app-web-<ランダム文字列>.azurewebsites.net/`

## 重要な注意事項

1. **タグの一意性**: `azd-service-name: web`タグは1つのリソースにのみ設定する
2. **環境の分離**: 本番環境と開発環境のリソースは適切に分離する
3. **バックアップ**: 重要なデータは事前にバックアップを取る
4. **監視**: デプロイ後はアプリケーションログを確認する
5. **機密情報管理**: リソース情報は `AZURE_RESOURCES.md` に記録し、`.gitignore` でバージョン管理から除外する

## リソース情報の管理

このプロジェクトでは、Azureリソースの詳細情報を `AZURE_RESOURCES.md` ファイルに記録しています。このファイルには以下の機密情報が含まれるため、`.gitignore` に追加してGitリポジトリにコミットされないよう設定されています：

- サブスクリプション ID
- テナント ID  
- リソース名とID
- エンドポイント URL
- 認証情報

**注意**: このファイルは個人用メモとして使用し、チーム共有が必要な場合は Azure Key Vault などのセキュアな方法を使用してください。

## 有用なコマンド

```bash
# 環境一覧の表示
azd env list

# 環境の切り替え
azd env select <環境名>

# 環境変数の表示
azd env get-values

# デプロイ
azd deploy

# ログの確認
azd logs

# 環境の削除（注意！）
azd down
```

## 参考リンク

- [Azure Developer CLI ドキュメント](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- [Azure AI Agent Service ドキュメント](https://learn.microsoft.com/azure/ai-services/agents/overview)
- [Azure App Service ドキュメント](https://learn.microsoft.com/azure/app-service/)
