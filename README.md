# play-fixai-game

![Model](https://img.shields.io/badge/model-Claude%20Haiku-green)
![License](https://img.shields.io/badge/license-CC%20BY--NC--ND%204.0-lightgrey)
[![Game](https://img.shields.io/badge/game-fixai.dev-blue)](https://fixai.dev)

A Claude skill for playing [Fix AI](https://fixai.dev) — a browser game where
you contest automated AI decisions using real consumer protection law.

## What this is

[Fix AI](https://fixai.dev) presents scenarios where an AI system has wrongly
denied your flight refund, closed your bank account, rejected your job
application, or penalized your ride-share score. You have a limited number of
messages to reverse the decision by presenting a compeling legal argument.

This skill helps you do that. It tracks game state, researches applicable
statutes for the appropriate jurisdiction, and dispatches a focused drafting 
agent to write precise legal arguments, with visible research and links to 
authoritative sources.

## How it works

The skill is split into two components:

- **Router** (`skills/play-fixai-game/SKILL.md`) — tracks confidence state
  (`DENIED → UNDER REVIEW → RECONSIDERING → APPROVED`), manages turn count,
  and decides when to draft, ask for player input, or escalate to a more
  capable model
- **Drafter** (`skills/play-fixai-game/agents/drafter.md`) — researches applicable law for the
  jurisdiction and harm type, produces a visible research section with links,
  then drafts the legal argument in a copyable code fence

## Installation

Download `play-fixai-game.skill` from
[Releases](../../releases) and install it in Claude.ai via
Settings → Skills → Install from file.

## Usage

1. Open a case on [fixai.dev](https://fixai.dev)
2. Paste the scenario, automated denial, and current confidence state into Claude
3. The skill drafts your argument — copy it from the code fence and paste it
   into the game
4. Report the new confidence state after each turn

The skill handles the full game loop:
- **`CONFIDENCE: DENIED`** — drafts an opening argument
- **`CONFIDENCE: UNDER REVIEW`** — asks whether to push or escalate
- **`CONFIDENCE: RECONSIDERING`** — drafts a targeted rebuttal
- **`CONFIDENCE: APPROVED`** or **`DECISION REVERSED`** — confirms the win
- Stuck? The skill produces a full escalation handoff package for a more
  capable model

## Jurisdictions covered

The drafter researches applicable law for any jurisdiction the game presents,
including 🇺🇸 US, 🇬🇧 UK, 🇪🇺 EU, 🇦🇺 AU, 🇮🇳 IN, and 🌐 International cases.
It uses web search to find and verify statutes.

## Disclaimer

This skill is designed for use with Fix AI, an educational game. Legal
arguments are simplified for gameplay and **do not constitute legal advice**.
Always consult a qualified legal professional for your actual situation. See
[NOTICE](./NOTICE.md) for full disclaimer.

## License

Copyright (c) 2026 Trevor Gullstad ([@tgulls](https://github.com/trev-gulls))

Licensed under
[CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/) —
you may share this skill unchanged for personal, non-commercial use only.
No derivatives. No commercial use. See [LICENSE](./LICENSE.md) for
full terms.
