#!/bin/bash
# coding: utf-8

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# shellcheck source=./util.sh
. "${BASE_DIR}/utils.sh"

HOST=$(get_config DB_HOST)
PORT=$(get_config DB_PORT)
USER=$(get_config DB_USER)
PASSWORD=$(get_config DB_PASSWORD)
DATABASE=$(get_config DB_NAME)

DB_FILE="$1"

function main() {
  docker_network_check
  echo "$(gettext 'Start restoring database'): $DB_FILE"
  restore_cmd="mysql --host=${HOST} --port=${PORT} --user=${USER} --password=${PASSWORD} ${DATABASE}"

  if [[ ! -f "${DB_FILE}" ]]; then
    echo "$(gettext 'file does not exist'): ${DB_FILE}"
    exit 2
  fi

  project_name=$(get_config COMPOSE_PROJECT_NAME)
  net_name="${project_name}_default"

  if ! docker run --rm -i --network="${net_name}" x-lab/mysql:5.7.31 ${restore_cmd} <"${DB_FILE}"; then
    log_error "$(gettext 'Database recovery failed. Please check whether the database file is complete or try to recover manually')!"
    exit 1
  else
    log_success "$(gettext 'Database recovered successfully')!"
  fi
}

if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
  if [[ -z "$1" ]]; then
    log_error "$(gettext 'Format error')！Usage './rsctl.sh restore_db DB_Backup_file '"
    exit 1
  fi
  if [[ ! -f $1 ]]; then
    echo "$(gettext 'The backup file does not exist'): $1"
    exit 2
  fi
  main
fi
