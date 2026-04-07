# Release Guide

## Local Build

Build the skill locally for testing:

```bash
make build   # creates play-fixai-game.skill
make site    # stages assets to _site/ for Pages testing
make test    # verifies build and site manifests
make clean   # removes all build artifacts (ZIP, build/, _site/)
```

`make build` creates `play-fixai-game.skill` in the repository root.
`make site` stages the same files to `_site/` in the flat layout served by GitHub Pages.
Both outputs are gitignored and won't be committed.

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

## GitHub Pages

Skill assets are also deployed to GitHub Pages automatically on every push to `main`
via `.github/workflows/pages.yml`. This enables installation via URL in Google AI Edge Gallery.

Pages deploy URL: `https://trev-gulls.github.io/play-fixai-game/SKILL.md`

No manual action required — merging to `main` triggers the deploy.

## Versioning

Use [semantic versioning](https://semver.org/):

- **v1.0.0** — First major release
- **v1.0.1** — Patch (bug fix, no API changes)
- **v1.1.0** — Minor (new feature, backward compatible)
- **v2.0.0** — Major (breaking changes)

## Installation for End Users

**Claude AI Desktop** → Settings → Skills → Install from file → select `play-fixai-game.skill`

Download from [Releases](../../releases).

**Google AI Edge Gallery** → Add Skill → enter URL:
`https://trev-gulls.github.io/play-fixai-game/SKILL.md`

## Troubleshooting

**Build fails locally?**
- Ensure `zip` is installed: `which zip`
- Check file permissions: `ls -la skills/play-fixai-game/`

**GitHub Actions release workflow doesn't trigger?**
- Verify tag format: must match `v*` (e.g., `v1.0.0`)
- Check workflow status: GitHub repo → Actions tab

**GitHub Pages deploy fails?**
- Confirm Pages is enabled: Settings → Pages → Source: GitHub Actions
- Check the `Deploy to GitHub Pages` workflow in the Actions tab
