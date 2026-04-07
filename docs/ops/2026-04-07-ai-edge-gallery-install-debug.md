# AI Edge Gallery Install — Debug Triage

**Date:** 2026-04-07
**Status:** Triaged
**Branch:** `fix/ai-edge-gallery-install`

## Symptom

Attempting to install `play-fixai-game` via URL in Google AI Edge Gallery's
"Add Skill" dialog produces:

> Error parsing SKILL.md: Invalid format: Expected at least two '---' sections.

Tested URLs:
- `https://github.com/trev-gulls/play-fixai-game/blob/main/skills/play-fixai-game/SKILL.md`
- `https://raw.githubusercontent.com/trev-gulls/play-fixai-game/main/skills/play-fixai-game/SKILL.md`

Both produce the same error. The SKILL.md file has valid YAML frontmatter
with two `---` delimiters (verified via hex dump — no BOM, no trailing whitespace).

## Root Cause Analysis

Two independent issues identified:

### 1. Non-standard frontmatter fields

Google AI Edge Gallery recognizes only these frontmatter fields:
- `name` (required)
- `description` (required)
- `metadata` block (optional): `homepage`, `require-secret`, `require-secret-description`

Our SKILL.md contains `version` and `author` fields that are not part of the
Gallery spec. The parser may reject or choke on unknown fields, producing the
misleading "Expected at least two '---' sections" error.

**Evidence:** All Gallery built-in and featured skills use only the fields
above. No existing Gallery skill includes `version` or `author`.

### 2. Incorrect MIME type from GitHub URLs

Gallery expects skills served via a web host with correct MIME types.
GitHub raw URLs (`raw.githubusercontent.com`) serve with
`text/plain; charset=utf-8`, and blob URLs return HTML. The Gallery parser
may fail to fetch or parse content served this way.

**Evidence:** Gallery documentation and wiki reference GitHub Pages as the
supported hosting method. The `.nojekyll` file is mentioned as required for
GitHub Pages deployments.

## Gallery Skill Format Reference

Source: [google-ai-edge/gallery](https://github.com/google-ai-edge/gallery/tree/main/skills)

Canonical minimal skill:
```yaml
---
name: send-email
description: Send an email.
---
```

Skill with metadata:
```yaml
---
name: mood-music
description: A skill to suggest or play music based on the user's mood...
metadata:
  require-secret: true
  require-secret-description: you can get api key from https://www.loudly.com/developers/apps
  homepage: https://github.com/google-ai-edge/gallery/tree/main/skills/featured/mood-music
---
```

Skill types:
- **Text-only:** Just `SKILL.md`
- **JavaScript:** `SKILL.md` + `scripts/index.html` (exposes `ai_edge_gallery_get_result`)
- **Native/Intent:** `SKILL.md` instructs LLM to call `run_intent` tool

## Platform Differences

| Concern | Claude AI Desktop | Google AI Edge Gallery |
|---------|-------------------|----------------------|
| Install format | `.skill` ZIP archive | URL to hosted `SKILL.md` |
| Frontmatter | Flexible (custom fields OK) | Strict (`name`, `description`, `metadata` only) |
| Hosting | GitHub Releases | GitHub Pages (correct MIME types) |
| Distribution | Download + install from file | Enter URL in app |

## Conclusion

The skill needs a **dual-distribution strategy**:
1. **Claude:** Continue building `.skill` ZIP via `make build` and GitHub Releases
2. **Gallery:** Deploy skill assets to GitHub Pages with Gallery-compatible frontmatter

See work item: `docs/work/backlog/2026-04-07-ai-edge-gallery-install-bugfix.md`
