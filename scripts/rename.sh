#!/bin/bash

set -euo pipefail

rename_deb_file() {
  local file="$1"
  local dir package_name version architecture new_base new_file

  dir=$(dirname "$file")
  package_name=$(dpkg-deb -f "$file" Package 2>/dev/null || true)
  version=$(dpkg-deb -f "$file" Version 2>/dev/null || true)
  architecture=$(dpkg-deb -f "$file" Architecture 2>/dev/null || true)

  if [[ -z "$package_name" || -z "$version" || -z "$architecture" ]]; then
    echo "Skipping $file (invalid .deb metadata)"
    return
  fi

  new_base="${package_name}_${version}_${architecture}.deb"
  new_file="${dir}/${new_base}"

  if [[ "$file" != "$new_file" ]]; then
    # Always move onto the canonical name, replacing any existing target.
    # "package_version_arch" uniquely identifies the build, so a pre-existing
    # target is the same version. We overwrite instead of comparing contents:
    # under `actions/checkout` with `lfs: false` the committed file on disk is a
    # Git LFS pointer, not the real .deb, so a content comparison would always
    # (wrongly) report a difference and leave a duplicate behind. When the
    # content is genuinely identical, Git/LFS sees the same object and nothing
    # is re-committed.
    mv -f "$file" "$new_file"
    echo "Renamed $file to $new_file"
  fi
}

process_directory() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    echo "Directory $dir not found!"
    exit 1
  fi

  shopt -s nullglob
  for file in "$dir"/*.deb; do
    rename_deb_file "$file"
  done
}

if [[ -d "${1:-}" ]]; then
  process_directory "$1"
elif [[ -f "${1:-}" ]]; then
  if [[ "$1" == *.deb ]]; then
    rename_deb_file "$1"
  else
    echo "File $1 is not a .deb file!"
    exit 1
  fi
else
  echo "Input ${1:-} is neither a directory nor a file!"
  exit 1
fi
