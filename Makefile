DEBS_DIR = debs
REPO_DIR = repo

.PHONY: all clean repo

all: download repo

repo:
	mkdir -p $(REPO_DIR)
	cp $(DEBS_DIR)/*.deb $(REPO_DIR)/
	cd $(REPO_DIR) && dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz

download:
	mkdir -p $(DEBS_DIR)
	cd $(DEBS_DIR) && cat ../packages.txt | xargs -n 1 wget -nc

clean:
	rm -rf $(DEBS_DIR)

clean-all: clean
	rm -rf $(REPO_DIR)
