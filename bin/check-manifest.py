#!/usr/bin/env python3
"""Check manual.json against the article files on disk.

manual.json declares the manual's reading order: which parts, in which order, and
which articles within each part. It is the table of contents, and it drives the
site's next/prev links, the sidebar, and the printed book.

Because it is a second source of truth alongside the files themselves, the two can
drift. That drift is silent in the worst direction: an article missing from the
manifest still exists as a file and still has a working URL, but nothing links to it
and it appears in no listing. It is published and invisible. So a mismatch is an
error here, not a warning.

Run through bin/validate.sh, or directly: python3 bin/check-manifest.py
"""

from __future__ import annotations

import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
MANIFEST = ROOT / "manual.json"

problems: list[str] = []


def problem(message: str) -> None:
    problems.append(message)


def load_manifest() -> dict | None:
    if not MANIFEST.is_file():
        problem("manual.json is missing. It declares the manual's reading order.")
        return None

    try:
        return json.loads(MANIFEST.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        problem(f"manual.json is not valid JSON: {exc}")
        return None


def article_slugs_on_disk() -> dict[str, set[str]]:
    """Every {category: {slug}} that has at least one article file."""
    found: dict[str, set[str]] = {}

    for path in sorted(ROOT.glob("*/*.md")):
        if path.parent.name == ".github":
            continue
        # <slug>.<locale>.md -> <slug>
        slug = path.name.rsplit(".", 2)[0]
        found.setdefault(path.parent.name, set()).add(slug)

    return found


def main() -> int:
    manifest = load_manifest()
    if manifest is None:
        report()
        return 1

    if manifest.get("version") != 1:
        problem(f"manual.json declares version {manifest.get('version')!r}; this checker understands version 1.")

    parts = manifest.get("parts")
    if not isinstance(parts, list) or not parts:
        problem("manual.json must declare a non-empty 'parts' list.")
        report()
        return 1 if problems else 0

    on_disk = article_slugs_on_disk()
    listed: dict[str, list[str]] = {}
    seen_categories: list[str] = []

    for index, part in enumerate(parts):
        if not isinstance(part, dict):
            problem(f"parts[{index}] is not an object.")
            continue

        category = part.get("category")
        articles = part.get("articles")

        if not isinstance(category, str) or not category:
            problem(f"parts[{index}] has no 'category'.")
            continue

        if category in seen_categories:
            problem(f"category '{category}' appears more than once in manual.json.")
        seen_categories.append(category)

        if not isinstance(articles, list) or not articles:
            problem(f"part '{category}' must list a non-empty 'articles' array.")
            continue

        duplicates = {slug for slug in articles if articles.count(slug) > 1}
        for slug in sorted(duplicates):
            problem(f"part '{category}' lists '{slug}' more than once.")

        listed[category] = articles

    # A part with no directory: every entry in it points at nothing.
    for category in listed:
        if category not in on_disk:
            problem(f"manual.json declares part '{category}', but no such directory holds articles.")

    # A directory absent from the manifest: every article in it is invisible.
    for category in sorted(on_disk):
        if category not in listed:
            problem(
                f"directory '{category}' holds articles but is not a part in manual.json, "
                f"so none of them appear in the manual."
            )

    for category in sorted(set(listed) & set(on_disk)):
        listed_slugs = set(listed[category])
        disk_slugs = on_disk[category]

        for slug in sorted(listed_slugs - disk_slugs):
            problem(f"manual.json lists '{category}/{slug}', but there is no article file for it.")

        for slug in sorted(disk_slugs - listed_slugs):
            problem(
                f"'{category}/{slug}' exists but is not listed in manual.json, so it would be "
                f"published at a working URL that nothing links to."
            )

    report()
    return 1 if problems else 0


def report() -> None:
    for message in problems:
        print(f"  ✗ {message}")


if __name__ == "__main__":
    sys.exit(main())
