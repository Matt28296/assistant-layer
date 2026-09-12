# LIBRARIAN — the scheduled pass that keeps a vault honest

A daily job per vault. It does **not** write conclusions into the vault; it proposes, measures, and
republishes. An automated process that edits a knowledge base directly produces a knowledge base
nobody trusts.

---

## What a pass does

1. **Sweep** notes changed since the last run.
2. **Measure** every live number the vault asserts against its source, and record disagreements.
3. **Census** the link graph — broken links, orphans, frontmatter completeness.
4. **Propose** edits into `proposed/`, for the owner to merge. Never edit in place.
5. **Publish** the snapshot consumers actually read.
6. **Commit and push**, and verify the push landed.

`LAST_RUN` advances only when the pass **completes**, for the reason in the next section.

---

## The three failures this job has actually had

### It failed on a warning

The runner treated any output on the error stream as fatal. Git prints line-ending warnings on that
stream. So a routine warning terminated the run **after the work had succeeded**, leaving a full pass
staged and uncommitted for six hours.

**And `LAST_RUN` had already been written** — so the next day's pass would have skipped everything
that day had read. *That is not a lost day, it is a permanently invisible one.*

**Two fixes:** do not treat a native program's warnings as terminating, and **advance the
watermark only on success.**

### It failed loudly into a field nobody reads

The runner was written to fail loudly and did — non-zero exit, by design, with a comment in its own
source explaining that a quiet delivery failure was the exact gap it was closing.

**The loud failure went to a scheduler result field that nothing consumed between daily passes.**

> A guard that fails red into a channel with no reader is worth the same as one that failed green.
> **An alarm needs an actuator.**

### It shipped by coincidence, and the exit code was the only thing that knew

After a repair, the pass committed and pushed correctly — but the *snapshot publish* step still threw,
on a dirty working tree. The snapshot reached consumers anyway, because **an unrelated scheduled job
pushed the same repository four minutes later.**

Everything looked healthy. The exit code — a distinct value meaning *"pass succeeded, shipping
failed"* — was the only evidence.

> **A good outcome produced by coincidence is not a fixed system.** Give partial failures their own
> exit code, and read it.

---

## The snapshot rule

Consumers that cannot open the vault read a **published copy**. Publishing has two hard rules:

**1. Refuse to publish a page that contradicts a measured fact.** The publisher checks the vault's
assertions against the state files that measure them, and fails rather than shipping a page that
disagrees with reality.

**2. Flattening destroys every link.** A vault flattened into a snapshot directory loses its graph —
which is why the trigger index carries paths rather than wiki-links, and why it is the page designed
to survive flattening.

> **A snapshot that drifts is a reader ruling from a page nobody is looking at.**

If consumers read the copy, **republishing the copy is part of the change**, not a follow-up task.
And when the snapshot is stale but a decision cannot wait, send the consumer the current text
directly and say the snapshot is behind.

---

## Measuring what the vault asserts

The most valuable output of the pass is a machine-written file of **every number the vault claims,
measured against its source**, with a severity per finding:

- **BLOCKING** — the claim is on a page that auto-loads, or in the published snapshot. It will be
  acted on.
- **INFO** — anywhere else. A stale number in a dated note is correct-as-history, and flagging it is
  noise.

**And an explicit `unmeasurable` list.** Some claims cannot be checked: prose about who owns what,
counts where no artifact defines the unit, figures where two readings are both true of different
things. **Naming them as unmeasurable is the honest output** — guessing which unit an author meant
would assert a unit they never stated.
