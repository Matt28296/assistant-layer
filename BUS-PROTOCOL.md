# BUS PROTOCOL — how independent agent sessions coordinate

The coordination substrate is a **git repository**. Not a message queue, not a database. The
reasoning is that git already provides the three properties this problem needs — append-only history,
attribution, and a remote that can act as the arbiter of what actually happened — and every agent
already has a client for it.

---

## Layout

```
msg/<seat>.md        append-only.  A seat's narrative log. Nobody else writes here.
state/<seat>.json    overwritten.  Current status. Small, structured, machine-read.
state/<shared>.json  registers that many seats read (blocked items, measured facts)
```

**Two files per seat, because they answer different questions.** The log says what happened; the
state file says where things stand. A busy seat writes plenty of log and forgets the state file — so
reading only state calls live seats dead, and reading only logs misses a seat wedged mid-task.

> **Read both, or neither. When they disagree, report the disagreement as a finding — never resolve
> it by taking the fresher one.**

**Read `state/` for summaries; logs are archives.** Logs grow without bound and are for forensics.

---

## Identity — fail closed

A seat's identity is **hostname + launch working directory + which files it writes**. All three,
checked at the start of every session, *measured rather than remembered*.

Why all three: one machine can host several seats, so hostname alone is ambiguous. A directory can be
opened from anywhere, so the path alone is ambiguous. And an agent that cannot match itself to a row
in the identity table **stops** rather than guessing.

*Both discriminators have been observed to move at once — a machine rename and a user-profile change
in the same maintenance event — while an agent asserted "same box, same hostname" from habit in the
very pass where it re-measured everyone else. Measure your own identity with the same instrument you
use on others.*

**Corollary: a direct message between two agent sessions is not a bus write.** Work coordinated
out-of-band does not exist to anyone who was not in that conversation, and it will not survive the
session. Commit per turn.

---

## The identity table is the authority

One table, in one file, lists every seat: machine, exact working directory, what it may write, and
what it may never do. **Do not keep a second copy elsewhere** — that is how two rows come to disagree,
and a disagreement about who is allowed to publish is expensive.

---

## Liveness

> **A declared cadence is a claim until measured.** See `LAWS.md` §1.

A watcher checks every agent against **its own declared cadence**, not one global threshold, and
flags at a multiple of that claim. An agent claiming fifteen minutes is flagged around forty-five;
one that claims no cadence is never flagged for silence.

**Statuses and what each requires:**

| Status | Requires |
|---|---|
| `VERIFIED-ACTIVE` | A round-trip **and** a heartbeat fresher than its declared cadence |
| `ATTENDED` | Round-trip proven, no autonomous cadence — do not expect unprompted replies |
| `UNVERIFIED` | Anything self-declared. **No document may call this "active."** |
| `STALE` | Was verified, has since gone past its cadence. Treat as down until re-proven |
| `DORMANT` | Deliberately not running — a decision, not a failure |

**Quote the measurement TIME beside every status, never the status alone.** A liveness reading is a
photograph, not a property, and the `IDLE` ones expire first — an idle seat is exactly the thing that
can change state with nobody doing anything.

**Do not let a scheduled job write a seat's heartbeat.** If a timer publishes the seat's state file
every few minutes, that seat's freshness is pinned by a robot and it can never be flagged stale. See
`LAWS.md` §3.

---

## Don't nudge a seat because its log is quiet

The instrument measures **log writes**, not work. A seat rendering continuously for five hours with
nothing to say produces the same reading as a seat that has stopped.

*Seven consecutive nudges were once sent to a seat that was never asleep.* Check for a second,
independent witness — output artifacts, process state, a timestamp inside its own files — before
escalating silence.

---

## Writing discipline

- **Never write another seat's files.** Not to help, not to correct.
- **One checkout per writing session** (`LAWS.md` §15).
- **`git status` immediately before staging.** If the change set contains files you did not touch,
  another session is working here — commit your own paths explicitly.
- **Integrating a dirty tree:** `pull --rebase` **aborts before fetching** when tracked files are
  modified. A synchronisation job that used it, and discarded the return code, silently failed to
  fetch four of nine repositories **for nine consecutive days** — the four with dirty trees. Use an
  explicit fetch, or auto-stash, and **read the return code.**
- **The remote is the receipt** (`LAWS.md` §13).

---

## Reporting cadence

Each cycle, an orchestrator does a fixed sweep rather than reporting whatever it noticed:

1. **What shipped?** Asked first, every cycle, and answered with an artifact or "nothing."
2. **Per-seat liveness**, measured, with the time of measurement.
3. **Documentation currency** — is what the seats read still true?
4. **A second artifact spot-check**, chosen so the sweep cannot become a ritual.
5. **Anything blocked on the human**, with its age.

**A genuinely clean cycle writes state only and posts nothing.** A cycle that posts every time trains
readers to skim, and the post that matters then arrives into a habit of skimming.

**Anti-flood rule:** do not repeat a finding unless it has *materially changed* — a doubled elapsed
time, a new cause, a new owner. Name the threshold you used, so "I already said that" is checkable.
