#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# shellcheck source=./util.sh
. "${BASE_DIR}/utils.sh"
VOLUME_DIR=$(get_config VOLUME_DIR)
BACKUP_DIR="${VOLUME_DIR}/db_backup"
CURRENT_VERSION=$(get_config CURRENT_VERSION)

HOST=$(get_config DB_HOST)
PORT=$(get_config DB_PORT)
USER=$(get_config DB_USER)
PASSWORD=$(get_config DB_PASSWORD)
DATABASE=$(get_config DB_NAME)
DB_FILE=${BACKUP_DIR}/${DATABASE}-${CURRENT_VERSION}-$(date +%F_%T).sql

function main() {
  docker_network_check
  mkdir -p "${BACKUP_DIR}"
  echo "$(gettext 'Backing up')..."

  project_name=$(get_config COMPOSE_PROJECT_NAME)
  net_name="${project_name}_default"

  backup_cmd="mysqldump --host=${HOST} --port=${PORT} --user=${USER} --password=${PASSWORD} ${DATABASE}"
  if ! docker run --rm -i --network="${net_name}" x-lab/mysql:5.7.31 ${backup_cmd} > "${DB_FILE}"; then
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
