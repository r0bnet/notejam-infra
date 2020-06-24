#!/usr/bin/env bash

set -euo pipefail

if ! which pwsh; then
  echo "Powershell is needed to run ${0}" 1>&2
  exit 1
fi

if [[ -z $ARM_TENANT_ID || -z $ARM_SUBSCRIPTION_ID ]]; then
  echo "You need to set \$ARM_TENANT_ID and \$ARM_SUBSCRIPTION_ID" 1>&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

MSSQL_RG_NAME=$(terraform output mssql_resource_group_name)
MSSQL_SERVER_NAME=$(terraform output mssql_server_name)
MSSQL_DB_NAME=$(terraform output mssql_db_name)

pwsh -Command "$SCRIPT_DIR/set-db-backup-retention.ps1 -SubscriptionId $ARM_SUBSCRIPTION_ID -MssqlResourceGroupName ${MSSQL_RG_NAME} -MssqlResourceServerName ${MSSQL_SERVER_NAME} -MssqlDbName ${MSSQL_DB_NAME}"