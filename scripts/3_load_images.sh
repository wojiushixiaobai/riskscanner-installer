#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# shellcheck source=./util.sh
. "${BASE_DIR}/utils.sh"
IMAGE_DIR=images

cd "${BASE_DIR}" || return

function load_image_files() {
  images=$(get_images)
  for image in ${images}; do
    filename=$(basename "${image}").tar
    filename_windows=${filename/:/_}
    if [[ -f ${IMAGE_DIR}/${filename_windows} ]]; then
      filename=${filename_windows}
    fi
    if [[ ! -f ${IMAGE_DIR}/${filename} ]]; then
      continue
    fi

    echo -n "${image} <= ${IMAGE_DIR}/${filename} "
    md5_filename=$(basename "${image}").md5
    md5_path=${IMAGE_DIR}/${md5_filename}
    image_id=$(docker inspect -f "{{.ID}}" "${image}" 2>/dev/null || echo "")
    saved_id=""

    if [[ -f "${md5_path}" ]]; then
      saved_id=$(cat "${md5_path}")
    fi
    if [[ ${image_id} != "${saved_id}" ]]; then
      echo
      docker load <"${IMAGE_DIR}/${filename}"
    else
      echo "$(gettext 'Docker image loaded, skipping')"
    fi
  done
}

function pull_image() {
  images=$(get_images)
  DOCKER_IMAGE_PREFIX=$(get_config DOCKER_IMAGE_PREFIX)
  i=1
  for image in ${images}; do
    echo "[${image}]"
    if ! docker images | grep "${image%:*}" | grep "${image#*:}" >/dev/null; then
      if [[ -n "${DOCKER_IMAGE_PREFIX}" && $(image_has_prefix "${image}") == "0" ]]; then
        docker pull "${DOCKER_IMAGE_PREFIX}/${image}"
        docker tag "${DOCKER_IMAGE_PREFIX}/${image}" "${image}"
        docker rmi -f "${DOCKER_IMAGE_PREFIX}/${image}"
      else
        docker pull "${image}"
      fi
    fi
    ((i++)) || true
  done
}

function main() {
  if [[ -d "${IMAGE_DIR}" && -f "${IMAGE_DIR}/mysql:5.7.31.tar" ]]; then
    load_image_files
  else
    pull_image
  fi
  echo_done
}

if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
  main
fi
