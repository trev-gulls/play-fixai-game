---
date: 2026-04-09
status: resolved-partial
related-issue: https://github.com/google-ai-edge/gallery/issues/619
related-pr: https://github.com/google-ai-edge/gallery/pull/642
related-task: docs/work/backlog/2026-04-09-yaml-frontmatter-parsing-bug.md
---

# Skill URL Loading Failure — Debug Session

## Symptom

Installing a skill from a URL in Google AI Edge Gallery fails with:

> `Invalid format: Expected at least two '---' sections.`

Reported in [issue #619](https://github.com/google-ai-edge/gallery/issues/619) from
an iPhone 15 Pro (iOS 16.3.1). The same failure reproduced on Mac. Multiple URL
formats were tested and all failed.

## Root Cause (URL Layer)

`SkillManagerViewModel.kt` normalized the input URL by only stripping a trailing
`/SKILL.md` or `/`, then re-appending `/SKILL.md`. It did not convert GitHub web
UI URLs to raw content URLs.

A URL like:

```
https://github.com/owner/repo/tree/main/skills/foo
```

Was left unchanged and fetched as-is, returning a GitHub HTML page instead of
the raw file content. The app had no content-type or HTML body check, so the HTML
was passed directly into the SKILL.md parser.

The parser (`convertSkillMdToProto`) splits on `"---"` and requires at least three
parts. GitHub HTML pages contain `---` characters (in `<hr>` elements and
elsewhere), so the count check sometimes passed, silently dumping HTML fragments
into the `name` and `description` fields. When it failed the count check, the
error `"Expected at least two '---' sections."` was thrown.

## Error Path (Code Trace)

```
validateSkillFromUrl(url)
  → normalize: strip /SKILL.md suffix, re-append /SKILL.md
  → URL(skillMdUrl).openConnection() → HTML page returned (no content-type check)
  → InputStreamReader(...).readText() → mdContent = full GitHub HTML
  → convertSkillMdToProto(mdContent)
      → mdContent.split("---") → parts.size < 3
      → errors.add("Invalid format: Expected at least two '---' sections.")
```

## PR #642 Fix (Android Only)

[PR #642](https://github.com/google-ai-edge/gallery/pull/642) addresses the URL
layer on Android with two new guards:

1. **`convertGithubSkillUrlToRawBase(url)`** — converts `github.com` tree/blob URLs
   and `raw.githubusercontent.com` URLs into a normalized base pointing at the raw
   skill folder.

2. **`isLikelyHtmlResponse(contentType, body)`** — detects HTML responses by
   checking the `Content-Type` header and body prefix (`<!doctype html`, `<html`),
   rejecting them before the content reaches the parser.

3. **`hasUnsupportedJsSkillHost(skillUrl)`** — blocks skills using `run_js` from
   being hosted on GitHub/raw.githubusercontent.com (they require a web server such
   as GitHub Pages to serve JS assets).

**Scope gap:** The fix is Android-only. Issue #619 was filed from iOS. No iOS
counterpart exists in this repo (the iOS source is maintained in a private Google
repo). A code review comment was left on the PR noting this:
https://github.com/google-ai-edge/gallery/pull/642#issuecomment-4215482206

## Second Issue: YAML Block Scalar Parsing (Unrelated to PR #642)

While tracing the error, a second independent bug was found in `convertSkillMdToProto`
itself. The parser is not a real YAML parser — it processes headers line-by-line:

```kotlin
trimmedLine.startsWith("description:") ->
    description = trimmedLine.substringAfter("description:").trim()
```

Any YAML multi-line value syntax is silently mishandled. For example, the
play-fixai-game SKILL.md uses a folded block scalar:

```yaml
description: >
  Help the user play Fix AI (fixai.dev), a browser game...
  ...multi-line content...
```

The parser captures only the `>` character as the description value. This passes
the `isNullOrEmpty()` validation check (non-empty), so no error is thrown and the
skill installs — but with `description = ">"`.

The raw URL for the play-fixai-game skill returns HTTP 200 with `text/plain`
content, confirming the network layer is not the issue for this skill:

```
curl -sI https://raw.githubusercontent.com/trev-gulls/play-fixai-game/refs/heads/main/skills/play-fixai-game/SKILL.md
→ HTTP/2 200, content-type: text/plain; charset=utf-8
```

A backlog task has been filed:
[`docs/work/backlog/2026-04-09-yaml-frontmatter-parsing-bug.md`](../work/backlog/2026-04-09-yaml-frontmatter-parsing-bug.md)

## convertSkillMdToProto Call Sites

The parser is called from four distinct code paths in `SkillManagerViewModel.kt`,
all of which share the same YAML parsing limitation:

| Call site | Line | Source | Purpose |
|-----------|------|--------|---------|
| 1 | ~181 | `assets/skills/<dir>/SKILL.md` | Load packaged built-in skills on startup |
| 2 | ~313 | Remote URL fetch | Install skill from URL (addressed by PR #642) |
| 3 | ~391 | Content resolver (device storage) | Check if local skill duplicates a built-in |
| 4 | ~451 | Content resolver (device storage) | Install skill from local directory |

Agent markdown files (e.g. `agents/argument-drafter.md`) are never passed to the
parser — they are read at runtime by the LLM via the skill's instructions field,
not by the app.

## Parser Fragility Notes

The `split("---")` approach has the following known limitations:

- `---` inside a **header field value** silently truncates the field (only `parts[1]`
  is read as the header; anything after the next `---` is treated as instructions)
- `---` inside the **instructions body** is safe — `parts.drop(2).joinToString("---")`
  correctly reassembles it
- `parts[0]` (content before the opening `---`) is silently discarded — leading
  garbage or a BOM would not cause an error
- YAML block scalars (`>`, `|`), multi-line strings, anchors, and aliases are all
  unsupported

## Recommended Fix

Replace the line-by-line header parser with a proper YAML library scoped to the
frontmatter block only (i.e. `parts[1]` in the current split, or the equivalent
region extracted by a proper frontmatter splitter). The instructions body remains
raw text and does not need YAML parsing.

Candidate: [snakeyaml-engine](https://bitbucket.org/snakeyaml/snakeyaml-engine)
(YAML 1.2, Android-compatible).
