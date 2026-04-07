# GitHub Pages Deployment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deploy skill assets to GitHub Pages so the Gallery install URL `https://trev-gulls.github.io/play-fixai-game/SKILL.md` serves the unmodified SKILL.md with correct MIME types.

**Architecture:** The Makefile is the single source of truth for what gets packaged. A new `make site` target stages the same files as `make build` (SKILL.md, agents/, LICENSE.md, NOTICE.md, README.md) into `_site/` with the same flat layout as the ZIP. A new `pages.yml` workflow calls `make site` then deploys `_site/` via the standard GitHub Pages Actions API. `release.yml` continues to call `make build` unchanged. A `.nojekyll` in `_site/` prevents Jekyll from stripping YAML frontmatter. Adding a file to the skill requires a single Makefile change and both outputs stay in sync.

**Tech Stack:** GitHub Actions (`actions/configure-pages@v5`, `actions/upload-pages-artifact@v3`, `actions/deploy-pages@v4`), GNU Make

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `.nojekyll` | Create | Prevents Jekyll from processing Pages output during build |
| `Makefile` | Modify | Add `site` and `clean-site` targets |
| `.github/workflows/pages.yml` | Create | Calls `make site` and deploys `_site/` to GitHub Pages on push to `main` |

---

### Task 1: Add `.nojekyll` to repo root

**Files:**
- Create: `.nojekyll`

This empty file tells GitHub Pages to skip Jekyll processing. Without it, Jekyll strips YAML frontmatter blocks from Markdown files — which would corrupt SKILL.md before it's served to the Gallery.

- [ ] **Step 1: Create `.nojekyll`**

```bash
touch .nojekyll
```

- [ ] **Step 2: Verify it exists and is empty**

```bash
ls -la .nojekyll
```

Expected output: `-rw-r--r-- ... 0 ... .nojekyll`

- [ ] **Step 3: Stage the file**

```bash
git add .nojekyll
```

---

### Task 2: Add `site` and `clean-site` targets to the Makefile

**Files:**
- Modify: `Makefile`

`make site` stages the same files as `make build` into `_site/` using the same flat layout as the ZIP. Both workflows share this definition — adding a file to the skill means one Makefile change.

- [ ] **Step 1: Add `SITE_DIR` variable and `site`/`clean-site` targets**

Append to `Makefile` after the existing `clean` target:

```makefile
SITE_DIR := _site

site: clean-site
	@echo "Staging $(SKILL_NAME) for GitHub Pages..."
	@mkdir -p $(SITE_DIR)/agents
	@cp $(SOURCE_DIR)/SKILL.md $(SITE_DIR)/
	@cp -r $(SOURCE_DIR)/agents/. $(SITE_DIR)/agents/
	@cp LICENSE.md NOTICE.md README.md $(SITE_DIR)/
	@touch $(SITE_DIR)/.nojekyll
	@echo "✓ Staged to $(SITE_DIR)/"

clean-site:
	@rm -rf $(SITE_DIR)
	@echo "Cleaned site artifacts"
```

Also update the `.PHONY` line to include the new targets:

```makefile
.PHONY: build clean site clean-site help
```

And add `site` and `clean-site` to the `help` target:

```makefile
	@echo "  make site   - Stage $(SKILL_NAME) assets to $(SITE_DIR)/ for GitHub Pages"
	@echo "  make clean-site - Remove site artifacts"
```

- [ ] **Step 2: Dry-run `make site` to verify the output**

```bash
make site
find _site -type f | sort
make clean-site
```

Expected `find` output:
```
_site/.nojekyll
_site/LICENSE.md
_site/NOTICE.md
_site/README.md
_site/SKILL.md
_site/agents/argument-drafter.md
```

- [ ] **Step 3: Verify `make build` still works (no regression)**

```bash
make build
ls -lh play-fixai-game.skill
make clean
```

Expected: ZIP created successfully, same as before.

- [ ] **Step 4: Stage the Makefile**

```bash
git add Makefile
```

---

### Task 3: Create the `pages.yml` workflow

**Files:**
- Create: `.github/workflows/pages.yml`

The workflow calls `make site` then uploads `_site/` — no inline staging logic.

- [ ] **Step 1: Write the workflow file**

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches:
      - main

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: false

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}

    steps:
      - uses: actions/checkout@v4

      - name: Stage assets
        run: make site

      - name: Setup Pages
        uses: actions/configure-pages@v5

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: _site

      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

Save this to `.github/workflows/pages.yml`.

- [ ] **Step 2: Validate the YAML is well-formed**

```bash
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/pages.yml')); print('YAML OK')"
```

Expected output: `YAML OK`

- [ ] **Step 3: Stage the workflow file**

```bash
git add .github/workflows/pages.yml
```

---

### Task 4: Commit and push

- [ ] **Step 1: Review staged changes**

```bash
git diff --staged --stat
```

Expected: 3 files changed — `.nojekyll`, `Makefile`, and `.github/workflows/pages.yml`

- [ ] **Step 2: Commit**

```bash
git commit -S -m "$(cat <<'EOF'
ci: add GitHub Pages deploy workflow for Gallery install URL

Deploys skill assets to Pages on push to main. Layout mirrors the ZIP
(SKILL.md at root) so the Gallery URL is /SKILL.md. Isolated from
release.yml; .nojekyll prevents Jekyll from stripping frontmatter.

Co-Authored-By: Trevor Gullstad <tech.gulls@gmail.com>
Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

- [ ] **Step 3: Push to remote**

> **Prerequisite:** Enable GitHub Pages before this push so the workflow has permission to deploy.
> Go to Settings > Pages > Source: **GitHub Actions** — do this before pushing.

```bash
git push origin fix/ai-edge-gallery-install
```

---

### Task 5: Enable GitHub Pages and verify deployment

**Manual steps (user must perform):**

- [ ] **Step 1: Enable GitHub Pages in repo settings**

  Go to `https://github.com/trev-gulls/play-fixai-game/settings/pages`
  - Source: **GitHub Actions**
  - Save

- [ ] **Step 2: Merge the branch to `main`**

  The workflow triggers on push to `main`. Merge via PR — the workflow will run once the branch lands on main.

- [ ] **Step 3: Watch the Actions run**

  Go to `https://github.com/trev-gulls/play-fixai-game/actions` and confirm the `Deploy to GitHub Pages` workflow completes successfully.

- [ ] **Step 4: Test the Pages URL**

```bash
curl -I https://trev-gulls.github.io/play-fixai-game/SKILL.md
```

Expected:
```
HTTP/2 200
content-type: text/markdown
```

- [ ] **Step 5: Test in Google AI Edge Gallery**

  Open Google AI Edge Gallery > Add Skill > enter:
  ```
  https://trev-gulls.github.io/play-fixai-game/SKILL.md
  ```
  Confirm it loads without a frontmatter parsing error.

  - If it loads → Step A complete, move to Step C (README/badges update)
  - If parsing error → Proceed to Step B (strip frontmatter + inline agent)

---

## Acceptance Criteria

- [ ] Pages workflow deploys successfully from `main`
- [ ] `https://trev-gulls.github.io/play-fixai-game/SKILL.md` returns HTTP 200 with `content-type: text/markdown`
- [ ] Pages layout matches the ZIP layout (SKILL.md at root, agents/ alongside)
- [ ] Pages failures do not affect `release.yml`
- [ ] Source SKILL.md is unmodified (no frontmatter stripped at this step)
