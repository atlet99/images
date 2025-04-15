#!/bin/bash
set -e

if [ -n "$YC_OAUTH_TOKEN" ]; then
  echo "🔐 YC_OAUTH_TOKEN provided — setting up Yandex Cloud CLI profile..."

  rm -rf ~/.config/yandex-cloud

  yc config profile create default
  yc config profile activate default

  yc config set token "$YC_OAUTH_TOKEN"
  yc config set region "kz"
  yc config set compute-default-zone "kz1-a"

  CLOUD_ID=$(yc resource-manager cloud list --format json --token "$YC_OAUTH_TOKEN" | jq -r '.[0].id')
  FOLDER_ID=$(yc resource-manager folder list --cloud-id "$CLOUD_ID" --format json --token "$YC_OAUTH_TOKEN" | jq -r '.[0].id')

  yc config set cloud-id "$CLOUD_ID"
  yc config set folder-id "$FOLDER_ID"

  echo "✅ CLI configured:"
  yc config list
else
  echo "ℹ️ YC_OAUTH_TOKEN not provided — skipping Yandex Cloud authentication"
fi

exec "$@"