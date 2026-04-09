---
status: pending
created: 2026-04-09
updated: 2026-04-09
blocked-by: []
---

# Replace naive `---` split with a real YAML frontmatter parser in google-ai-edge/gallery

## Goal

`convertSkillMdToProto` in `SkillManagerViewModel.kt` splits SKILL.md content
on the literal string `"---"` and parses header fields line-by-line. This
approach silently misparses any SKILL.md that uses standard YAML features
beyond simple `key: value` on a single line. The goal is to replace it with a
proper YAML frontmatter parser, ideally using a Kotlin/JVM library already
available in the project or a minimal well-maintained dependency.

Discovered while investigating why
`https://raw.githubusercontent.com/trev-gulls/play-fixai-game/refs/heads/main/skills/play-fixai-game/SKILL.md`
fails to load — its `description` uses YAML folded block scalar (`>`), which
the current parser silently reduces to `">"`.

## Acceptance Criteria

- [ ] YAML folded block scalar (`description: >`) is parsed correctly
- [ ] YAML literal block scalar (`description: |`) is parsed correctly
- [ ] Inline multi-line strings with `\n` escapes are parsed correctly
- [ ] `---` appearing inside instruction body content is still handled correctly
- [ ] `---` appearing inside a header field value no longer silently truncates the field
- [ ] All existing built-in skills continue to parse correctly
- [ ] Unit tests in `SkillManagerViewModelTest` cover the new YAML field types

## Notes

- Upstream repo: https://github.com/google-ai-edge/gallery
- Affected file: `Android/src/app/src/main/java/com/google/ai/edge/gallery/customtasks/agentchat/SkillManagerViewModel.kt`
- Related PR: https://github.com/google-ai-edge/gallery/pull/642 (fixes URL resolution but not the parser)
- Related issue: https://github.com/google-ai-edge/gallery/issues/619
- Candidate library: [snakeyaml-engine](https://bitbucket.org/snakeyaml/snakeyaml-engine) (YAML 1.2, Android-compatible)
- The parser only needs to handle the frontmatter block (between the first two `---` markers) — the instructions body is raw text and does not need YAML parsing
