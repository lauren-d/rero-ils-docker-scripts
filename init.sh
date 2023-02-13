#!/bin/bash
# -*- coding: utf-8 -*-
#
# RERO ILS
# UCLouvain
# Copyright (C) 2019-2023 RERO
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

set -e

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

source "${SCRIPT_DIR}/includes/messages.sh"

usage () {
    info "usage: ./init.sh COMMAND [ARGUMENTS]
    clone             clone RERO-ILS sources
    build             build docker image from Dockerfile
      -a|--all                        build rero-ils-base and rero-ils images
      -t|--tgz_package <file_path>    rero-ils-ui tgz package
    start             start rero-ils (production mode)
    restart           restart rero-ils
    stop              stop rero-ils
    destroy           remove and destroy all (containers, networks, volumes)
    setup             run RERO-ILS setup
    "
}

clone () {
  info "-- Clone RERO-ILS repository"
  git clone --branch master https://github.com/rero/rero-ils.git src
}

build () {
    info "-- Build docker image"
    build_base_image=false
    tgz_file=""
    while test $# -gt 0
    do
      case "$1" in
        -a|--all)
          build_base_image=true ;;
        -t|--tgz_package)
          tgz_file="$2"
          shift ;;
      esac
      shift
    done

    # build images
    if $build_base_image ; then
      info "Build RERO-ILS docker base image"
      docker build --rm --no-cache -t rero/rero-ils-base:latest -f Dockerfile.base .
    fi

    if [[ $tgz_file == "" ]]; then
      info "Build RERO-ILS docker image"
      docker build --no-cache .
    else
      # rero-ils image
      info "Build RERO-ILS docker with UI"
      docker build \
        --build-arg UI_TGZ=$tgz_file \
        --no-cache .
    fi
}

start () {
  info "-- Starting RERO-ILS  full stack with docker compose"
  docker compose -f docker-compose.full.yml up -d
}

stop () {
  info "-- Stopping RERO-ILS  full stack with docker compose"
  docker compose -f docker-compose.full.yml stop
}

restart () {
  info "-- Restarting RERO-ILS full stack with docker compose"
  docker compose -f docker-compose.full.yml restart
}

destroy () {
  info "-- Stopping and destroying RERO-ILS full stack with docker compose"
  docker compose -f docker-compose.full.yml down --remove-orphans --volumes
}

setup () {
  info "-- Setup RERO-ILS"
  CONTAINER_NAME="web-api"
  CONTAINER_ID=$(docker container ls  | grep "${CONTAINER_NAME}" | awk '{print $1}')
  if [[ $CONTAINER_ID == "" ]]; then
    error "$CONTAINER_NAME seems not running."
  else
    docker exec -it $(docker container ls  | grep 'web-api' | awk '{print $1}') poetry run poe setup
  fi
}

main () {
    declare CMD=$1

    if [ -z $CMD ]; then
        error "You need to specify a command."
        usage
        exit 0
    fi

    if [[ ! $CMD =~ ^clone|build|start|restart|stop|destroy|setup ]]; then
        error "$CMD is not a supported command."
        exit 1
    fi

    $@
}

main $@
