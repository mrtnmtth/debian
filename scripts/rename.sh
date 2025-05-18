#!/bin/bash

# Check if the directory exists
if [ ! -d "$1" ]; then
  echo "Directory $1 not found!"
  exit 1
fi

# Loop through each .deb file in the specified directory
for file in "$1"/*.deb; do
  # Check if the file exists
  if [ -f "$file" ]; then
    # Extract the package name, version, and architecture from the file name
    package_name=$(dpkg-deb --info "$file" | grep "Package:" | awk '{print $2}')
    version=$(dpkg-deb --info "$file" | grep "Version:" | awk '{print $2}')
    architecture=$(dpkg-deb --info "$file" | grep "Architecture:" | awk '{print $2}')

    # Rename the file to match the schema `package_name_version_architecture.deb`
    new_file="$1/${package_name}_${version}_${architecture}.deb"
    if [ "$file" != "$new_file" ]; then
      mv "$file" "$new_file"
      echo "Renamed $file to $new_file"
    fi
  fi
done
