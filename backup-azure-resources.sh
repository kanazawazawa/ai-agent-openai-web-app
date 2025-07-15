#!/bin/bash

# Azure リソース情報バックアップスクリプト
# 使用方法: ./backup-azure-resources.sh

BACKUP_DIR="$HOME/azure-backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/AZURE_RESOURCES_$TIMESTAMP.md"

# バックアップディレクトリを作成
mkdir -p "$BACKUP_DIR"

# ファイルが存在する場合のみバックアップ
if [ -f "AZURE_RESOURCES.md" ]; then
    cp "AZURE_RESOURCES.md" "$BACKUP_FILE"
    echo "✅ Azure リソース情報をバックアップしました: $BACKUP_FILE"
    
    # 古いバックアップを削除（30日以上古いもの）
    find "$BACKUP_DIR" -name "AZURE_RESOURCES_*.md" -type f -mtime +30 -delete
    echo "🧹 30日以上古いバックアップを削除しました"
    
    # バックアップファイル一覧を表示
    echo "📁 現在のバックアップファイル:"
    ls -la "$BACKUP_DIR"/AZURE_RESOURCES_*.md 2>/dev/null || echo "   (バックアップファイルなし)"
else
    echo "❌ AZURE_RESOURCES.md が見つかりません"
    exit 1
fi
