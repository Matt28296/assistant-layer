# BRAINS — two vaults, and why there are two

**This describes how the knowledge vaults are STRUCTURED and MAINTAINED. It deliberately contains
none of their content**, which is a model of a specific person's judgement and a specific
operation's private state.

---

## Why two

| Vault | Owns | Answers |
|---|---|---|
| **principal-mind** | the orchestrator | *How does the principal decide?* Objectives in their own words, priority rules, hard lines, heuristics, defaults by decision type, communication style |
| **system-brain** | the delegated-authority seat | *How does the system work?* Chain of command, seats, bus, gates, per-division state, open structural items |

They are separate because they go stale for **different reasons and at different rates**. How someone
decides changes slowly and only when they say so. How the system works changes several times a day
and is measurable. Merging them produces one document where half the entries are verifiable and half
are not, and readers treat the whole thing at the confidence of whichever half they noticed first.

---

## Core pages are ONE PAGE, on purpose

Each vault has a `core.md` that loads into every session. It stays one page.

Everything else is reached by following a link from an index. **Nothing else loads by default.** A
core page that grows to five pages is a core page nobody finishes, and the content at the bottom is
load-bearing precisely because it was added most recently.

**No live counts on a core page.** Current numbers live in machine-written state files with a
measurement timestamp. A hand-written number in a hand-written document is stale from the moment the
next event happens, and it is quotable forever.

---

## An agent cannot follow a wikilink

The single most useful structural rule here.

Wiki-style `[[links]]` are for humans in a vault application. An agent reading files needs a **path**.
So every index entry carries the link *and* the path beside it, and the machine-generated trigger
index carries paths only.

**The trigger index** is the mid-task entry point: a generated table of *trigger → action → path*
covering every note in the vault. Match a trigger, open the path. The core page is a summary; **the
note at the end of the path is the authority.**

*Before this existed, the only trigger list in either vault was a summary on the core page, and not
one line carried a route to the note behind it. The depth was unreachable in practice.*

---

## A folder is not a vault

An audit of one vault found **zero links and twenty-nine of twenty-nine notes orphaned.** It had the
directory layout of a knowledge base and none of the connective tissue. Every note read fine on its
own, which is exactly why nobody noticed.

The other vault's own core page was itself an orphan — the entry point was unreachable from anything.

**Run a link census as a scheduled check**, not as a one-off: broken links, orphans, and frontmatter
completeness. "It looks organised" is not a measurement.

---

## `confirmed/` versus `inferred/`

The principal-mind vault separates what the principal has **actually confirmed** from what has been
**inferred** from their behaviour.

This matters more than any other structure here, because an orchestrator emulating someone's judgement
is otherwise unable to distinguish "they told me this" from "I concluded this and have repeated it
until it felt settled."

> **A standing honesty check: if `confirmed/` is empty, then everything being emulated is inference,
> and the documents should say so in those words.**

Volume in `inferred/` is never the constraint. A short review queue that converts inferences into
signed-off rules is worth more than any amount of additional inference, and it costs the principal
minutes.

---

## Dated notes, and why they are not corrected in place

A note records what was true when it was written, with the date. When it is superseded, the newer note
supersedes it explicitly and **the old one stays**, marked.

A corrected-in-place vault loses the thing that makes it valuable: *why* the earlier conclusion was
reached, and what evidence changed it. That reasoning is what stops the same wrong conclusion being
re-derived in six weeks.
