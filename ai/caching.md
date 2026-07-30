# Caching

```bash
ecko run app.ecko --cache          # cache in .ecko-cache/
export ECKO_AI_CACHE=~/.ecko/cache # or choose the directory
```

Identical calls replay the stored response: no API call, no budget consumption,
traced as `cached: true`.

## Content-addressed

The key is the content of the request - provider, model, prompt, and the schema
for a typed call. Two consequences:

- **Entries never go stale by key.** A changed prompt is a different key, not a
  wrong hit. There is nothing to invalidate.
- **To reset, delete the directory.** That is the whole cache-management story.

A replay still goes through the normal coercion path, so a cached response is
coerced and contract-checked exactly like a fresh one.

## What it is for

Iterating on the code *around* a prompt. Editing a loop, a schema, a handler, or
the formatting of an output while the prompt itself is stable - each run replays
instantly and free instead of paying for the same answer again.

It is also how you make a demo repeatable without going offline entirely.

## What bypasses it

- **[Voting](./voting.md)** - identical cached responses would defeat the point of
  independent samples.
- **[Sessions](./sessions.md)** - a cached reply would break a conversation.
- **Mock mode** - there is nothing to save.

## What it is not

Not a semantic cache. A prompt differing by one character is a miss. Nothing
fuzzy-matches, and that is deliberate: an approximate hit would silently answer a
question you did not ask.

Not a rate limiter, and not a substitute for `ECKO_AI_MAX_CALLS`. A cache reduces
repeat spending; a budget bounds total spending. Use both.

## Secrets

The cache stores prompts and responses on disk in plain form. A prompt containing
a `reveal`ed credential or personal data is a file on your filesystem afterwards.
Treat the cache directory like a log, keep it out of version control, and do not
point `ECKO_AI_CACHE` at a shared location.
