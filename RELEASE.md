# Release Guide

## Local Build

Build the skill locally for testing:

```bash
make build
```

This creates `play-fixai-game.skill` in the repository root. The file is gitignored and won't be committed.

To clean up build artifacts:

```bash
make clean
```

## Creating a Release

Releases are automated via GitHub Actions. To release a new version:

1. **Tag the commit** with semantic versioning:
   ```bash
   git tag v1.0.0
   ```

2. **Push the tag** to trigger the workflow:
   ```bash
   git push origin v1.0.0
   ```

3. **GitHub Actions** automatically:
   - Builds `play-fixai-game.skill`
   - Attaches it to the GitHub Release
   - Makes it downloadable from the Releases page

4. **Update README Install badge** (manual):
   - Edit `README.md`
   - Change the Install badge link from `vX.X.X` to the new version number
   - Example: `releases/download/v1.0.1/play-fixai-game.skill`

## Versioning

Use [semantic versioning](https://semver.org/):

- **v1.0.0** — First major release
- **v1.0.1** — Patch (bug fix, no API changes)
- **v1.1.0** — Minor (new feature, backward compatible)
- **v2.0.0** — Major (breaking changes)

## Installation for End Users

Users download from [Releases](../../releases) and install via:

**Claude AI Desktop** → Settings → Skills → Install from file → select `play-fixai-game.skill`

## Troubleshooting

**Build fails locally?**
- Ensure `zip` is installed: `which zip`
- Check file permissions: `ls -la skills/play-fixai-game/`

**GitHub Actions workflow doesn't trigger?**
- Verify tag format: must match `v*` (e.g., `v1.0.0`)
- Check workflow status: GitHub repo → Actions tab
