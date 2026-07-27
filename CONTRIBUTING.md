# Contributing to the manual

Thank you for helping. This manual is read by people who are trying to do something specific and
are probably a little unsure. Clear beats clever, every time.

You do not need to be a programmer to contribute here. If you can write plainly in Albanian or
English, you can improve this manual.

## The kinds of contribution that help most

1. **Corrections.** A button that has been renamed, a step that no longer exists, a number that is
   out of date. These are the most valuable and the easiest to review.
2. **Clarity.** A paragraph that assumes knowledge the reader does not have, or a sentence that
   only makes sense if you already know the answer.
3. **Translation quality.** The Albanian is the primary text and the English is its sibling.
   Improvements to either are welcome, especially Albanian that reads as though it were written in
   Albanian rather than translated into it.
4. **New articles.** Worth opening an issue first, so we can agree the article is needed and
   where it belongs before you write it.

## Fixing or improving an existing article

1. Fork the repository and create a branch.
2. Edit the article. **Edit both locales.** An article exists in `sq` and `en`, and a change to one
   almost always means a change to the other. If you can only write one of them confidently, say so
   in the pull request and we will handle the other.
3. Run `bin/validate.sh`.
4. Open a pull request describing what was wrong and how you know.

## Adding a new article

1. Open an issue first.
2. Pick the category by asking who the reader is, not what the feature is. Someone signing a
   petition is in `backing` even though petitions are their own part of the platform.
3. Create both files:
   ```
   <category>/<your-slug>.sq.md
   <category>/<your-slug>.en.md
   ```
   The slug becomes the URL, so choose it as though it will not change, because changing it later
   breaks every link to the article.
4. Open each file with a `# ` heading. That heading is the article's title everywhere on the site,
   so it should read as a title and not as a sentence.
5. Link the new article from any existing article that should point at it. An article nothing links
   to is one nobody finds.
6. Run `bin/validate.sh`.

## Changing a number

Some articles quote figures that the platform holds in its configuration: the fee percentage, the
processing passthrough, the collection window in days. **Do not change these here on their own.**
The application's test suite pins the prose to the real configured value, so a change here without
the matching change there fails the site's build. Open an issue instead and describe what you
believe the correct figure is.

## Adding a new category

The three categories are declared in the application's code as well as existing as directories
here, and the site's tests assert the two agree. Creating a new directory here on its own will
break the site's build. Open an issue and we will make the two changes together.

## What happens after you open a pull request

- A check runs `bin/validate.sh` on your branch. It has to be green.
- A maintainer reviews the writing itself. The check verifies structure; only a person can tell
  whether a paragraph is actually clearer.
- After merging, the article is not live yet. The site pins this repository to an exact commit, and
  a separate change on the site bumps that pin and deploys it. This usually follows quickly.

## Reporting something without opening a pull request

Open an issue. Tell us which article, what is wrong, and what you expected. Screenshots help.
That is a genuinely useful contribution and there is no expectation that you fix it yourself.
