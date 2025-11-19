#!/bin/bash

# Check if the file exists
if [ ! -f projects.txt ]; then
  echo "File projects.txt not found!"
  exit 1
fi

# Loop through each line in the file
while IFS= read -r line; do
  # Check if the line is not empty
  if [ -n "$line" ]; then
    # Extract the repository name from the line
    repo_name=$(echo "$line" | awk -F'/' '{print $2}')

    echo "Fetching assets for $repo_name..."

    # Make a single API call: capture body and HTTP code in one go
    response=$(curl -sS -L \
      -H "User-Agent: debian-repository-script" \
      -H "Accept: application/vnd.github+json" \
      -w "\n%{http_code}" \
      "https://api.github.com/repos/$line/releases/latest")

    http_code="${response##*$'\n'}"   # last line is the HTTP code
    body="${response%$'\n'*}"         # everything before the last newline

    if [ "$http_code" -ne 200 ]; then
      echo "Error fetching assets for $repo_name. HTTP code: $http_code"
      error_message=$(jq -r '.message // "Unknown error"' <<< "$body" 2>/dev/null || echo "Unknown error")
      echo "Error message: $error_message"
      url=""
    else
      # Find the amd64 .deb asset URL (handle missing assets array safely)
      url=$(jq -r '.assets[]? | select(.name | test("amd64\\.deb")) | .browser_download_url' <<< "$body")
    fi

    # If the URL is not empty add it to packages.txt (if it doesn't already exist)
    if [ -n "$url" ]; then
      if ! grep -q "$url" packages.txt; then
        echo "$url" >> packages.txt
        echo "Added $url to packages.txt"
      else
        echo "$url already exists in packages.txt"
      fi
    else
      echo "No amd64.deb package found for $repo_name"
    fi

  fi
done < projects.txt

# Sort entries in packages.txt alphabetically
sort -o packages.txt packages.txt
