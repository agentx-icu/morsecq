#!/usr/bin/env python3
"""Enforce the existing APP_STORE release budgets on final packaged bytes.

MiB means 1024*1024 bytes. Payload is logical bytes per regular-file pathname
plus relative symlink target bytes, without following links. Directories, disk
allocation, installer caches/registry and startup latency are outside this metric.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import stat
import sys


MIB = 1024 * 1024
# None records a final artifact without inventing an unspecified budget.
ARTIFACT_MIB = {
    "android": {".apk": 100, ".aab": 100},
    "ios": {".ipa": 150},
    "macos": {".pkg": 100, ".zip": None},
    "windows": {".msi": 150, ".zip": None},
    "linux": {".deb": 100, ".rpm": 100, ".tar.gz": None},
}
PAYLOAD_MIB = {"macos": 100, "windows": 250, "linux": 250}
METRIC = "regular-file logical bytes per pathname + symlink target bytes; no link traversal, directory/block allocation or OS installer caches"


def payload_bytes(root):
    root = Path(root)
    if root.is_symlink() or not root.is_dir():
        raise ValueError("Expected a real application payload directory")
    root = root.resolve()
    total = regular = links = 0
    def inaccessible(error):
        raise ValueError("Cannot inspect the complete application payload") from error
    for directory, directories, files in os.walk(root, followlinks=False, onerror=inaccessible):
        for name in directories + files:
            path = Path(directory) / name
            mode = path.lstat()
            if stat.S_ISLNK(mode.st_mode):
                target = os.readlink(path)
                if Path(target).is_absolute():
                    raise ValueError("Non-relocatable payload symlink")
                try:
                    resolved = path.resolve(strict=True)
                except (OSError, RuntimeError) as error:
                    raise ValueError("Dangling or cyclic payload symlink") from error
                if not resolved.is_relative_to(root):
                    raise ValueError("Escaping payload symlink")
                total += len(os.fsencode(target))
                links += 1
            elif stat.S_ISREG(mode.st_mode):
                total += mode.st_size
                regular += 1
            elif not stat.S_ISDIR(mode.st_mode):
                raise ValueError("Unsupported special file in application payload")
    return {"bytes": total, "regular_files": regular, "symlinks": links, "metric": METRIC}


def artifact_record(path, limit):
    path = Path(path)
    if path.is_symlink() or not path.is_file():
        raise ValueError(f"Expected a real final artifact: {path.name}")
    with path.open("rb") as stream:
        before = os.fstat(stream.fileno())
        checksum = hashlib.file_digest(stream, "sha256").hexdigest()
        after = os.fstat(stream.fileno())
    if before.st_size <= 0 or (before.st_size, before.st_mtime_ns) != (after.st_size, after.st_mtime_ns):
        raise ValueError(f"Empty or changing final artifact: {path.name}")
    return {"name": path.name, "bytes": after.st_size, "sha256": checksum,
            "limit_bytes": limit * MIB if limit is not None else None}


def write_report(output, report):
    output = Path(output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(report, indent=2) + "\n")


def verify_sizes(platform, architecture, artifacts, payload, output):
    report = {"platform": platform, "architecture": architecture,
              "source": "doc/release/APP_STORE.md#release-budgets",
              "mib_bytes": MIB, "outcome": "failed"}
    try:
        if platform not in ARTIFACT_MIB or not isinstance(architecture, str) or not architecture.strip():
            raise ValueError("A supported platform and explicit architecture are required")
        limits = ARTIFACT_MIB[platform]
        records, found = [], []
        for path in artifacts:
            path = Path(path)
            kind = next((suffix for suffix in limits if path.name.lower().endswith(suffix)), None)
            if kind is None or kind in found:
                raise ValueError("Unexpected or duplicate final artifact type")
            found.append(kind)
            records.append(artifact_record(path, limits[kind]))
        if set(found) != set(limits):
            raise ValueError("Missing final artifacts required by the release matrix")
        report["artifacts"] = records
        violations = [f"{item['name']}: {item['bytes']} > {item['limit_bytes']} bytes"
                      for item in records if item["limit_bytes"] is not None and item["bytes"] > item["limit_bytes"]]
        if platform != "android":
            measured = payload_bytes(payload)
            limit = PAYLOAD_MIB.get(platform)
            measured["limit_bytes"] = limit * MIB if limit is not None else None
            report["payload"] = measured
            if limit is not None and measured["bytes"] > limit * MIB:
                violations.append(f"application payload: {measured['bytes']} > {limit * MIB} bytes")
        elif payload is not None:
            raise ValueError("Android installed size has no declared budget or measured installed payload here")
        report.update(outcome="failed" if violations else "passed", violations=violations)
    except (OSError, ValueError, TypeError) as error:
        report["error"] = str(error)
        write_report(output, report)
        raise
    write_report(output, report)
    if violations:
        raise ValueError("Release size budget exceeded: " + "; ".join(violations))
    return report


def record_unsigned_archive(payload, output):
    report = {"platform": "ios", "architecture": "arm64", "outcome": "recorded",
              "scope": "Unsigned archive app payload only; no IPA produced or qualified against the 150 MiB IPA budget",
              "payload": payload_bytes(payload)}
    write_report(output, report)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--platform", required=True, choices=ARTIFACT_MIB)
    parser.add_argument("--architecture", required=True)
    parser.add_argument("--artifacts", type=Path, required=True)
    parser.add_argument("--payload", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    try:
        artifacts = sorted(path for path in args.artifacts.iterdir()
                           if path.is_file() and not path.name.startswith(".") and path.name != "SHA256SUMS")
        verify_sizes(args.platform, args.architecture, artifacts, args.payload, args.output)
        print(f"Final release size budgets passed: {args.output}")
        return 0
    except (OSError, ValueError, TypeError) as error:
        print(f"Release size budget check failed: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
