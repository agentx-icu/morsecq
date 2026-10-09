#!/usr/bin/env bash
# Validate the app version and, when present, the release tag.
#
# Usage:
#   tool/ci/check_version_tag.sh [vX.Y.Z]
#
# In GitHub Actions the tag is read from GITHUB_REF_NAME for tag refs. A
# positional tag is useful for local/preflight checks (and is what the release
# asset gate passes explicitly).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tool/ci/common.sh
source "$SCRIPT_DIR/common.sh"

if [[ $# -eq 1 && ( "$1" == "--help" || "$1" == "-h" ) ]]; then
  sed -n '2,9p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit 0
fi
[[ $# -le 1 ]] || ci_die "Usage: check_version_tag.sh [vX.Y.Z]"

APP_SPEC="$(ci_repo_root)/apps/morsecq/pubspec.yaml"
[[ -f "$APP_SPEC" ]] || ci_die "Missing app pubspec: $APP_SPEC"

version_line="$(sed -nE 's/^version:[[:space:]]*([^[:space:]]+)[[:space:]]*$/\1/p' "$APP_SPEC" | head -n 1)"
[[ "$version_line" =~ ^([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)$ ]] ||
  ci_die "app version must be X.Y.Z+build in $APP_SPEC (found: ${version_line:-<missing>})"
APP_VERSION="${BASH_REMATCH[1]}"
APP_BUILD="${BASH_REMATCH[2]}"
EXPECTED_TAG="v$APP_VERSION"

TAG="${1:-}"
if [[ -z "$TAG" && "${GITHUB_REF_TYPE:-}" == "tag" ]]; then
  TAG="${GITHUB_REF_NAME:-}"
fi
# A caller that only provides GITHUB_REF_NAME (for example a local CI replay)
# still gets the same safety check when it looks like a release tag.
if [[ -z "$TAG" && "${GITHUB_REF_NAME:-}" == v* ]]; then
  TAG="$GITHUB_REF_NAME"
fi

if [[ -n "$TAG" ]]; then
  [[ "$TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] ||
    ci_die "release tag must be vX.Y.Z (found: $TAG; app version is $version_line)"
  [[ "$TAG" == "$EXPECTED_TAG" ]] ||
    ci_die "tag $TAG must match app version $EXPECTED_TAG (declared $version_line)"
  ci_log "Version/tag check passed: $version_line -> $TAG"
else
  ci_log "Version check passed: $version_line (release tag should be $EXPECTED_TAG)"
fi

# Optional machine-readable values for shell callers that source this script
# is deliberately avoided: this script is a gate and exits on every mismatch.
# The build number is printed to make accidental reuse of stale artifacts
# visible in logs, even though Git tags carry only the semantic version.
ci_log "Android/iOS build number: $APP_BUILD"
