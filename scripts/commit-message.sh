#!/bin/bash
# Print a commit message describing newly added entries in packages.txt.
# Reads the diff of the current working tree against HEAD, so it works
# equally well in CI and locally (before staging).
# Usage:
#   scripts/commit-message.sh | git commit -F -

set -euo pipefail

added=()
while IFS= read -r url; do
  [ -z "$url" ] && continue
  added+=("$(echo "$url" | awk -F'/' '{print $5, $8}')")
done < <(git diff HEAD -- packages.txt | grep '^+' | grep -v '^+++' | sed 's/^+//')

if [ ${#added[@]} -eq 0 ]; then
  echo "Update packages & repository"
elif [ ${#added[@]} -le 3 ]; then
  joined=$(printf '%s, ' "${added[@]}")
  echo "Update packages: ${joined%, }"
else
  echo "Update packages & repository (${#added[@]} new versions)"
  echo
  printf -- '- %s\n' "${added[@]}"
fi
