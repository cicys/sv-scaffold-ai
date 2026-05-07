#!/usr/bin/env python3
"""Validate compressed AGENTS.md format and indexed path truth."""

from pathlib import Path
import sys


PATH_VALIDATION_CATEGORIES = {
    "Backend Config",
    "Config",
    "Database",
    "Docs Root",
    "Local Skills",
    "Project Root",
    "Skill Root",
    "Source",
    "Subagent Docs",
    "Workspace AGENTS",
    "Workspace Layout",
    "Workspaces",
}


def fail(message: str) -> int:
    print(f"FAIL: {message}")
    return 1


def warn(message: str) -> None:
    print(f"WARN: {message}")


def find_repo_root(start: Path) -> Path:
    current = start.resolve()
    for candidate in [current, *current.parents]:
        if (candidate / ".git").exists():
            return candidate
    return Path.cwd().resolve()


def resolve_existing_path(token: str, agents_dir: Path, repo_root: Path) -> Path | None:
    normalized = token.strip().rstrip("/")
    if not normalized:
        normalized = "."

    candidates = [agents_dir / normalized]
    if repo_root != agents_dir:
        candidates.append(repo_root / normalized)

    for candidate in candidates:
        if candidate.exists():
            return candidate
    return None


def iter_index_paths(category: str, value: str) -> list[str]:
    if category not in PATH_VALIDATION_CATEGORIES:
        return []

    paths: list[str] = []
    for raw_segment in value.split("|"):
        segment = raw_segment.strip().strip("`")
        if not segment:
            continue

        if segment.endswith(":*"):
            paths.append(segment[:-2].strip())
            continue

        if ":{" in segment and segment.endswith("}"):
            base, items_block = segment.split(":{", 1)
            base = base.strip()
            items = [item.strip() for item in items_block[:-1].split(",") if item.strip()]
            if base:
                paths.append(base)
            for item in items:
                if item == "*":
                    continue
                paths.append(f"{base}/{item}" if base else item)
            continue

        paths.append(segment)

    return paths


def validate_index_paths(lines: list[str], path: Path) -> int:
    agents_dir = path.resolve().parent
    repo_root = find_repo_root(agents_dir)
    missing_entries: list[str] = []

    for line_no, line in enumerate(lines[1:], start=2):
        stripped = line.strip()
        if not stripped or not stripped.startswith("|"):
            continue

        body = stripped[1:]
        if ":" not in body:
            continue

        category, value = body.split(":", 1)
        for entry in iter_index_paths(category.strip(), value.strip()):
            if resolve_existing_path(entry, agents_dir, repo_root) is None:
                missing_entries.append(f"line {line_no} [{category.strip()}] -> {entry}")

    if missing_entries:
        details = "; ".join(missing_entries[:5])
        if len(missing_entries) > 5:
            details += f"; ... (+{len(missing_entries) - 5} more)"
        return fail(f"Indexed path target not found: {details}")

    return 0


def main() -> int:
    if len(sys.argv) != 2:
        return fail("Usage: node .agents/skills/infoq-agents-md-compress/scripts/example.mjs <path-to-AGENTS.md>")

    path = Path(sys.argv[1])
    if not path.exists():
        return fail(f"File not found: {path}")

    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines:
        return fail("File is empty")

    if lines[0].strip() != "# AGENTS.md":
        return fail("First line must be exactly '# AGENTS.md'")

    non_empty_after_title = [line.strip() for line in lines[1:] if line.strip()]
    if not non_empty_after_title:
        return fail("No index lines found after title")

    important_positions = [idx for idx, line in enumerate(non_empty_after_title, start=1) if line.startswith("|IMPORTANT:")]
    if not important_positions:
        return fail("Missing mandatory '|IMPORTANT:' line")
    if important_positions[0] > 3:
        warn("'|IMPORTANT:' should appear near top (recommended within first 3 non-empty lines)")

    for line_no, line in enumerate(lines[1:], start=2):
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith("##") or stripped.startswith("###"):
            return fail(f"Markdown heading found at line {line_no}: {stripped}")
        if stripped.startswith("```"):
            return fail(f"Code fence found at line {line_no}: {stripped}")
        if not stripped.startswith("|"):
            return fail(f"Non-index line at {line_no}: {stripped}")

    line_count = len(non_empty_after_title) + 1  # include title
    if line_count > 35:
        warn(f"Document has {line_count} non-empty lines; recommended range is ~15-35")

    path_status = validate_index_paths(lines, path)
    if path_status != 0:
        return path_status

    print("PASS: AGENTS.md matches compressed index format and path checks")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
