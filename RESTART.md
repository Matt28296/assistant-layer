# RESTART — the pattern for a document that brings everything back

`CONTINUITY.md` explains *what fails and why*. This file is about the **operational document** that
sits beside it: a per-component restart reference, regenerated daily, that a cold session can follow
without knowing anything.

It is separated out because the two documents fail differently, and the restart document fails
worse — it is the one consulted at the moment nobody has time to reason.

---

## Rules that make it trustworthy

**1. Re-derive facts from each component's own state, never from memory.**
The document is regenerated from what the components publish about themselves. An entry written from
recollection is a claim (`LAWS.md` §1).

**2. A new component with no restart entry is a bug**, tracked as one.

**3. Lead with a `CURRENT AS OF` block that explicitly wins over everything below it.**
The document accretes. A reader arriving top-down otherwise meets the oldest content first. Everything
below the block is history, and says so.

**4. Keep superseded sections, marked superseded.**
The reason a conclusion changed is worth more than the conclusion. Delete the claim, keep the
correction.

**5. State the instrument's reach for the pass.**
When a regeneration runs with less access than usual — a sandbox refusing a probe, a tool unavailable
— say so **in the document**, and scope every claim in that pass accordingly. A number carried into a
different instrument's units keeps its authority and loses its meaning.

**6. Where a fact could not be measured, write UNVERIFIED.** Not a plausible value.

**7. Cross-read the neighbouring documents before writing "no entry exists."** (`LAWS.md` §14.)

---

## What each entry contains

```
COMPONENT      what it is, in one line
WHERE          machine + exact path
CLASS          scheduled job / at-logon / attended session / interactive dependency
BRING IT BACK  the exact command, with full paths
WHO            nobody / any agent / the human specifically
CONFIRM IT     the check that proves it is really back -- and NOT the thing that lied
STATE          measured status, with the time of measurement
RESUME POINT   the first thing this component should do when it returns
```

**`RESUME POINT` is the field that earns the document.** A component that restarts and does not know
what it was doing has restarted into idleness.

**But a resume point is only as good as the restart.** One component carried a correct, specific
resume point — *"fix this error before anything else"* — through **five consecutive days** while
nothing ever started it. *A resume point assigned to a component nobody starts is a note left on an
empty chair.* If a resume point ages, the thing to escalate is the restart, not the note.

---

## The failure this document is most prone to

**Reading a status field as a health field.**

A scheduled job's result code has a *contract*, and it is per-job. One job in this system returns a
non-zero code to mean "the thing I watch is late" — a correct, healthy report. A pass that read the
number without the contract scored that job as the single failure and **missed two genuine
failures in the same sweep**, producing a summary that was pessimistic about recovery and optimistic
about health simultaneously.

**Read the contract per row, every pass.**

Three codes worth knowing in any scheduler, because all three have been misread here:

- *currently running* — not an error
- *has never run* — a placeholder date is the tell, and it catches jobs that were registered and
  never fired
- *a non-zero code that is a signal, not a crash*

**And enumerate without a filter.** A count taken from a remembered list cannot find what the list is
missing. A filtered enumeration once hid an entire scheduled job from this document for days, while
two neighbouring documents carried it by name.

---

## Daily upkeep

- **0a.** Regenerate from source. Do not hand-edit values the generator owns.
- **0b.** Enumerate **all** components unfiltered and diff against the document. Additions are the
  point.
- **0c.** Cross-read the neighbouring documents before asserting any absence.
- **0d.** Re-run the verification for anything reported fixed *since the fix*, not before it. A hazard
  closed on the strength of having run the fix, rather than on re-running the check, comes back
  quietly — one such item returned three times under a rule everyone could see.
- **0e.** Record what the pass could not reach.
