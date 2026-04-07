.PHONY: build clean site test help

BUILD_DIR := build
SKILL_NAME := play-fixai-game
SKILL_FILE := $(SKILL_NAME).skill
PKG_SRC_PATH := skills/$(SKILL_NAME)
SITE_DIR := _site
PKG_DOC_FILES := LICENSE.md NOTICE.md README.md

help:
	@echo "Available targets:"
	@echo "  make build  - Create $(SKILL_FILE) for installation"
	@echo "  make site   - Stage $(SKILL_NAME) assets to $(SITE_DIR)/ for GitHub Pages"
	@echo "  make clean  - Remove all build artifacts"
	@echo "  make test   - Run packaging tests"

build: clean
	@echo "Building $(SKILL_FILE)..."
	@mkdir -p $(BUILD_DIR)/$(SKILL_NAME)
	@cp $(PKG_SRC_PATH)/SKILL.md $(BUILD_DIR)/$(SKILL_NAME)/
	@cp -r $(PKG_SRC_PATH)/agents $(BUILD_DIR)/$(SKILL_NAME)/
	@cp $(PKG_DOC_FILES) $(BUILD_DIR)/$(SKILL_NAME)/
	@cd $(BUILD_DIR) && zip -r -q ../$(SKILL_FILE) $(SKILL_NAME)
	@rm -rf $(BUILD_DIR)
	@echo "✓ Created $(SKILL_FILE)"
	@ls -lh $(SKILL_FILE)

site: clean
	@echo "Staging $(SKILL_NAME) for GitHub Pages..."
	@mkdir -p $(SITE_DIR)/agents
	@awk 'BEGIN{d=0} /^---$$/{d++; if(d<=2){print; next} else{print "- - -"; next}} {print}' \
		$(PKG_SRC_PATH)/SKILL.md \
		| sed '/^version:/d;/^author:/d' \
		> $(SITE_DIR)/SKILL.md
	@cp -r $(PKG_SRC_PATH)/agents/. $(SITE_DIR)/agents/
	@cp $(PKG_DOC_FILES) $(SITE_DIR)/
	@touch $(SITE_DIR)/.nojekyll
	@echo "✓ Staged to $(SITE_DIR)/"

clean:
	@rm -rf $(BUILD_DIR) $(SKILL_FILE) $(SITE_DIR)
	@echo "Cleaned build artifacts"

test:
	@sh test/packaging_test.sh
