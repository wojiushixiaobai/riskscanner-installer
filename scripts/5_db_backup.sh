#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
PROJECT_DIR=$(dirname ${BASE_DIR})
# shellcheck source=./util.sh
. "${BASE_DIR}/utils.sh"
BACKUP_DIR=/opt/riskscanner/db_backup
CURRENT_VERSION=$(get_config CURRENT_VERSION)

HOST=$(get_config DB_HOST)
PORT=$(get_config DB_PORT)
USER=$(get_config DB_USER)
PASSWORD=$(get_config DB_PASSWORD)
DATABASE=$(get_config DB_NAME)
DB_FILE=${BACKUP_DIR}/${DATABASE}-${CURRENT_VERSION}-$(date +%F_%T).sql

function main() {
  docker_network_check
  mkdir -p ${BACKUP_DIR}
  echo "$(gettext 'Backing up')..."
  backup_cmd="mysqldump --host=${HOST} --port=${PORT} --user=${USER} --password=${PASSWORD} ${DATABASE}"
  docker run --rm -i --network=rs_default registry.cn-qingdao.aliyuncs.com/x-lab/mysql:5.7.31 ${backup_cmd} > ${DB_FILE}

  code="x$?"
  if [[ "$code" != "x0" ]]; then
    log_error "$(gettext 'Backup failed')!"
    rm -f "${DB_FILE}"
    exit 1
  else
    log_success "$(gettext 'Backup succeeded! The backup file has been saved to'): ${DB_FILE}"
  fi
}

if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
  main
fi