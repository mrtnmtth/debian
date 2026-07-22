DEBS_DIR = debs
DL_DIR = dl
REPO_DIR = repo

.PHONY: all clean repo

all: fetch download repo

repo:
	mkdir -p $(REPO_DIR) $(DEBS_DIR) $(DL_DIR)
	rm -f $(REPO_DIR)/*.deb
	find $(DEBS_DIR) $(DL_DIR) -maxdepth 1 -name '*.deb' -exec cp {} $(REPO_DIR)/ \;
	./scripts/rename.sh $(REPO_DIR)
	cd $(REPO_DIR) && dpkg-scanpackages --multiversion . /dev/null | gzip -9c > Packages.gz

download:
	@./scripts/download-github.sh $(DL_DIR)
	@./scripts/download-direct.sh $(DL_DIR)

fetch:
	scripts/fetch-github.sh

clean:
	rm -rf $(DL_DIR)

clean-all: clean
	rm -rf $(REPO_DIR)
