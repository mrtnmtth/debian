#!/bin/bash
# Print a commit message describing newly added entries in github-packages.lock
# and updated direct-download packages in direct-packages.lock.
# Reads the diff of the current working tree against HEAD, so it works
# equally well in CI and locally (before staging).
# Usage:
#   scripts/commit-message.sh | git commit -F -

set -euo pipefail

added=()
while IFS= read -r url; do
  [ -z "$url" ] && continue
  added+=("$(echo "$url" | awk -F'/' '{print $5, $8}')")
done < <(git diff HEAD -- github-packages.lock | grep '^+' | grep -v '^+++' | sed 's/^+//')

# direct-packages.lock lines are already "<package> <version>".
while IFS= read -r line; do
  [ -z "$line" ] && continue
  added+=("$line")
done < <(git diff HEAD -- direct-packages.lock | grep '^+' | grep -v '^+++' | sed 's/^+//')

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
