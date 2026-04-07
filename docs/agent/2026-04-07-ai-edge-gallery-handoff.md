# Handoff: AI Edge Gallery Install Fix

**Date:** 2026-04-07
**From:** Opus
**To:** Sonnet
**Branch:** `fix/ai-edge-gallery-install`
**PR:** https://github.com/trev-gulls/play-fixai-game/pull/2

## Context

This repo distributes a Claude Code skill (`play-fixai-game`) that helps
users play [Fix AI](https://fixai.dev), a browser game about contesting
automated AI decisions with legal arguments.

The skill currently ships as a `.skill` ZIP for Claude AI Desktop. The user
wants to also support installation via Google AI Edge Gallery, which uses a
different format (URL to a hosted SKILL.md served with correct MIME types).

## What's Done

1. **Triage complete** — Root causes identified and documented
   - `docs/ops/2026-04-07-ai-edge-gallery-install-debug.md`

2. **Work item written and reviewed** — PR #2 has owner feedback incorporated
   - `docs/work/backlog/2026-04-07-ai-edge-gallery-install-bugfix.md`

3. **Branch created** — `fix/ai-edge-gallery-install` with triage + work item

4. **PR #2 open** — Awaiting final approval before implementation begins

## What Needs to Happen

Follow the steps in the bugfix work item. In priority order:

### Step A — Deploy to GitHub Pages from main
- Create `pages.yml` workflow (separate from `release.yml`)
- Add `.nojekyll` to repo root
- Deploy all assets (skills/, README, LICENSE, NOTICE)
- Test URL in Gallery: `https://trev-gulls.github.io/play-fixai-game/skills/play-fixai-game/SKILL.md`

### Step B — Frontmatter + inline agent (if Step A alone doesn't fix it)
- Strip `version` and `author` from SKILL.md for Gallery deploy
- Keep only `name`, `description`, `metadata` (Gallery-recognized fields)
- Inline `agents/argument-drafter.md` content into SKILL.md body
- Add `make gallery` target to Makefile for local testing
- Source SKILL.md stays unchanged — build generates Gallery version

### Step C — Update README and badges
- Document both install methods near top of README
- Add Gallery model badge alongside Claude Haiku badge

## Key Decisions (from PR review)

- **Deploy from `main`**, not a `gh-pages` branch
- **Separate workflow** (`pages.yml`) — isolate failures from `release.yml`
- **Include all content** in Pages deploy (README, LICENSE, NOTICE)
- **Inline the drafter agent** as primary approach (Gallery likely can't
  follow `agents/*.md` references)
- Could share packaging step between workflows if structures are identical

## Repo Structure

```
.
├── .github/workflows/
│   └── release.yml          # Builds .skill ZIP on v* tags
├── skills/
│   └── play-fixai-game/
│       ├── SKILL.md          # Main skill (Claude frontmatter)
│       └── agents/
│           └── argument-drafter.md
├── Makefile                  # `make build` creates .skill ZIP
├── CLAUDE.md                 # Release process docs
├── RELEASE.md                # Build/release guide
├── README.md                 # User-facing docs
├── LICENSE.md                # CC BY-NC-ND 4.0
└── NOTICE.md                 # Disclaimer
```

## Important Conventions

- **Git workflow:** Feature branches + PRs. Never push directly to main.
- **File operations:** Use `git mv` for moves/renames, never write + delete.
- **Commits:** Signed (`-S` flag). User will squash on GitHub if needed.
- **Docs:** Follow docile conventions (`docs/{type}/{date}-{name}-{suffix}.md`)
- **Build:** `make build` for Claude ZIP, `make clean` to reset
- **Release:** Tag with `v*`, move `latest` tag, GitHub Actions builds

## Watch Out For

- The user's SSH key for `tg-agent` has push access, but GPG signing
  requires the user's own key — they may want to amend commits
- The user prefers to review before pushing to main
- The `latest` tag needs to be moved manually after each release
  (documented in CLAUDE.md)
- Gallery's error messages can be misleading — "Expected at least two
  '---' sections" may actually mean "unknown frontmatter fields"
