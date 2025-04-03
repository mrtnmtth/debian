# Debian Repository

The debian repository is served by GitHub Pages at [https://mrtnmtth.github.io/debian](https://mrtnmtth.github.io/debian).

## Usage

Add the repository to your `sources.list.d` directory:

```bash
echo "Types: deb
URIs: https://mrtnmtth.github.io/debian/repo/
Suites: /
Trusted: yes" | sudo tee /etc/apt/sources.list.d/mmtth.sources
```

## Adding packages to the repository

1. Clone this repository.
2. Put the links to your deb files in the `packages.txt` file.
3. Run `make` to generate the repository.
4. The repository will be generated in the `repo` directory.
