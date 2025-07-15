# Azure リソース情報テンプレート

> ⚠️ **注意**: このテンプレートをコピーして `AZURE_RESOURCES.md` を作成し、実際の値を入力してください。

## 環境情報

### 本番環境 ({環境名})
- **Azure サブスクリプション ID**: `{subscription-id}`
- **Azure テナント ID**: `{tenant-id}`
- **リージョン**: `{region}` (`{region-code}`)
- **リソースグループ**: `{resource-group-name}`

### App Service 関連
- **App Service 名**: `{app-service-name}`
- **App Service プラン**: `{app-service-plan-name}`
- **SKU**: `{app-service-sku}`
- **エンドポイント**: `{app-service-url}`
- **デフォルトホスト名**: `{app-service-hostname}`

### AI Foundry 関連
- **AI Storage Account**: `{ai-storage-account}`
- **AI Services**: `{ai-services-name}`
- **AI Key Vault**: `{ai-keyvault-name}`

### 認証情報
- **サインイン アカウント**: `{admin-account}`
- **プリンシパル ID**: `{principal-id}` (App Service マネージド ID)

### AZD 環境設定
- **環境名**: `{azd-environment-name}`
- **設定場所**: `.azure/{azd-environment-name}/.env`

### タグ設定
- **azd-env-name**: `{azd-environment-name}`
- **azd-service-name**: `{azd-service-name}`
- **SecurityControl**: `Ignore`
- **CostControl**: `Ignore`

## デプロイ履歴

### {日付}
- **デプロイ時刻**: {deploy-time}
- **デプロイ時間**: {deploy-duration}
- **デプロイ結果**: {deploy-result}
- **変更内容**: {changes}
- **問題**: {issues}

## 重要なメモ

1. **マネージド ID**: App Service にシステム割り当てマネージド ID が設定済み
2. **AI Agent 接続**: 環境変数 `AzureAIAgent__ConnectionString` と `AzureAIAgent__AgentId` の設定が必要

## トラブルシューティング履歴

### {問題名}
- **エラー**: `{error-message}`
- **解決**: {solution}
- **確認コマンド**: `{verification-command}`
