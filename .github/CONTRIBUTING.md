# Contributing to OpenChainBench Attestations (EVM)

## Conventional Commits

This project follows [Conventional Commits](https://www.conventionalcommits.org/) for semantic versioning and automated releases.

### Commit types

- `feat:` – New feature (triggers MINOR version bump)
- `fix:` – Bug fix (triggers PATCH version bump)
- `chore:` – Maintenance, no version bump
- `docs:` – Documentation only, no version bump
- `refactor:` – Code refactoring, no version bump
- `test:` – Adding or updating tests, no version bump
- `ci:` – CI/CD changes, no version bump

### Examples

```bash
git commit -m "feat: add updateProviderProfile function"
git commit -m "fix: handle validity window edge case"
git commit -m "docs: update README with integration examples"
```

## Semantic Versioning

Releases follow [SemVer](https://semver.org/): `MAJOR.MINOR.PATCH`

- **MAJOR** – Breaking changes (manual bump)
- **MINOR** – New features, backwards compatible (`feat:` commits)
- **PATCH** – Bug fixes, backwards compatible (`fix:` commits)

## Release Process

1. Merge PRs to `main` with conventional commit messages
2. CI runs tests, lint, and builds
3. On successful CI, release workflow:
   - Calculates next version based on commit types
   - Creates annotated Git tag (`vX.Y.Z`)
   - Publishes GitHub Release with auto-generated notes
   - Attaches contract artifacts (ABI JSON, bytecode)

## Manual Release

To trigger a manual release:

1. Go to Actions → Release workflow
2. Click "Run workflow"
3. Specify version bump type (major/minor/patch)
4. Workflow creates tag and release

## Code Quality

- All PRs must pass CI (build + tests + fmt check)
- Use `forge fmt` for formatting
- Add Foundry tests for new functions
- Update README for user-facing changes
