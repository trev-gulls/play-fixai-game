# Bugfix: Enable skill install in Google AI Edge Gallery

**Date:** 2026-04-07
**Priority:** Medium
**Branch:** `fix/ai-edge-gallery-install`
**Triage:** `docs/ops/2026-04-07-ai-edge-gallery-install-debug.md`

## Problem

The play-fixai-game skill cannot be installed in Google AI Edge Gallery via
URL. The app rejects SKILL.md with a frontmatter parsing error.

## Goal

Users can install the skill in both Claude AI Desktop (via `.skill` ZIP) and
Google AI Edge Gallery (via URL) from the same repository.

## Steps

### A) Deploy all assets to GitHub Pages from main

GitHub Pages serves files with correct MIME types, which Gallery requires.
Deploy from `main` to stay consistent with the Claude release workflow.

1. **Enable GitHub Pages** on the repo
   - Go to Settings > Pages
   - Source: GitHub Actions (deploy from `main`)

2. **Add `.nojekyll` to repo root**
   - Prevents Jekyll from stripping YAML frontmatter during Pages build

3. **Create a new GitHub Actions workflow** (`pages.yml`)
   - Separate from `release.yml` so failures are isolated
   - Triggered on push to `main` (or on tagged release if preferred)
   - Deploys all skill assets including supporting content:
     ```
     skills/
       play-fixai-game/
         SKILL.md
         agents/
           argument-drafter.md
     README.md
     LICENSE.md
     NOTICE.md
     ```
   - Could share a packaging step with `release.yml` if the distributed
     filesystem structures turn out to be identical

4. **Test the Gallery URL**
   - URL format: `https://trev-gulls.github.io/play-fixai-game/skills/play-fixai-game/SKILL.md`
   - Enter in Gallery "Add Skill" dialog
   - Verify skill loads without errors

### B) Modify frontmatter and inline agent for Gallery compatibility

If deployment alone does not resolve the parsing error, adjust the
SKILL.md to match Gallery's expected format.

1. **Create a Gallery-specific SKILL.md** during deploy
   - Strip `version` and `author` fields (not recognized by Gallery)
   - Keep only `name`, `description`, and optionally `metadata`
   - Add `metadata.homepage` pointing to the GitHub repo
   - **Inline the drafter agent** content directly into SKILL.md body
     (Gallery likely cannot follow `agents/*.md` references)

   Gallery-compatible frontmatter:
   ```yaml
   ---
   name: play-fixai-game
   description: >
     Help the user play Fix AI (fixai.dev), a browser game where players
     contest automated AI decisions using real consumer protection law.
   metadata:
     homepage: https://github.com/trev-gulls/play-fixai-game
   ---
   ```

2. **Update the Makefile** with a `gallery` target
   - Generates a Gallery-compatible SKILL.md (strips fields, inlines agent)
   - Copies all assets to the deploy directory
   - Adds `.nojekyll`

3. **Keep the source SKILL.md unchanged**
   - The Claude build (`make build`) continues using the full frontmatter
     with separate agent file
   - The Gallery deploy generates an inlined, stripped version
   - Single source of truth, two distribution formats

4. **Test in Gallery again**
   - Verify the stripped/inlined SKILL.md resolves the parsing error
   - Confirm the skill loads and functions correctly

### C) Update README and badges

1. **Document both install methods** near the top of README
   - Claude AI Desktop: download `.skill` from Releases
   - Google AI Edge Gallery: add skill via Pages URL
2. **Add Gallery model badge** alongside existing Claude Haiku badge
   - Tag both recommended models in badges

## Acceptance Criteria

- [ ] Skill installs successfully in Google AI Edge Gallery via URL
- [ ] Skill continues to install in Claude AI Desktop via `.skill` ZIP
- [ ] Both install methods documented near top of README
- [ ] Both recommended models tagged in badges
- [ ] Build/deploy process documented in RELEASE.md
- [ ] No manual frontmatter editing required — build handles both formats
- [ ] Pages workflow isolated from release workflow

## Notes

- The Gallery also supports JavaScript skills (`scripts/index.html`) and
  intent-based skills (`run_intent` tool). This skill is text-only.
- Inlining the drafter agent is the most likely approach to work in Gallery.
  Could also try keeping it as a separate asset, but inline is safer.
- If the distributed structures are identical between Claude and Gallery,
  the packaging step could be shared between workflows.
