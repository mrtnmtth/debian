DEBS_DIR = debs
DL_DIR = dl
REPO_DIR = repo

.PHONY: all clean repo

all: fetch download repo

repo:
	mkdir -p $(REPO_DIR)
	cp $(DEBS_DIR)/*.deb $(REPO_DIR)/
	cp $(DL_DIR)/*.deb $(REPO_DIR)/
	./scripts/rename.sh $(REPO_DIR)
	cd $(REPO_DIR) && dpkg-scanpackages --multiversion . /dev/null | gzip -9c > Packages.gz

download:
	@mkdir -p $(DL_DIR)
	@while read -r url; do \
		filename=$$(basename "$$url"); \
		version=$$(echo "$$url" | rev | cut -d'/' -f2 | rev); \
		cached="$${filename%.deb}_$${version}.deb"; \
		if [ ! -f "$(DL_DIR)/$$cached" ]; then \
			echo "Downloading $$filename version $$version..."; \
			wget -q -O "$(DL_DIR)/$$cached" "$$url"; \
		else \
			echo "File $$cached already exists in $(DL_DIR), skipping."; \
		fi; \
	done < packages.txt

fetch:
	scripts/fetch-packages.sh

clean:
	rm -rf $(DL_DIR)

clean-all: clean
	rm -rf $(REPO_DIR)
