#! /usr/bin/env bash

update_string="Updating version for";

if [[ "$1" == *bsp-layout-ext.1 ]]; then
  echo "$update_string manpage"
  sed "s|{{VERSION}}|$(git describe --tags --abbrev=0)|g" bsp-layout-ext.1 > "$1"
else
  echo "$update_string main script"
  sed "s|{{VERSION}}|$(git describe --tags --abbrev=0)|g" layout-ext.sh.tmp > "$1"/layout-ext.sh
fi
