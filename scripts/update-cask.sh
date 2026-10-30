#!/usr/bin/env bash
# Rewrite version and both sha256 values in the clipy-recorder cask from the
# public releases API, so the tap tracks the current stable Mac release.
#
# Usage: update-cask.sh <path/to/clipy-recorder.rb> [version]
#
# With no version, the current stable version is read from the releases API.
# The sha256 values always come from the API rows for that version, and the
# script refuses to write when the arm and Intel rows disagree on version or
# a value is missing. Prints "unchanged" or "updated <old> -> <new>".
# Needs curl and jq. Runs on Linux and macOS.
set -euo pipefail

CASK="${1:?usage: update-cask.sh <cask.rb> [version]}"
WANT="${2:-}"
API="${CLIPY_RELEASES_API:-https://clipy.online/api/releases/latest}"
# clipy.online refuses some default library User-Agents; send our own.
UA="clipy-homebrew-tap-updater (+https://clipy.online/)"

fetch() {
  curl --fail --silent --show-error --retry 3 -A "$UA" \
    "$API?channel=stable&platform=$1"
}

ARM_JSON="$(fetch darwin-aarch64)"
INTEL_JSON="$(fetch darwin-x86_64)"

ARM_VERSION="$(jq -r '.version // empty' <<<"$ARM_JSON")"
INTEL_VERSION="$(jq -r '.version // empty' <<<"$INTEL_JSON")"
ARM_SHA="$(jq -r '.dmg_sha256 // empty' <<<"$ARM_JSON")"
INTEL_SHA="$(jq -r '.dmg_sha256 // empty' <<<"$INTEL_JSON")"

if [ -z "$ARM_VERSION" ] || [ "$ARM_VERSION" != "$INTEL_VERSION" ]; then
  echo "error: arm ($ARM_VERSION) and intel ($INTEL_VERSION) stable versions differ or are missing" >&2
  exit 1
fi
if [ -n "$WANT" ] && [ "$WANT" != "$ARM_VERSION" ]; then
  echo "error: requested $WANT but the releases API reports $ARM_VERSION" >&2
  exit 1
fi
for sha in "$ARM_SHA" "$INTEL_SHA"; do
  if ! [[ "$sha" =~ ^[0-9a-f]{64}$ ]]; then
    echo "error: bad sha256 from the releases API: '$sha'" >&2
    exit 1
  fi
done

OLD_VERSION="$(sed -n 's/^  version "\(.*\)"$/\1/p' "$CASK")"
if [ -z "$OLD_VERSION" ]; then
  echo "error: no version line found in $CASK" >&2
  exit 1
fi

TMP="$(mktemp)"
sed \
  -e "s/^  version \".*\"$/  version \"$ARM_VERSION\"/" \
  -e "s/^  sha256 arm:   \"[0-9a-f]*\",$/  sha256 arm:   \"$ARM_SHA\",/" \
  -e "s/^         intel: \"[0-9a-f]*\"$/         intel: \"$INTEL_SHA\"/" \
  "$CASK" >"$TMP"

# Every substitution must have landed, or the file layout changed under us.
grep -q "^  version \"$ARM_VERSION\"$" "$TMP" &&
  grep -q "\"$ARM_SHA\"" "$TMP" &&
  grep -q "\"$INTEL_SHA\"" "$TMP" || {
  rm -f "$TMP"
  echo "error: could not rewrite $CASK; check its version and sha256 lines" >&2
  exit 1
}

if cmp -s "$TMP" "$CASK"; then
  rm -f "$TMP"
  echo "unchanged $OLD_VERSION"
else
  cat "$TMP" >"$CASK"
  rm -f "$TMP"
  echo "updated $OLD_VERSION -> $ARM_VERSION"
fi
