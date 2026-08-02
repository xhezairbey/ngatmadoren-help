# The NgatmaDorën manual

The help center for [ngatmadoren.com](https://ngatmadoren.com), in Albanian and English.

NgatmaDorën is a community-action platform for Albanians, built on mutual aid and active
citizenship (*"ngatma dorën" = lend a hand*). This repository holds the manual: the articles that
explain how the platform works, for the people using it.

Every article here is published at `https://ngatmadoren.com/help/<category>/<slug>`.

The manual is public and open to contributions. If something is wrong, unclear, or missing,
[open an issue](https://github.com/xhezairbey/ngatmadoren-help/issues) or send a pull request.
See [CONTRIBUTING.md](CONTRIBUTING.md) to get started and [STYLE.md](STYLE.md) for how the
articles are written.

## Layout

```
<category>/<slug>.<locale>.md
```

- **category** is one of the three audience doors, and it is the first URL segment:
  - `backing` — for people backing campaigns, contributing, or signing petitions
  - `campaigns` — for initiators: creating, verifying, fees, payouts, updates
  - `account` — signing in, security, profile, panel, closing an account
- **slug** is the second URL segment: lowercase words joined by single dashes.
- **locale** is `sq` (Albanian, the default) or `en` (English).

Every article exists in **both** locales. The article's title is its first `# ` heading, so every
file opens with one.

## `manual.json` — the reading order

The manual is meant to be read as a book, not just searched. `manual.json` declares its order: which
parts, in which order, and which articles within each part.

```json
{
  "version": 1,
  "parts": [
    { "category": "backing", "articles": ["how-pledging-works", "..."] }
  ]
}
```

The order is **pedagogical, not alphabetical**. An article should come after whatever a reader needs
to understand it first.

This file drives the site's next/prev links, the sidebar, and the printed manual. An article that
exists as a file but is missing from `manual.json` is published at a working URL that nothing links
to and no listing shows, so **adding an article means adding it here too**. `bin/validate.sh` treats
any mismatch in either direction as an error.

Articles cross-link each other with root-relative paths, because markdown cannot build the site's
URLs itself:

```markdown
See [how pledging works](/help/backing/how-pledging-works).
```

## Checking your changes

```bash
bin/validate.sh
```

This is the same check that runs on every pull request. It verifies the filename shape, that both
locales exist and are non-empty, that every article has a title, that internal `/help/` links point
at real articles, and that the house style rules hold.

## How this reaches the site

The site consumes this repository as a **git submodule** mounted at `resources/content/help`,
pinned to an exact commit. Merging here does not publish: the application repository bumps the
pinned commit, and that bump deploys. So a change goes live in two steps, and the site's own test
suite gets to check the content before it ships.

That second gate is not a formality. The application's tests pin the money figures quoted in these
articles (the fee percentage, the processing passthrough, the collection window) to the platform's
real configuration, so an article that misstates a number fails the build over there even though
everything here is green. If you are changing a figure, say so in your pull request.

## Licence

The articles are the platform's documentation. Please open an issue if you would like to reuse
them elsewhere.
