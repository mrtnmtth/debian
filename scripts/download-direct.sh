#!/bin/bash
# Download direct-URL .deb packages listed in direct-urls.txt into the download
# cache using wget timestamping (-N), and regenerate direct-packages.lock with one
# "<package> <version>" line per package. The URLs are stable "latest"
# pointers that never change, so direct-packages.lock is the change-detection signal
# for CI (deploy gating, cache key, commit messages).
# Usage:
#   scripts/download-direct.sh [dl-dir]

set -euo pipefail

DL_DIR="${1:-dl}"
mkdir -p "$DL_DIR"

entries=()
if [ -f direct-urls.txt ]; then
  while IFS= read -r url; do
    [ -n "$url" ] || continue
    case "$url" in \#*) continue ;; esac
    file="$DL_DIR/$(basename "$url")"
    # -N re-downloads only when the server's Last-Modified is newer than
    # the cached file; -P keeps the server filename (-O would defeat -N).
    if ! wget -nv -N -P "$DL_DIR" "$url"; then
      # A partial file with a fresh mtime would make -N skip retries forever.
      rm -f "$file"
      echo "Download failed for $url" >&2
      exit 1
    fi
    entries+=("$(dpkg-deb -f "$file" Package) $(dpkg-deb -f "$file" Version)")
  done < direct-urls.txt
fi

if [ ${#entries[@]} -gt 0 ]; then
  printf '%s\n' "${entries[@]}" | sort > direct-packages.lock
else
  : > direct-packages.lock
fi
