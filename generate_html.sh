#!/bin/bash

set -e

tmp_dir_flag=false
phobos_dir_flag=false

usage() { echo "Usage: $0 [-d <phobos_dir>] [-o <output_dir>]" 1>&2; exit 1; }

while getopts ":d:o:" o; do
  case "${o}" in
    d)
      phobos_dir=${OPTARG}
      phobos_dir_flag=true
      ;;
    o)
      tmp_dir=${OPTARG}
      tmp_dir_flag=true
      ;;
    *)
      usage
      ;;
    esac
done

if ! $phobos_dir_flag || ! $tmp_dir_flag
then
  usage
fi


PHOBOS="$( cd "${phobos_dir}" && pwd )"
cd ${tmp_dir}

function generate_html {
  echo Processing "${1}"...
  fname=$(basename "${1}" .d)
  dmd "${1}" -D -Dd./ -Df${2}${fname}.html -o- &>/dev/null
}

for chapter in {"std","core"}
do
  for i in ${PHOBOS}/${chapter}/*
  do
    if test -f "${i}" 
    then
      generate_html "${i}" "${chapter}_"
    fi
  done
done

generate_html "${PHOBOS}/index.d" ""
