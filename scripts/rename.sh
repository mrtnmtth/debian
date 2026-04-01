#!/bin/bash

rename_deb_file() {
  local file="$1"
  local dir info package_name version architecture new_file

  dir=$(dirname "$file")
  info=$(dpkg-deb --info "$file")
  package_name=$(echo "$info" | grep "Package:" | awk '{print $2}')
  version=$(echo "$info" | grep "Version:" | awk '{print $2}')
  architecture=$(echo "$info" | grep "Architecture:" | awk '{print $2}')
  new_file="${dir}/${package_name}_${version}_${architecture}.deb"

  if [ "$file" != "$new_file" ]; then
    mv "$file" "$new_file"
    echo "Renamed $file to $new_file"
  fi
}

process_directory() {
  local dir="$1"
  if [ ! -d "$dir" ]; then
    echo "Directory $dir not found!"
    exit 1
  fi

  for file in "$dir"/*.deb; do
    if [ -f "$file" ]; then
      rename_deb_file "$file"
    fi
  done
}

if [ -d "$1" ]; then
  process_directory "$1"
elif [ -f "$1" ]; then
  if [[ "$1" == *.deb ]]; then
    rename_deb_file "$1"
  else
    echo "File $1 is not a .deb file!"
    exit 1
  fi
else
  echo "Input $1 is neither a directory nor a file!"
  exit 1
fi
