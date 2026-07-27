#!/usr/bin/env bash
#
# validate.sh — the content gate for the NgatmaDorën manual.
#
# Runs on every pull request (.github/workflows/validate.yml) and is worth running
# locally before you push: `bin/validate.sh`.
#
# What it checks, and why each one matters:
#
#   1. Filename shape     — the category and slug become URL segments on
#                           ngatmadoren.com. The site validates them against exactly
#                           this pattern before touching the filesystem and refuses
#                           anything else, so a misnamed file is an article nobody can
#                           ever open.
#   2. Locale parity      — every article exists in BOTH sq and en, and neither is
#                           empty. The site falls back to English when an Albanian file
#                           is missing, which hides the gap instead of reporting it.
#   3. A top-level H1     — the site reads the article's title from its first `# `
#                           heading. No heading, no title, and the page errors.
#   4. Internal links     — a /help/... link that points at no article is a silent 404.
#   5. House style        — no em dashes, no emoji (see STYLE.md).
#
# Exit: 0 = clean · 1 = at least one problem, each printed with its file.

set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

fail=0
problem() { printf '  ✗ %s\n' "$1"; fail=1; }

# The same anchored, traversal-safe shape the site enforces before any filesystem
# access. Keep this in sync with App\Support\HelpContent::SEGMENT_PATTERN.
segment='^[a-z0-9]+(-[a-z0-9]+)*$'

# Articles are the markdown files exactly one directory deep: <category>/<slug>.<locale>.md.
# Root-level markdown (README, CONTRIBUTING, STYLE) is repo documentation, not content,
# and .github/ holds templates — neither is an article, so neither is checked as one.
articles=()
while IFS= read -r file; do articles+=("$file"); done < <(
    find . -mindepth 2 -maxdepth 2 -name '*.md' -not -path './.git/*' -not -path './.github/*' | sort
)

if [ ${#articles[@]} -eq 0 ]; then
    echo "✗ no article files found — this cannot be right."
    exit 1
fi

# ── 1. Filename + directory shape ────────────────────────────────────────────
echo "▸ filename and directory shape"

# Anything deeper is an article the site will never find: it only ever reads
# <category>/<slug>.<locale>.md, so a nested file is invisible rather than broken.
while IFS= read -r stray; do
    problem "${stray#./} — articles live at <category>/<slug>.<locale>.md, one directory deep."
done < <(find . -mindepth 3 -name '*.md' -not -path './.git/*' -not -path './.github/*' | sort)

for file in "${articles[@]}"; do
    rel="${file#./}"
    category="${rel%%/*}"
    base="$(basename "$rel" .md)"
    locale="${base##*.}"
    slug="${base%.*}"

    [[ "$category" =~ $segment ]] || problem "$rel — category '$category' must be lowercase words joined by single dashes."
    [[ "$slug" =~ $segment ]]     || problem "$rel — slug '$slug' must be lowercase words joined by single dashes."

    case "$locale" in
        sq | en) ;;
        *) problem "$rel — locale must be 'sq' or 'en', found '$locale'." ;;
    esac
done

# ── 2. Locale parity + non-empty ─────────────────────────────────────────────
# ADR-0017: prose content is guarded by FILE parity, not key parity.
echo "▸ sq/en parity"
for file in "${articles[@]}"; do
    rel="${file#./}"
    base="${rel%.*.md}"
    locale="$(basename "$rel" .md)"; locale="${locale##*.}"

    [ "$locale" = "sq" ] || [ "$locale" = "en" ] || continue
    other=$([ "$locale" = "sq" ] && echo en || echo sq)
    sibling="${base}.${other}.md"

    if [ ! -f "$sibling" ]; then
        problem "$rel — missing its $other translation ($sibling)."
    elif [ -z "$(tr -d '[:space:]' < "$sibling")" ]; then
        problem "$sibling — is empty."
    fi
done

# ── 3. A top-level heading ───────────────────────────────────────────────────
echo "▸ every article has a title"
for file in "${articles[@]}"; do
    grep -qE '^# .+' "$file" || problem "${file#./} — has no top-level '# ' heading, so the site cannot title it."
done

# ── 4. Internal cross-links resolve ──────────────────────────────────────────
# Markdown cannot call route(), so articles cross-link with root-relative paths.
echo "▸ internal /help/ links resolve"
for file in "${articles[@]}"; do
    while IFS= read -r target; do
        [ -n "$target" ] || continue

        if [[ ! "$target" =~ ^[a-z0-9-]+/[a-z0-9-]+$ ]]; then
            problem "${file#./} — malformed help link '/help/$target'."
            continue
        fi

        [ -f "${target}.sq.md" ] || problem "${file#./} — link '/help/$target' points at no article."
    done < <(grep -oE '\]\(/help/[^)]+\)' "$file" | sed -E 's#\]\(/help/(.*)\)#\1#')
done

# ── 5. House style ───────────────────────────────────────────────────────────
echo "▸ house style"
for file in "${articles[@]}"; do
    if grep -q '—' "$file"; then
        problem "${file#./} — contains an em dash. Use a period, comma or semicolon (STYLE.md)."
    fi

    # perl rather than `grep -P`: BSD grep (macOS) has no -P, and a check that
    # silently passes when its tool is missing is worse than no check at all.
    # Note the flag: an `exit 0` mid-stream would run END, whose own exit status
    # would override it, and the check would silently never fire.
    if perl -CSD -ne '$hit = 1 if /[\x{1F300}-\x{1FAFF}\x{2600}-\x{27BF}\x{FE0F}\x{2B00}-\x{2BFF}]/; END { exit($hit ? 0 : 1) }' "$file"; then
        problem "${file#./} — contains an emoji. The platform never renders plain emoji (STYLE.md)."
    fi
done

# ── 6. The manifest matches the files ────────────────────────────────────────
# manual.json is the manual's table of contents. An article missing from it still
# has a working URL but appears in no listing and nothing links to it, so drift here
# publishes invisible pages. Detail lives in bin/check-manifest.py.
echo "▸ manual.json matches the articles on disk"
python3 bin/check-manifest.py || fail=1

# ── Verdict ──────────────────────────────────────────────────────────────────
echo
if [ "$fail" -eq 0 ]; then
    echo "✅ content valid (${#articles[@]} files checked)"
else
    echo "❌ content validation FAILED — fix the problems above."
fi
exit "$fail"
