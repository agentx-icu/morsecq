#!/usr/bin/env bash
# Portable helpers for offline app packaging.
set -euo pipefail
ci_log() {
  printf '[ci] %s\n' "$*" >&2
}

ci_die() {
  printf '[ci][error] %s\n' "$*" >&2
  exit 1
}

ci_require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || ci_die "Missing required command: $cmd"
}

ci_repo_root() {
  local dir
  dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  printf '%s\n' "$dir"
}

ci_reset_dir() {
  local dir="$1"
  rm -rf "$dir"
  mkdir -p "$dir"
}

ci_windows_path() {
  local path="$1"
  if command -v cygpath >/dev/null 2>&1; then
    cygpath -m "$path"
  else
    printf '%s\n' "$path"
  fi
}
