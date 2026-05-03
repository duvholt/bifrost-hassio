#!/bin/sh

set -eu

if [ $# -ne 1 ]; then
    echo "usage: $0 <bifrost-git-dir>"
    exit 1
fi

TARGET_DIR="$1"
FIRST_COMMIT="75eb23384b20acaca85e582c8ed4cfada4248616"

set_version() {
    DIR=$1
    VER=$2

    sed -i -re "s|^(version):.+|\1: ${VER}|" ${DIR}/config.yaml
    sed -i -re "s|^  (.+): \"(ghcr.io/duvholt/bifrost):.+\"|  \1: \"\2:${VER}\"|" ${DIR}/build.yaml
}

./generate.py "$TARGET_DIR" templates/readme-stable.jinja "${FIRST_COMMIT}..master" > bifrost/README.md
./generate.py "$TARGET_DIR" templates/readme-dev.jinja    "master..dev"             > bifrost-dev/README.md

./generate.py "$TARGET_DIR" templates/changelog-stable.jinja "${FIRST_COMMIT}..master" > bifrost/CHANGELOG.md
./generate.py "$TARGET_DIR" templates/changelog-dev.jinja    "${FIRST_COMMIT}..dev"    > bifrost-dev/CHANGELOG.md

set_version bifrost  master-2026-05-03
set_version bifrost-dev dev-2025-05-20
