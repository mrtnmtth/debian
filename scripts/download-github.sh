#!/bin/bash
# Download the pinned GitHub release .debs (github-packages.lock) into the
# download cache, skipping versions that are already cached. Afterwards
# prune cached .debs that are no longer listed in either channel
# (github-packages.lock or direct-urls.txt) — this script owns cache
# pruning for both channels.
# Usage:
#   scripts/download-github.sh [dl-dir]

set -euo pipefail

DL_DIR="${1:-dl}"
mkdir -p "$DL_DIR"

expected=""
while read -r url; do
  filename=$(basename "$url")
  version=$(echo "$url" | rev | cut -d'/' -f2 | rev)
  base="${filename%.deb}"
  version_no_v="${version#v}"
  case "$base" in
    *"$version"*|*"$version_no_v"*) cached="$filename" ;;
    *) cached="${base}_${version}.deb" ;;
  esac
  expected="$expected $cached"
  if [ ! -f "$DL_DIR/$cached" ]; then
    echo "Downloading $filename version $version..."
    # A failed download must not leave a partial file under the cached
    # name, or every later run would skip it as "already exists".
    if ! wget -q -O "$DL_DIR/$cached" "$url"; then
      rm -f "$DL_DIR/$cached"
      echo "Download failed for $url" >&2
      exit 1
    fi
  else
    echo "File $cached already exists in $DL_DIR, skipping."
  fi
done < github-packages.lock

if [ -f direct-urls.txt ]; then
  while read -r url; do
    [ -n "$url" ] || continue
    case "$url" in \#*) continue ;; esac
    expected="$expected $(basename "$url")"
  done < direct-urls.txt
fi

for f in "$DL_DIR"/*.deb; do
  [ -e "$f" ] || continue
  name=$(basename "$f")
  case " $expected " in
    *" $name "*) ;;
    *) echo "Pruning $name (no longer listed)"; rm -f "$f" ;;
  esac
done
