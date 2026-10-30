# Clipy screen recorder: Homebrew tap

Install the Clipy screen recorder for Mac with Homebrew:

```sh
brew install --cask clipy-recorder/tap/clipy-recorder
```

Clipy records your screen, camera and audio on Mac, Windows and Chrome, and gives you a share link with a transcript and summary. Viewers do not need to sign up to watch, and AI coding agents such as Claude Code, Codex and Cursor can read the recording. Learn more at [clipy.online](https://clipy.online/).

The cask is named `clipy-recorder` because the `clipy` cask in Homebrew is an unrelated clipboard manager. The two apps both install `Clipy.app`, so they cannot be installed side by side.

## How this tap stays current

`.github/workflows/bump.yml` checks Clipy's releases API every six hours and commits a new version and sha256 values when a new stable Mac release ships. It also verifies the downloaded DMGs against those hashes before committing. Apple Silicon and Intel are both supported.

## Uninstall

```sh
brew uninstall --cask clipy-recorder
# or, to also remove settings, caches and local recordings:
brew uninstall --cask --zap clipy-recorder
```

Clipy adds itself to Login Items on first launch. If it stays listed after uninstalling, remove it in System Settings > General > Login Items.
