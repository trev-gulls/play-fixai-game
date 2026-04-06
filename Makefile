.PHONY: build clean help

BUILD_DIR := build
SKILL_NAME := play-fixai-game
SKILL_FILE := $(SKILL_NAME).skill
SOURCE_DIR := skills/$(SKILL_NAME)

help:
	@echo "Available targets:"
	@echo "  make build  - Create $(SKILL_FILE) for installation"
	@echo "  make clean  - Remove build artifacts"

build: clean
	@echo "Building $(SKILL_FILE)..."
	@mkdir -p $(BUILD_DIR)/$(SKILL_NAME)
	@cp $(SOURCE_DIR)/SKILL.md $(BUILD_DIR)/$(SKILL_NAME)/
	@cp -r $(SOURCE_DIR)/agents $(BUILD_DIR)/$(SKILL_NAME)/
	@cp LICENSE.md $(BUILD_DIR)/$(SKILL_NAME)/LICENSE.md
	@cp NOTICE.md $(BUILD_DIR)/$(SKILL_NAME)/NOTICE.md
	@cp README.md $(BUILD_DIR)/$(SKILL_NAME)/README.md
	@cd $(BUILD_DIR) && zip -r -q ../$(SKILL_FILE) $(SKILL_NAME)
	@rm -rf $(BUILD_DIR)
	@echo "✓ Created $(SKILL_FILE)"
	@ls -lh $(SKILL_FILE)

clean:
	@rm -rf $(BUILD_DIR) $(SKILL_FILE)
	@echo "Cleaned build artifacts"
