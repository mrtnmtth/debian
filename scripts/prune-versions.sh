#!/bin/bash
# Keep only the newest N versions of each package in a directory, deleting the
# older .deb files. This bounds the size of the Pages artifact (repo/), which
# otherwise grows every time a package updates because dpkg-scanpackages
# --multiversion indexes every version left in the directory.
#
# Versions are compared with `dpkg --compare-versions` (true Debian ordering,
# so epochs and ~pre-release suffixes sort correctly), and package/version are
# read from the .deb metadata rather than the filename.
#
# Usage:
#   scripts/prune-versions.sh <dir> [keep]   # keep defaults to 2

set -euo pipefail

DIR="${1:?usage: prune-versions.sh <dir> [keep]}"
KEEP="${2:-2}"

declare -A entries_of   # package -> "version<TAB>file" lines, one per .deb

shopt -s nullglob
for file in "$DIR"/*.deb; do
  pkg=$(dpkg-deb -f "$file" Package)
  ver=$(dpkg-deb -f "$file" Version)
  entries_of["$pkg"]+="${ver}"$'\t'"${file}"$'\n'
done

for pkg in "${!entries_of[@]}"; do
  mapfile -t remaining < <(printf '%s' "${entries_of[$pkg]}")
  (( ${#remaining[@]} > KEEP )) || continue

  kept=0
  # Repeatedly pull out the newest remaining version. The first KEEP are kept;
  # every one after that is an older version to delete.
  while (( ${#remaining[@]} > 0 )); do
    best=0
    for i in "${!remaining[@]}"; do
      vi="${remaining[i]%%$'\t'*}"
      vb="${remaining[best]%%$'\t'*}"
      if dpkg --compare-versions "$vi" gt "$vb"; then
        best=$i
      fi
    done

    line="${remaining[best]}"
    unset 'remaining[best]'
    remaining=("${remaining[@]}")

    if (( kept < KEEP )); then
      kept=$((kept + 1))
    else
      ver="${line%%$'\t'*}"
      file="${line#*$'\t'}"
      echo "Pruning old ${pkg} ${ver}: ${file}"
      rm -f "$file"
    fi
  done
done
