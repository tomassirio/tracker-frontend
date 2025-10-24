# Version Management

This document describes the version management strategy used in the tracker-frontend project.

## Version Format

The project follows [Semantic Versioning](https://semver.org/) with a Flutter-specific build number extension:

```
MAJOR.MINOR.PATCH[-SNAPSHOT]+BUILD
```

- **MAJOR**: Incremented for incompatible API changes
- **MINOR**: Incremented for backward-compatible functionality additions
- **PATCH**: Incremented for backward-compatible bug fixes
- **-SNAPSHOT**: Indicates a development version (not a release)
- **+BUILD**: Flutter build number, used for app store versioning

### Examples

- `1.0.0-SNAPSHOT+1`: Development version, first build
- `1.0.0+1`: Release version 1.0.0, build 1
- `1.0.1-SNAPSHOT+1`: Next development iteration after releasing 1.0.0

## Workflow Behavior

### Feature Branch Development

When working on a feature branch:
1. The version in `pubspec.yaml` remains in `-SNAPSHOT` state
2. No version changes are made automatically
3. Manual version increments can be done if needed for testing

### Merge to Master (Release)

When a PR is merged to master, the workflow automatically:

1. **Creates Release Version**
   - Removes `-SNAPSHOT` suffix from current version
   - Example: `1.0.1-SNAPSHOT+1` → `1.0.1+1`

2. **Creates Git Tag**
   - Tags the release commit with the base version
   - Example: Creates tag `v1.0.1`
   - Fails if the tag already exists (indicates version wasn't incremented properly)

3. **Builds and Tests**
   - Runs full test suite
   - Updates README badges with version and coverage
   - Builds the web application

4. **Creates GitHub Release**
   - Creates a release with the tag
   - Includes release notes from commits since last release
   - Attaches web application archive

5. **Prepares Next Development Version**
   - **Increments patch version** (this is the key fix!)
   - Resets build number to 1
   - Adds `-SNAPSHOT` suffix
   - Example: `1.0.1+1` → `1.0.2-SNAPSHOT+1`

6. **Pushes Changes**
   - Commits the new development version to master
   - Pushes the commit and the new tag

## Version Increment Rules

### Automatic (on merge to master)
- **PATCH version**: Automatically incremented after each release
- **BUILD number**: Reset to 1 for each new version

### Manual (when needed)
- **MAJOR version**: Increment manually when making breaking changes
- **MINOR version**: Increment manually when adding new features
- Both require updating `pubspec.yaml` directly before merging

## Example Release Cycle

```
Development    → Release      → Next Development
1.0.0-SNAPSHOT+1 → 1.0.0+1 (v1.0.0) → 1.0.1-SNAPSHOT+1
1.0.1-SNAPSHOT+1 → 1.0.1+1 (v1.0.1) → 1.0.2-SNAPSHOT+1
1.0.2-SNAPSHOT+1 → 1.0.2+1 (v1.0.2) → 1.0.3-SNAPSHOT+1
```

If you need to release a new minor version:
```
# Manually update pubspec.yaml to 1.1.0-SNAPSHOT+1
1.1.0-SNAPSHOT+1 → 1.1.0+1 (v1.1.0) → 1.1.1-SNAPSHOT+1
```

If you need to release a new major version:
```
# Manually update pubspec.yaml to 2.0.0-SNAPSHOT+1
2.0.0-SNAPSHOT+1 → 2.0.0+1 (v2.0.0) → 2.0.1-SNAPSHOT+1
```

## Troubleshooting

### Tag Already Exists Error

If you see an error like:
```
fatal: tag 'v1.0.0' already exists
```

This means:
1. The version in `pubspec.yaml` wasn't properly incremented
2. You're trying to create a release with a version that was already released

**Solution**: Manually update `pubspec.yaml` to the next appropriate version:
- For a patch fix: Increment patch (e.g., `1.0.0` → `1.0.1`)
- For a new feature: Increment minor (e.g., `1.0.0` → `1.1.0`)
- For breaking changes: Increment major (e.g., `1.0.0` → `2.0.0`)

### Version Out of Sync

If the version seems out of sync with tags:

1. Check existing tags:
   ```bash
   git tag -l
   ```

2. Find the latest tag:
   ```bash
   git describe --tags --abbrev=0
   ```

3. Update `pubspec.yaml` to the next version after the latest tag

## Best Practices

1. **Don't manually edit version on feature branches** - Let the workflow handle it
2. **Only increment MAJOR/MINOR manually** - PATCH is handled automatically
3. **Always use -SNAPSHOT suffix** during development
4. **Check existing tags** before manually incrementing version
5. **Follow semantic versioning** - Breaking changes = MAJOR, Features = MINOR, Fixes = PATCH

## References

- [Semantic Versioning](https://semver.org/)
- [Flutter Versioning Documentation](https://docs.flutter.dev/deployment/android#versioning-the-app)
- [GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github)
