DEBS_DIR = debs
DL_DIR = dl
REPO_DIR = repo

.PHONY: all clean repo

all: download repo

repo:
	mkdir -p $(REPO_DIR)
	cp $(DEBS_DIR)/*.deb $(REPO_DIR)/
	cp $(DL_DIR)/*.deb $(REPO_DIR)/
	./scripts/rename.sh $(REPO_DIR)
	cd $(REPO_DIR) && dpkg-scanpackages --multiversion . /dev/null | gzip -9c > Packages.gz

download:
	mkdir -p $(DL_DIR)
	cd $(DL_DIR) && cat ../packages.txt | xargs -n 1 wget -nc

clean:
	rm -rf $(DL_DIR)

clean-all: clean
	rm -rf $(REPO_DIR)
