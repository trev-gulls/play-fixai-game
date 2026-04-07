# Play FixAI Game — Project Guidelines

## Release Process

### Creating a Release

1. **Create version tag** (semantic versioning):
   ```bash
   git tag v1.0.1
   git push origin v1.0.1
   ```

2. **Update `latest` tag** to point to new version:
   ```bash
   git tag -d latest
   git push origin --delete latest
   git tag latest
   git push origin latest
   ```

This ensures:
- GitHub Actions builds and creates release automatically
- Download link `https://github.com/trev-gulls/play-fixai-game/releases/download/latest/play-fixai-game.skill` always points to latest version
- No manual release management needed

### Workflow

- Push version tag (e.g., `v1.0.1`) → GitHub Actions builds automatically
- Move `latest` tag to same commit → users always download newest skill

## README Badges

The README contains badges that track project status:

| Badge | Updates | Notes |
|-------|---------|-------|
| **Build** | Auto | GitHub Actions workflow status — updates automatically |
| **Install** | Manual | Points to specific release — must bump version in README on new release (change `v1.0.0` to `v1.0.1`, etc.) |
| **Model**, **License**, **Play** | Static | No updates needed |

When releasing a new version, update the Install badge link:
```markdown
[![Install](https://img.shields.io/github/v/release/trev-gulls/play-fixai-game?color=0969da&label=install)](https://github.com/trev-gulls/play-fixai-game/releases/download/vX.X.X/play-fixai-game.skill)
```

## Build Targets

| Command | Output |
|---------|--------|
| `make build` | `play-fixai-game.skill` ZIP for Claude AI Desktop |
| `make site` | `_site/` flat directory for GitHub Pages |
| `make test` | Verifies exact file manifests for both outputs |
| `make clean` | Removes all build artifacts (ZIP, `build/`, `_site/`) |

## GitHub Pages

Skill assets deploy to Pages automatically on push to `main` via `pages.yml`.
Gallery install URL: `https://trev-gulls.github.io/play-fixai-game/SKILL.md`

Pages must be enabled in repo settings (Settings → Pages → Source: GitHub Actions).

## Development

All changes go through feature branches and PRs. Direct commits to `main` are blocked by git hooks.
