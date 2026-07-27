# How the manual is written

The reader is in the middle of something and wants to finish it. Every rule below follows from
that.

## Voice

**Write to someone doing the thing, not about the thing.** "Open the campaign page and enter the
amount", not "Campaign pages allow the entry of amounts."

**Say what happens, including when nothing happens.** A reader worrying about being charged is
better served by "no money moves" than by silence.

**Short sentences. Concrete nouns.** Prefer the word the interface actually uses. If the button
says "Paguaj tani", write "Paguaj tani", in quotes, not "the payment button".

**No marketing.** This is a manual. The platform does not need selling to someone already using it.

**Do not promise.** Describe how the platform behaves, not how well it will go for the reader.

## Albanian

Albanian is the primary text. Write it as Albanian, not as translated English. If the English
sentence structure survives into the Albanian, the Albanian is not finished.

- **Standard Albanian, not Gheg.** The founder's personal writing (blog posts, the about page,
  campaign texts) uses a Gheg register. The manual does not. This is instructional text and sits
  next to the interface, which is standard Albanian throughout. Keep them consistent.
- **Formal address, second person plural** (`ju`, `mbështetni`, `do të merrni`). This is what the
  existing articles use and what the interface uses. Do not switch to `ti`.
- **Say "shqiptarë" when naming the audience.** Never "Albanian-speakers", "Albanian-speaking
  people", or their Albanian equivalents. The platform is for Albanians.
- **Diacritics are not optional.** `ë` and `ç` are spelled properly, every time.

## English

The English is a real article, not a gloss. It should read as though written directly in English by
someone who understands the platform. It carries the same facts as the Albanian, in the same order,
under the same headings, so the two can be read side by side.

## Structure

- One `# ` heading at the top. It is the article's title everywhere on the site, so make it a title,
  not a sentence, and keep it short enough to sit in a list.
- `## ` for sections. The site styles `#` and `##`; go no deeper.
- Numbered lists for anything the reader performs in order. Bulleted lists for things that are true
  at the same time.
- **Bold** for the decisive word in a paragraph, and for interface labels the reader must find.
- Open with a sentence that tells the reader they are in the right place. Do not open with a
  definition.

## Punctuation and characters

- **No em dashes.** Use a period, a comma, or a semicolon. This is enforced by `bin/validate.sh`.
- **No emoji.** The platform never renders plain emoji anywhere. This is also enforced.
- Use quotation marks around interface labels: `press "Paguaj tani"`.

## Links

- Cross-link with root-relative paths: `[verification](/help/campaigns/verification)`.
- Link the first time an article names something covered elsewhere, then stop. A paragraph with
  four links is a paragraph nobody reads.
- Link text describes the destination. Never "click here".

## Numbers

Some figures come from the platform's configuration: the fee percentage, the processing
passthrough, the collection window in days. They are pinned by the site's tests to their real
configured values.

Write them plainly (`14 ditë`, `5%`) and do not introduce a percentage figure that is not one of
those. A stray "about 3%" in an article will fail the site's build, which is deliberate: it stops a
stale number sitting next to a fresh one and both looking equally official.

If you believe a pinned figure is wrong, open an issue rather than editing the prose.

## Length

Most articles want 200 to 500 words. If one runs past that, it is usually two articles. An article
that answers one question well is more useful than one that answers four adequately.
