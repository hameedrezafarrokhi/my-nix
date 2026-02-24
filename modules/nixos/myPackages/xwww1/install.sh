#!/usr/bin/env bash

TMP_DIR=$(mktemp -d /tmp/xwww-install.XXXXX);

if [[ ! "$1" == "local" ]]; then
  git clone https://github.com/hameedrezafarrokhi/xwww.git $TMP_DIR;
  cd $TMP_DIR;
fi

VERSION=$(git describe --tags --abbrev=0);

sudo make VERSION="$VERSION" install || exit 1;

for dep in ffmpeg hsetroot feh; do
  !(which $dep >/dev/null 2>&1) && echo "[Missing dependency] xwww needs $dep installed";
done;

rm -rf "$TMP_DIR";

exit 0;
