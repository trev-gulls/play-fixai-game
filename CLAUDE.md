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

## Development

All changes go through feature branches and PRs. Direct commits to `main` are blocked by git hooks.
