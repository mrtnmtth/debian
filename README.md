# Debian Repository

The debian repository is served by GitHub Pages at [https://mrtnmtth.github.io/debian](https://mrtnmtth.github.io/debian).

## Usage

Add the repository to your `sources.list` file:

```bash
echo "deb [trusted=yes] https://mrtnmtth.github.io/debian/repo /" > /etc/apt/sources.list
```

## Adding packages to the repository

1. Clone this repository.
2. Put the links to your deb files in the `packages.txt` file.
3. Run `make` to generate the repository.
4. The repository will be generated in the `repo` directory.
