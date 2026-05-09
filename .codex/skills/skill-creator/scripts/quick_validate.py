#!/usr/bin/env python3
"""
Quick validation script for skills - minimal version
"""

import re
import sys
from pathlib import Path

import yaml

MAX_SKILL_NAME_LENGTH = 64
ALLOWED_TOP_LEVEL = {"SKILL.md", "agents", "scripts", "references", "assets"}


def has_reference_toc(lines):
    head = "\n".join(lines[:30]).lower()
    return (
        "## table of contents" in head
        or "## contents" in head
        or "## 目录" in head
        or "[toc]" in head
    )


def validate_skill(skill_path):
    """Basic validation of a skill"""
    skill_path = Path(skill_path)

    skill_md = skill_path / "SKILL.md"
    if not skill_md.exists():
        return False, "SKILL.md not found"

    content = skill_md.read_text()
    if len(content.splitlines()) > 500:
        return False, "SKILL.md exceeds 500 lines"
    if not content.startswith("---"):
        return False, "No YAML frontmatter found"

    match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not match:
        return False, "Invalid frontmatter format"

    frontmatter_text = match.group(1)

    try:
        frontmatter = yaml.safe_load(frontmatter_text)
        if not isinstance(frontmatter, dict):
            return False, "Frontmatter must be a YAML dictionary"
    except yaml.YAMLError as e:
        return False, f"Invalid YAML in frontmatter: {e}"

    allowed_properties = {"name", "description", "license", "allowed-tools", "metadata"}

    unexpected_keys = set(frontmatter.keys()) - allowed_properties
    if unexpected_keys:
        allowed = ", ".join(sorted(allowed_properties))
        unexpected = ", ".join(sorted(unexpected_keys))
        return (
            False,
            f"Unexpected key(s) in SKILL.md frontmatter: {unexpected}. Allowed properties are: {allowed}",
        )

    if "name" not in frontmatter:
        return False, "Missing 'name' in frontmatter"
    if "description" not in frontmatter:
        return False, "Missing 'description' in frontmatter"

    name = frontmatter.get("name", "")
    if not isinstance(name, str):
        return False, f"Name must be a string, got {type(name).__name__}"
    name = name.strip()
    if name:
        if not re.match(r"^[a-z0-9-]+$", name):
            return (
                False,
                f"Name '{name}' should be hyphen-case (lowercase letters, digits, and hyphens only)",
            )
        if name.startswith("-") or name.endswith("-") or "--" in name:
            return (
                False,
                f"Name '{name}' cannot start/end with hyphen or contain consecutive hyphens",
            )
        if len(name) > MAX_SKILL_NAME_LENGTH:
            return (
                False,
                f"Name is too long ({len(name)} characters). "
                f"Maximum is {MAX_SKILL_NAME_LENGTH} characters.",
            )
        if skill_path.name != name:
            return (
                False,
                f"Skill folder '{skill_path.name}' must exactly match frontmatter name '{name}'",
            )

    description = frontmatter.get("description", "")
    if not isinstance(description, str):
        return False, f"Description must be a string, got {type(description).__name__}"
    description = description.strip()
    if description:
        if "<" in description or ">" in description:
            return False, "Description cannot contain angle brackets (< or >)"
        if len(description) > 1024:
            return (
                False,
                f"Description is too long ({len(description)} characters). Maximum is 1024 characters.",
            )

    extras = sorted(path.name for path in skill_path.iterdir() if path.name not in ALLOWED_TOP_LEVEL)
    if extras:
        return (
            False,
            "Unexpected top-level file(s) or directory(ies): " + ", ".join(extras),
        )

    references_dir = skill_path / "references"
    if references_dir.exists():
        for reference_path in sorted(references_dir.rglob("*.md")):
            lines = reference_path.read_text().splitlines()
            if len(lines) > 100 and not has_reference_toc(lines):
                relative_path = reference_path.relative_to(skill_path)
                return (
                    False,
                    f"Long reference file '{relative_path}' is missing a table of contents near the top",
                )

    openai_yaml = skill_path / "agents" / "openai.yaml"
    if openai_yaml.exists():
        try:
            openai = yaml.safe_load(openai_yaml.read_text()) or {}
        except yaml.YAMLError as exc:
            return False, f"Invalid YAML in agents/openai.yaml: {exc}"
        interface = openai.get("interface") if isinstance(openai, dict) else None
        if interface is None or not isinstance(interface, dict):
            return False, "agents/openai.yaml must contain an interface mapping"
        default_prompt = interface.get("default_prompt")
        if default_prompt and f"${name}" not in default_prompt:
            return (
                False,
                f"agents/openai.yaml default_prompt must explicitly mention ${name}",
            )

    return True, "Skill is valid!"


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: node .codex/skills/skill-creator/scripts/quick_validate.mjs <skill_directory>")
        sys.exit(1)

    valid, message = validate_skill(sys.argv[1])
    print(message)
    sys.exit(0 if valid else 1)
